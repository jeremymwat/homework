#define M61_DISABLE 1
#include "m61.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <inttypes.h>
#include <limits.h>

#define HHARRAY_SIZE 20
#define ACTIVE_FLAG 21987
#define FREED_FLAG 121986
#define FOOTER_CHECK 70797984 // decimal ASCII for FOOT
#define HH_THRESHOLD 10.0 // percent (float) mininum to print in heavy hitter report

// Memory statistics

struct m61_statistics globe_stats = {0,0,0,0,0,0,NULL,NULL};

// footer structure only contains single int to test for wild writes
struct footer {
    int verifyf;
};

// header contains size of alloc, double linked list structure, and file information
struct header {
    unsigned long long alloc_size;
    struct header *next;
    struct header *prev;
    int verifyh;
    struct footer *flocation;
	const char *file_name;
	int line_num;
};

//Heavy hitter statistics

struct hhcounter {
	unsigned long long tot_alloc;
	long long counter;
	const char* file;
	int line;
	
};

struct hhcounter hharray[HHARRAY_SIZE];

struct header *list_end = NULL;

void* m61_malloc(size_t sz, const char* file, int line) {

    (void) file, (void) line;   // avoid uninitialized variable warnings
    // Your code here.
    unsigned long long llsz = (unsigned long long) sz;
     
    void *ptr = malloc(sz + sizeof(struct header) + sizeof(struct footer));

    struct header hdr = {sz,NULL,NULL,ACTIVE_FLAG,ptr + sizeof(hdr) + sz,file,line};
    struct footer ftr = {FOOTER_CHECK};

    // Too large alloc test
    if (llsz + globe_stats.nactive > (unsigned long long) ((size_t) -1)) {  
    	globe_stats.fail_size += llsz;
	    globe_stats.nfail++;
	    return NULL;
    } 

    if (ptr == NULL)  {
        globe_stats.nfail++;
        globe_stats.fail_size += llsz;
        return ptr;
    } else {
        
        if (ptr + sz + sizeof(struct header) >= (void*) globe_stats.heap_max 
                || globe_stats.heap_max == NULL) {
            globe_stats.heap_max = (ptr + sz + sizeof(struct header));  
         }

        if (ptr <= (void *) globe_stats.heap_min || globe_stats.heap_min == NULL) {
            globe_stats.heap_min = ptr + sizeof(struct header);
         }

        // Maintain stats
        globe_stats.nactive++;
        globe_stats.ntotal++;
        globe_stats.total_size += llsz;
        globe_stats.active_size += llsz;

        // Put info in footer/header
        memcpy(ptr, &hdr, sizeof(hdr));
        memcpy(hdr.flocation, &ftr, sizeof(ftr));
    }

    struct header *mptr = ptr; // for convenience to avoid lots of casting

    // Maintain double linked list of mallocs
    if (list_end == NULL) {
        list_end = mptr;
    } else {
        list_end->next = mptr;
        mptr->prev = list_end;
        mptr->next = NULL;
        list_end = mptr;
    }

	// Heavy hitter data, Demaine paper method
	int i = 0;
	int found = 0;
	int zero_loc = -1;
	
	for (int i = 0; i < HHARRAY_SIZE && found == 0; i++) {
		if (hharray[i].file != NULL && (!(strcmp(hharray[i].file,file)) 
				&& hharray[i].line == line)) { // already counting
			hharray[i].tot_alloc += llsz;
			hharray[i].counter += llsz;
			found = 1;
		} else if (zero_loc < 0 && hharray[i].counter < 1) { // checking for open counters
			zero_loc = i;
		}
	}
	
	if (found == 0 && zero_loc >= 0) {
		hharray[zero_loc].tot_alloc = llsz;
		hharray[zero_loc].counter = llsz;
		hharray[zero_loc].file = file;
		hharray[zero_loc].line = line;
	} else if (found == 0 && zero_loc < 0) {
		for (int j = 0; j < HHARRAY_SIZE; j++) 
			hharray[j].counter -= llsz;
	}


	return ((struct header *) ptr + 1);
}

void m61_free(void *ptr, const char *file, int line) {
    (void) file, (void) line;   // avoid uninitialized variable warnings
    // Your code here.

   if (ptr == NULL)
        return;
    
    if (ptr < (void *) globe_stats.heap_min || ptr > (void *) globe_stats.heap_max) {
        printf("MEMORY BUG at %s:%u: invalid free of pointer %p, not in heap\n",
            file,line,ptr);
        abort();
    }
    
    struct header *metadata = (struct header *) ptr - 1;

    // Check if allocation is in linked list, and linked list agrees
	if ((metadata->prev != NULL && (metadata->prev)->next != metadata) 
		|| (metadata->next != NULL && (metadata->next)->prev != metadata)) {
		printf("MEMORY BUG: %s:%u: invalid free of pointer %p, not allocated\n",
            file,line,ptr); 
		abort();

    }
    
    // simple flag check
    if (metadata->verifyh != ACTIVE_FLAG  ) {
    	if (metadata->verifyh == FREED_FLAG ) {			
			printf("MEMORY BUG at %s:%u: invalid free of pointer %p," 
                "double free detected\n",file,line,ptr);
			abort();
		}	
		
        // check for bad free inside an allocation
		struct header *temp = list_end;
		while (temp != NULL) {
			if (ptr > (void *) (temp + 1) 
               && ptr < ((void *) (temp + 1) + (size_t) temp->alloc_size)) {
				unsigned bytes = (unsigned) (ptr - (void *) (temp + 1));
				
				printf("MEMORY BUG: %s:%u: invalid free of pointer %p, not allocated\n",
				temp->file_name, line, ptr);

				printf("  %s:%u: %p is %u bytes inside a %llu byte region allocated here\n", 
					temp->file_name, temp->line_num, ptr, bytes, temp->alloc_size);
				abort();	
			}
			
			temp = temp->prev;
		}

		printf("MEMORY BUG: %s:%u: invalid free of pointer %p, not allocated\n",
		file,line,ptr);
		abort();
    }


	// Simple wild free test
	if (((struct footer *) (ptr + metadata->alloc_size))->verifyf != FOOTER_CHECK) {

		printf("MEMORY BUG: %s:%u: detected wild write during free of pointer %p\n",
		file,line,ptr);
		abort();

	}

	// If the code reaches this point, the free should be successful

    // remove memory from double linked list malloc chain
    if (metadata->next == NULL && metadata->prev == NULL) { // single element case
        list_end = NULL;
    } else if ((metadata->prev) == NULL) { // head of list case
        (metadata->next)->prev = NULL;
    } else if (!(metadata->next)) { // last element case
        (metadata->prev)->next = NULL;
        list_end = metadata->prev;
    } else { // somewhere in the middle case
        (metadata->prev)->next = metadata->next;
        (metadata->next)->prev = metadata->prev;
    }

    // Maintain stats
    globe_stats.nactive--;
    globe_stats.active_size -= metadata->alloc_size;

    metadata->verifyh = FREED_FLAG;
    free((void *) metadata);
}

void* m61_realloc(void* ptr, size_t sz, const char* file, int line) {
    void *new_ptr = NULL;
    if (sz)
        new_ptr = m61_malloc(sz, file, line);
    if (ptr && new_ptr) {
        // Copy the data from `ptr` into `new_ptr`.
        // To do that, we must figure out the size of allocation `ptr`.
        // Your code here (to fix test012).
        
        size_t old_sz = ((struct header *) ptr - 1)->alloc_size;
        if (old_sz < sz) 
            memcpy(new_ptr,ptr,old_sz);
        else 
            memcpy(new_ptr,ptr,sz);
    }
    m61_free(ptr, file, line);
    return new_ptr;
}

void* m61_calloc(size_t nmemb, size_t sz, const char* file, int line) {
    // Your code here (to fix test014).
    if ((size_t) - 1/nmemb < sz) {
        globe_stats.nfail++;
        globe_stats.fail_size += (unsigned long long) sz * (unsigned long long) nmemb;
        return NULL;
    }
    void *ptr = m61_malloc(nmemb * sz, file, line);
    
    if (ptr)
        memset(ptr, 0, nmemb * sz);
    
    return ptr;

}

void m61_getstatistics(struct m61_statistics* stats) {
    // Stub: set all statistics to enormous numbers
    memset(stats, 0, sizeof(struct m61_statistics));
    // Your code here.
    *stats = globe_stats;
}

void m61_printstatistics(void) {
    struct m61_statistics stats;
    m61_getstatistics(&stats);

    printf("malloc count: active %10llu   total %10llu   fail %10llu\n",
           stats.nactive, stats.ntotal, stats.nfail);
    printf("malloc size:  active %10llu   total %10llu   fail %10llu\n",
           stats.active_size, stats.total_size, stats.fail_size);
}

void m61_printleakreport(void) {
	struct header *print_ptr = list_end;

	while (print_ptr) {
		printf("LEAK CHECK: %s:%u: allocated object %p with size %zu\n",
		 print_ptr->file_name, print_ptr->line_num, print_ptr + 1, 
			(size_t) print_ptr->alloc_size);
		print_ptr = print_ptr->prev;
	}

    // Your code here.
}

void m61_getheavyhitter(struct hhcounter* hh) {
	memset(hh, 0, sizeof(struct hhcounter) * HHARRAY_SIZE);
	for (int l = 0; l < HHARRAY_SIZE; l++)
		hh[l] = hharray[l];
}

void m61_heavyhitter(void) {
		// My code here
	struct hhcounter parray[HHARRAY_SIZE];
	m61_getheavyhitter(parray);	
	
	for (int k = 0; k < HHARRAY_SIZE; k++) {
		if (parray[k].file != NULL) {
			float palloc = (float) hharray[k].tot_alloc / 
                ((float) globe_stats.total_size / 100.0);
            if (palloc >= HH_THRESHOLD)    
             printf("Heavy Hitter: %s:%u: %llu bytes (~%.2f%%)\n",
             hharray[k].file,hharray[k].line, hharray[k].tot_alloc, palloc);
            
        }
    }
}

