#include "kernel.h"
#include "lib.h"

// kernel.c
//
//    This is the kernel.


// INITIAL PHYSICAL MEMORY LAYOUT
//
//  +-------------- Base Memory --------------+
//  v                                         v
// +-----+--------------------+----------------+--------------------+---------/
// |     | Kernel      Kernel |       :    I/O | App 1        App 1 | App 2
// |     | Code + Data  Stack |  ...  : Memory | Code + Data  Stack | Code ...
// +-----+--------------------+----------------+--------------------+---------/
// 0  0x40000              0x80000 0xA0000 0x100000             0x140000
//                                             ^
//                                             | \___ PROC_SIZE ___/
//                                      PROC_START_ADDR

#define PROC_SIZE 0x40000       // initial state only

static proc processes[NPROC];   // array of process descriptors
                                // Note that `processes[0]` is never used.
proc* current;                  // pointer to currently executing proc

#define HZ 100                  // timer interrupt frequency (interrupts/sec)
static unsigned ticks;          // # timer interrupts so far

void schedule(void);
void run(proc* p) __attribute__((noreturn));


// PAGEINFO
//
//    The pageinfo[] array keeps track of information about each physical page.
//    There is one entry per physical page.
//    `pageinfo[pn]` holds the information for physical page number `pn`.
//    You can get a physical page number from a physical address `pa` using
//    `PAGENUMBER(pa)`. (This also works for page table entries.)
//    To change a physical page number `pn` into a physical address, use
//    `PAGEADDRESS(pn)`.
//
//    pageinfo[pn].refcount is the number of times physical page `pn` is
//      currently referenced. 0 means it's free.
//    pageinfo[pn].owner is a constant indicating who owns the page.
//      PO_KERNEL means the kernel, PO_RESERVED means reserved memory (such
//      as the console), and a number >=0 means that process ID.
//
//    pageinfo_init() sets up the initial pageinfo[] state.

typedef struct physical_pageinfo {
    int8_t owner;
    int8_t refcount;
} physical_pageinfo;

static physical_pageinfo pageinfo[PAGENUMBER(MEMSIZE_PHYSICAL)];

typedef enum pageowner {
    PO_FREE = 0,                // this page is free
    PO_RESERVED = -1,           // this page is reserved memory
    PO_KERNEL = -2              // this page is used by the kernel
} pageowner_t;

static void pageinfo_init(void);


// Memory functions

void virtual_memory_check(void);
void memshow_physical(void);
void memshow_virtual(x86_pagetable* pagetable, const char* name);
void memshow_virtual_animate(void);


x86_pagetable* copy_pagetable(x86_pagetable* pagetable, int8_t owner);

// kernel(command)
//    Initialize the hardware and processes and start running. The `command`
//    string is an optional string passed from the boot loader.

static void process_setup(pid_t pid, int program_number);

void kernel(const char* command) {
    hardware_init();
    pageinfo_init();
    console_clear();
    timer_init(HZ);

    // Set up process descriptors
    memset(processes, 0, sizeof(processes));
    for (pid_t i = 0; i < NPROC; i++) {
        processes[i].p_pid = i;
        processes[i].p_state = P_FREE;
    }

    if (command && strcmp(command, "fork") == 0)
        process_setup(1, 4);
    else if (command && strcmp(command, "forkexit") == 0)
        process_setup(1, 5);
    else
        for (pid_t i = 1; i <= 4; ++i)
            process_setup(i, i - 1);

    //make kernel memory safe
	virtual_memory_map(kernel_pagetable,0,0,0x100000,PTE_P|PTE_W );
	virtual_memory_map(kernel_pagetable, (uintptr_t) console, 
        (uintptr_t) console, PAGESIZE, PTE_P | PTE_W | PTE_U);
    virtual_memory_map(kernel_pagetable,0,0,PAGESIZE,0); // make null ptrs fault

    // Switch to the first process using run()
    run(&processes[1]);
}

// int find_open_page()
// returns page number of first open page found

int find_open_page() {
    int pn;
    for (pn = 0; pn < NPAGES && pageinfo[pn].refcount != 0; pn++);
    
    if (pn == NPAGES)
        return -1;
    else
        return pn;
}


// process_setup(pid, program_number)
//    Load application program `program_number` as process number `pid`.
//    This loads the application's code and data into memory, sets its
//    %eip and %esp, gives it a stack page, and marks it as runnable.

void process_setup(pid_t pid, int program_number) {
    process_init(&processes[pid], 0);

    processes[pid].p_pagetable = copy_pagetable(kernel_pagetable, pid);

    pageinfo[PAGENUMBER(processes[pid].p_pagetable)].refcount = 1;

	
	int r = program_load(&processes[pid], program_number);
    assert(r >= 0);
    processes[pid].p_registers.reg_esp = MEMSIZE_VIRTUAL;
    uintptr_t stack_page = PAGEADDRESS(find_open_page());
    physical_page_alloc(stack_page, pid);
    virtual_memory_map(processes[pid].p_pagetable, MEMSIZE_VIRTUAL-PAGESIZE, stack_page,
                       PAGESIZE, PTE_P|PTE_W|PTE_U);

    virtual_memory_map(processes[pid].p_pagetable, (uintptr_t) console, (uintptr_t) console,
                       PAGESIZE, PTE_P|PTE_W|PTE_U);
    processes[pid].p_state = P_RUNNABLE;
}


// Copy a page table and assign the copy to the process identified by 'owner'
x86_pagetable* copy_pagetable(x86_pagetable* pagetable, int8_t owner) {
	
    x86_pagetable* pl1;
	x86_pagetable* pl2;

	//Find open physical pages and mark them in the pageinfo table 
    
    uintptr_t pa = PAGEADDRESS(find_open_page());
	if (pa == -1)
		return (uintptr_t) 0;
    if (-1 == physical_page_alloc(pa, owner))
		return (uintptr_t) 0;
	pl1 = (x86_pagetable*) pa;

    pa = PAGEADDRESS(find_open_page());
	if (pa == -1)
		return (uintptr_t) 0;
	physical_page_alloc(pa, owner);
    pl2 = (x86_pagetable*) pa;

    // Make sure mem areas are clear (was causing issues)	
    memset(pl1, 0, PAGESIZE);
    memset(pl2, 0, PAGESIZE); 

    // Setup level 1 pagetable
	pl1->entry[0] = (x86_pageentry_t) pl2 | PTE_P | PTE_W | PTE_U;

    // copy pagetable data from old to new	
    for (int j = 0; j < PAGENUMBER(PROC_START_ADDR); j++) {
		vamapping vm = virtual_memory_lookup(pagetable,PAGEADDRESS(j));
        assert(vm.pn < PAGENUMBER(MEMSIZE_PHYSICAL));
		if (vm.pn != -1 && vm.pa != -1) {
			virtual_memory_map(pl1, PAGEADDRESS(j), vm.pa,PAGESIZE, PTE_P | PTE_W);
		}
	}
	return pl1;
}

// return the pid of the first owner found for pagenumber pn. Returns -1 on failure
int reverse_lookup(int rl_pn) {

    if (rl_pn < 1 || rl_pn >= 1024)
        return -1;
    vamapping vm;
    int pid = -1;
    for (int i = 1; i < NPROC && pid == -1; i++) {
        
        for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
            vm = virtual_memory_lookup(current->p_pagetable, va);
            if (vm.pn == rl_pn)
                pid = i;
        }

    }

    return pid;
}

// physical_page_alloc(addr, owner)
//    Allocates the page with physical address `addr` to the given owner.
//    Fails if physical page `addr` was already allocated. Returns 0 on
//    success and -1 on failure. Used by the program loader.

int physical_page_alloc(uintptr_t addr, int8_t owner) {
    if ((addr & 0xFFF) != 0
        || addr >= MEMSIZE_PHYSICAL
        || pageinfo[PAGENUMBER(addr)].refcount != 0)
        return -1;
    else {
        pageinfo[PAGENUMBER(addr)].refcount = 1;
        pageinfo[PAGENUMBER(addr)].owner = owner;
        return 0;
    }
}



// exception(reg)
//    Exception handler (for interrupts, traps, and faults).
//
//    The register values from exception time are stored in `reg`.
//    The processor responds to an exception by saving application state on
//    the kernel's stack, then jumping to kernel assembly code (in
//    k-exception.S). That code saves more registers on the kernel's stack,
//    then calls exception().
//
//    Note that hardware interrupts are disabled whenever the kernel is running.

void exception(x86_registers* reg) {
    // Copy the saved registers into the `current` process descriptor
    // and always use the kernel's page table.
    current->p_registers = *reg;
    set_pagetable(kernel_pagetable);

    // It can be useful to log events using `log_printf`.
    // Events logged this way are stored in the host's `log.txt` file.
    /*log_printf("proc %d: exception %d\n", current->p_pid, reg->reg_intno);*/

    // Show the current cursor location and memory state.
    console_show_cursor(cursorpos);
    virtual_memory_check();
    memshow_physical();
    memshow_virtual_animate();

    // If Control-C was typed, exit the virtual machine.
    check_keyboard();


    // Actually handle the exception.
    switch (reg->reg_intno) {

    case INT_SYS_PANIC:
        panic(NULL);
        break;                  // will not be reached

    case INT_SYS_GETPID:
        current->p_registers.reg_eax = current->p_pid;
        break;

    case INT_SYS_YIELD:
        schedule();
        break;                  /* will not be reached */

    case INT_SYS_PAGE_ALLOC: {
        int pagen;
        for (pagen = 0; pagen < NPAGES && pageinfo[pagen].refcount !=0;pagen++) 
        if (pagen == NPAGES - 1) {
            current->p_registers.reg_eax = -1;
            console_printf(CPOS(24,0), 0x0700, "OUT OF PHYSICAL MEMORY\n");
            break;
        }

        uintptr_t addr = PAGEADDRESS(pagen);

        uintptr_t v_addr = current->p_registers.reg_eax;
        int r = physical_page_alloc(addr, current->p_pid);
        if (r >= 0 && v_addr >= PROC_START_ADDR)
            virtual_memory_map(current->p_pagetable, v_addr, addr,
                               PAGESIZE, PTE_P|PTE_W|PTE_U);
        current->p_registers.reg_eax = r;
        break;
    }

    case INT_TIMER:
        ++ticks;
        schedule();
        break;                  /* will not be reached */

    case INT_PAGEFAULT: {
        // Analyze faulting address and access type.
        uintptr_t addr = rcr2();
        const char* operation = reg->reg_err & PFERR_WRITE
                ? "write" : "read";
        const char* problem = reg->reg_err & PFERR_PRESENT
                ? "protection problem" : "missing page";

        if (!(reg->reg_err & PFERR_USER))
            panic("Kernel page fault for 0x%08X (%s %s, eip=%p)!\n",
                  addr, operation, problem, reg->reg_eip);
        console_printf(CPOS(24, 0), 0x0C00,
                       "Process %d page fault for 0x%08X (%s %s, eip=%p)!\n",
                       current->p_pid, addr, operation, problem, reg->reg_eip);
		log_printf("pagefault\n");
        current->p_state = P_BROKEN;
        break;
    }

    case INT_SYS_FORK: {
        //find open process slot
        int npid;
        for (npid = 1; npid < NPROC && processes[npid].p_state != P_FREE; ++npid);
        
        // no open process slots
        if (npid == NPROC) {
			log_printf("no open process slots\n");
            current->p_registers.reg_eax = -1;
            break;
        }
		
		log_printf("forking process: %d forked process: %d \n",current->p_pid ,npid);
     		
		if (find_open_page() == -1) {
			log_printf("no open pages\n");

		current->p_registers.reg_eax = -1;
		break;

}
		 
        // set up processes array 
		processes[npid].p_state = P_RUNNABLE;
        processes[npid].p_registers = current->p_registers;
        processes[npid].p_pagetable = copy_pagetable(current->p_pagetable, npid);
		if (processes[npid].p_pagetable == 0 ) { //|| find_open_page() == -1) {
			log_printf("page table creation failed for %d\n", npid);
			current->p_registers.reg_eax = -1;
			processes[npid].p_registers.reg_eax = -1;
			processes[npid].p_state = P_FREE;
			break;
		}
        processes[npid].p_registers.reg_eax = 0;
        current->p_registers.reg_eax = npid;

        vamapping vm;

        // copy memory from parent to child
        for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
            vm = virtual_memory_lookup(current->p_pagetable, va);
            // handle shared/read only memory
            if (((vm.perm & (PTE_U|PTE_W|PTE_P)) == (PTE_U | PTE_P)) && 
                    (pageinfo[vm.pn].refcount > 0 && pageinfo[vm.pn].owner > 0)) {
                virtual_memory_map(processes[npid].p_pagetable,va,vm.pa,PAGESIZE,vm.perm);
                pageinfo[vm.pn].refcount++;
            // handle writable memory
            } else if (vm.perm & PTE_U && vm.pa != (uintptr_t) console) {
                uintptr_t naddr = PAGEADDRESS(find_open_page());
                int r = physical_page_alloc(naddr, npid);
				if (r == -1) {
					log_printf("alloc failed");
					current->p_registers.reg_eax = -1;
        			processes[npid].p_registers.reg_eax = -1;
					break;
				}
					
                memcpy((void *) naddr,(const void *) vm.pa, PAGESIZE);
                virtual_memory_map(processes[npid].p_pagetable,va,naddr,PAGESIZE,vm.perm);
               	 
            }

        }	
        
        
        virtual_memory_map(processes[npid].p_pagetable,
		(uintptr_t) console,(uintptr_t) console,PAGESIZE,vm.perm);

		assert(processes[npid].p_pagetable != 0);
		assert(current->p_pagetable != 0);
		log_printf("finished fork\n");	
        break;
    }

    case INT_SYS_EXIT: {
       // Walk through all virtual memory mappings, unmark the physical pages & decrement
       // refcount. Dont mess with the pagetables until last. If refcount > 0 after 
       // decrement, find new owner and assign. Fix process array.
       //
        vamapping vm;

        int pn_pt1 = PAGENUMBER(current->p_pagetable);
        int pn_pt2 = PAGENUMBER(current->p_pagetable->entry[0]);

        log_printf("%d called exit. p1 = %p pn = %d \n", current->p_pid,PAGEADDRESS(pn_pt1),pn_pt1);
        for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
            vm = virtual_memory_lookup(current->p_pagetable, va);
			if (vm.perm & (PTE_P ) && pageinfo[vm.pn].owner == current->p_pid ) {
                int rf = --pageinfo[vm.pn].refcount;
                if (rf) { 
                    pageinfo[vm.pn].owner = reverse_lookup(vm.pn);
					assert(pageinfo[vm.pn].owner != current->p_pid);
                } else 
                    pageinfo[vm.pn].owner = 0;
            }
        }
        if (pn_pt1){
            pageinfo[pn_pt1] = (physical_pageinfo) {0,0};
		}
		if (pn_pt2)
            pageinfo[pn_pt2] = (physical_pageinfo) {0,0}; 
        
        for (int pagen = 1; pagen < NPAGES ;pagen++) {
			if (pageinfo[pagen].owner == current->p_pid)
				pageinfo[pagen] = (physical_pageinfo) {0,0};
		} 

        processes[current->p_pid].p_state = P_FREE;
		processes[current->p_pid].p_pagetable = (x86_pagetable *) 0;
		break;    
    }


    default:
        panic("Unexpected exception %d!\n", reg->reg_intno);
        break;                  /* will not be reached */

    }

    // Return to the current process (or run something else).
    if (current->p_state == P_RUNNABLE)
        run(current);
    else
        schedule();
}


// schedule
//    Pick the next process to run and then run it.
//    If there are no runnable processes, spins forever.

void schedule(void) {
    pid_t pid = current->p_pid;
    while (1) {
        pid = (pid + 1) % NPROC;
        if (processes[pid].p_state == P_RUNNABLE)
            run(&processes[pid]);
        // If Control-C was typed, exit the virtual machine.
        check_keyboard();
    }
}


// run(p)
//    Run process `p`. This means reloading all the registers from
//    `p->p_registers` using the `popal`, `popl`, and `iret` instructions.
//
//    As a side effect, sets `current = p`.

void run(proc* p) {
    assert(p->p_state == P_RUNNABLE);
    current = p;

    set_pagetable(p->p_pagetable);
    asm volatile("movl %0,%%esp\n\t"
                 "popal\n\t"
                 "popl %%es\n\t"
                 "popl %%ds\n\t"
                 "addl $8, %%esp\n\t"
                 "iret"
                 :
                 : "g" (&p->p_registers)
                 : "memory");

 spinloop: goto spinloop;       // should never get here
}


// pageinfo_init
//    Initialize the `pageinfo[]` array.

void pageinfo_init(void) {
    extern char end[];

    for (uintptr_t addr = 0; addr < MEMSIZE_PHYSICAL; addr += PAGESIZE) {
        int owner;
        if (physical_memory_isreserved(addr))
            owner = PO_RESERVED;
        else if ((addr >= KERNEL_START_ADDR && addr < (uintptr_t) end)
                 || addr == KERNEL_STACK_TOP - PAGESIZE)
            owner = PO_KERNEL;
        else
            owner = PO_FREE;
        pageinfo[PAGENUMBER(addr)].owner = owner;
        pageinfo[PAGENUMBER(addr)].refcount = (owner != PO_FREE);
    }
}


// virtual_memory_check
//    Check operating system invariants about virtual memory. Panic if any
//    of the invariants are false.

void virtual_memory_check(void) {
    // Process 0 must never be used.
    assert(processes[0].p_state == P_FREE);

    // The kernel page table should be owned by the kernel;
    // its reference count should equal 1, plus the number of processes
    // that don't have their own page tables.
    // Active processes have their own page tables. A process page table
    // should be owned by that process and have reference count 1.
    // All level-2 page tables must have reference count 1.

    // Calculate expected kernel refcount
    int expected_kernel_refcount = 1;
    for (int pid = 0; pid < NPROC; ++pid)
        if (processes[pid].p_state != P_FREE
            && processes[pid].p_pagetable == kernel_pagetable)
            ++expected_kernel_refcount;

    for (int pid = -1; pid < NPROC; ++pid) {
        if (pid >= 0 && processes[pid].p_state == P_FREE)
            continue;

        x86_pagetable* pagetable;
        int expected_owner, expected_refcount;
        if (pid < 0 || processes[pid].p_pagetable == kernel_pagetable) {
            pagetable = kernel_pagetable;
            expected_owner = PO_KERNEL;
            expected_refcount = expected_kernel_refcount;
        } else {
            pagetable = processes[pid].p_pagetable;
            expected_owner = pid;
            expected_refcount = 1;
        }
if (pageinfo[PAGENUMBER(pagetable)].owner != expected_owner) {
		log_printf("refcount: %d expected refcount: %d expected owner: %d current pid: %d owner: %d page: %d\n", 
			pageinfo[PAGENUMBER(pagetable)].refcount, 
			expected_refcount, expected_owner, pid, pageinfo[PAGENUMBER(pagetable)].owner,
			PAGENUMBER(pagetable)); }
        // Check main (level-1) page table
        assert(PTE_ADDR(pagetable) == (uintptr_t) pagetable);
        assert(PAGENUMBER(pagetable) < NPAGES);
        assert(pageinfo[PAGENUMBER(pagetable)].owner == expected_owner);
        assert(pageinfo[PAGENUMBER(pagetable)].refcount == expected_refcount);

        // Check level-2 page tables
        for (int pn = 0; pn < PAGETABLE_NENTRIES; ++pn)
            if (pagetable->entry[pn] & PTE_P) {
                x86_pageentry_t pte = pagetable->entry[pn];
                assert(PAGENUMBER(pte) < NPAGES);
                assert(pageinfo[PAGENUMBER(pte)].owner == expected_owner);
                assert(pageinfo[PAGENUMBER(pte)].refcount == 1);
            }
    }

    // Check that all referenced pages refer to active processes
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn)
        if (pageinfo[pn].refcount > 0 && pageinfo[pn].owner >= 0) {
			if (processes[pageinfo[pn].owner].p_state == P_FREE)
				log_printf("refcount: %d current pid: %d owner: %d page: %d\n",
				 	pageinfo[pn].refcount,  current->p_pid, 
					pageinfo[pn].owner,pn);
            assert(processes[pageinfo[pn].owner].p_state != P_FREE);
		}
}


// memshow_physical
//    Draw a picture of physical memory on the CGA console.

static const uint16_t memstate_colors[] = {
    'K' | 0x0D00, 'R' | 0x0700, '.' | 0x0700, '1' | 0x0C00,
    '2' | 0x0A00, '3' | 0x0900, '4' | 0x0E00, '5' | 0x0F00,
    '6' | 0x0C00, '7' | 0x0A00, '8' | 0x0900, '9' | 0x0E00,
    'A' | 0x0F00, 'B' | 0x0C00, 'C' | 0x0A00, 'D' | 0x0900,
    'E' | 0x0E00, 'F' | 0x0F00
};

void memshow_physical(void) {
    console_printf(CPOS(0, 32), 0x0F00, "PHYSICAL MEMORY");
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn) {
        if (pn % 64 == 0)
            console_printf(CPOS(1 + pn / 64, 3), 0x0F00, "0x%06X ", pn << 12);

        int owner = pageinfo[pn].owner;
        if (pageinfo[pn].refcount == 0)
            owner = PO_FREE;
        uint16_t color = memstate_colors[owner - PO_KERNEL];
        // darker color for shared pages
        if (pageinfo[pn].refcount > 1)
            color &= 0x77FF;

        console[CPOS(1 + pn / 64, 12 + pn % 64)] = color;
    }
}


// memshow_virtual(pagetable, name)
//    Draw a picture of the virtual memory map `pagetable` (named `name`) on
//    the CGA console.

void memshow_virtual(x86_pagetable* pagetable, const char* name) {
    assert((uintptr_t) pagetable == PTE_ADDR(pagetable));

    console_printf(CPOS(10, 26), 0x0F00, "VIRTUAL ADDRESS SPACE FOR %s", name);
    for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
        vamapping vam = virtual_memory_lookup(pagetable, va);
        uint16_t color;
        if (vam.pn < 0)
            color = ' ';
        else {
            assert(vam.pa < MEMSIZE_PHYSICAL);
            int owner = pageinfo[vam.pn].owner;
            if (pageinfo[vam.pn].refcount == 0)
                owner = PO_FREE;
            color = memstate_colors[owner - PO_KERNEL];
            // reverse video for user-accessible pages
            if (vam.perm & PTE_U)
                color = ((color & 0x0F00) << 4) | ((color & 0xF000) >> 4)
                    | (color & 0x00FF);
            // darker color for shared pages
            if (pageinfo[vam.pn].refcount > 1)
                color &= 0x77FF;
        }
        uint32_t pn = PAGENUMBER(va);
        if (pn % 64 == 0)
            console_printf(CPOS(11 + pn / 64, 3), 0x0F00, "0x%06X ", va);
        console[CPOS(11 + pn / 64, 12 + pn % 64)] = color;
    }
}


// memshow_virtual_animate
//    Draw a picture of process virtual memory maps on the CGA console.
//    Starts with process 1, then switches to a new process every 0.25 sec.

void memshow_virtual_animate(void) {
    static unsigned last_ticks = 0;
    static int showing = 1;

    // switch to a new process every 0.25 sec
    if (last_ticks == 0 || ticks - last_ticks >= HZ / 2) {
        last_ticks = ticks;
        ++showing;
    }

    // the current process may have died -- don't display it if so
    while (showing <= 2*NPROC && processes[showing % NPROC].p_state == P_FREE)
        ++showing;
    showing = showing % NPROC;

    if (processes[showing].p_state != P_FREE) {
        char s[4];
        snprintf(s, 4, "%d ", showing);
        memshow_virtual(processes[showing].p_pagetable, s);
    }
}
