#include "sh61.h"
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/wait.h>

#define PIPE_READ 0 // for clarity / sanity
#define PIPE_WRITE 1

// struct command
//    Data structure describing a command. Add your own stuff.

typedef struct command command;
struct command {
    int argc;      // number of arguments
    char** argv;   // arguments, terminated by NULL
    pid_t pid;     // process ID running this command, -1 if none
    pid_t child_pid; // pid of last child this process forked
    int bg;        // 1 if running in background, 0 otherwise
    command* next; // linked list
    command* prev; // ibid
    int ctoken;    // token associated with command
    int fd[2];
    char redir;
    int pgid;
};

command* head;
command* tail;

//function definitions
static void command_free(command* c);
pid_t start_command(command* c, pid_t pgid);

sig_atomic_t interrupted = 0;

void handler(int signal) {
    interrupted = signal;
}


// inserts at tail ALWAYS
void insert_command(command* com) {
    com->next = NULL;
    com->prev = tail;
    if (tail)
        tail->next = com;
    else
        head = com;
    tail = com;
}

void remove_command(command* com) {
    if (com->next)
        com->next->prev = com->prev;
    if (com->prev)
        com->prev->next = com->next;
    else
        tail = com->next;
}

void free_command_list(command* com) {
    while (com) {
        command* temp = com;
        com = com->next;
        command_free(temp);
    }
    head = tail = NULL;

}

// command_alloc()
//    Allocate and return a new command structure.

static command* command_alloc(void) {
    command* c = (command*) malloc(sizeof(command));
    c->argc = 0;
    c->argv = NULL;
    c->pid = -1;
    c->bg = 0;
    c->next = c->prev = NULL;
    c->ctoken = 0;
    c->fd[0] = -1; c->fd[1] = -1;
    c->redir = (char) 0;
    c->pgid = 0;
    return c;
}


// command_free(c)
//    Free command structure `c`, including all its words.

static void command_free(command* c) {
    for (int i = 0; i != c->argc; ++i)
        free(c->argv[i]);
    free(c->argv);
    free(c);
}


// command_append_arg(c, word)
//    Add `word` as an argument to command `c`. This increments `c->argc`
//    and augments `c->argv`.

static void command_append_arg(command* c, char* word) {
    c->argv = (char**) realloc(c->argv, sizeof(char*) * (c->argc + 2));
    c->argv[c->argc] = word;
    c->argv[c->argc + 1] = NULL;
    ++c->argc;
}


// COMMAND EVALUATION

// start_command(c, pgid)
//    Start the single command indicated by `c`. Sets `c->pid` to the child
//    process running the command, and returns `c->pid`.
//
//    PART 1: Fork a child process and run the command using `execvp`.
//    PART 5: Set up a pipeline if appropriate. This may require creating a
//       new pipe (`pipe` system call), and/or replacing the child process's
//       standard input/output with parts of the pipe (`dup2` and `close`).
//       Draw pictures!
//    PART 7: Handle redirections.
//    PART 8: The child process should be in the process group `pgid`, or
//       its own process group (if `pgid == 0`). To avoid race conditions,
//       this will require TWO calls to `setpgid`.


// consider refactoring some code here
pid_t start_command(command* c, pid_t pgid) {
    // do nothing on blank line
    if (!c->argv || c->argv[0] == NULL)
        return c->pid;

    int pid;
    // Your code here!

    if (c->ctoken == TOKEN_PIPE) {
        int p = pipe(c->fd);
        if (p == -1) {
            fprintf(stderr, "sh61: bad pipe\n");
            exit(1);
        }
    }

    int is_cd = 0;
    if (!strcmp(c->argv[0],"cd"))
        is_cd = 1;

    // if not changing directory, run command in forked process
    if (!is_cd) {
        pid = fork();
        if (!pgid) {
            setpgid(0, 0); // child set its own process group
            c->pid = getpid();
        } else
            setpgid(pid,pid); // parent set child process group

        if (pid)
            c->child_pid = pid;
    } else {
        c->child_pid = 0;
        pid = getpid();

}

    if (!pid || (pid && is_cd)) {
        int fd;
        // Check for redirections

        // store standard file descriptors to reset main shell
        // descriptors for combination of pipes/redirects and the cd command
        int cd_stdin = dup(0);
        int cd_stdout = dup(1);
        int cd_stderr = dup(2);

        if (c->ctoken == TOKEN_PIPE) {
            dup2(c->fd[PIPE_WRITE],1); // write to pipe`
            close(c->fd[PIPE_WRITE]); // close unused fd
        }
        // If previous command is pipe, modify read to take from pipe
        if (c->prev && c->prev->ctoken == TOKEN_PIPE) { // read end
            // make current in the previous command's pipe read
            dup2(c->prev->fd[PIPE_READ],0);
            close(c->prev->fd[PIPE_READ]);
        }

		// handle redirections
        if (c->redir) {

            for (int i = 0; i < c->argc; i++) {
                // handle redirection type
                char dirchar = c->argv[i][0];

                if (dirchar == '<') {
                    fd = open(c->argv[i+1],O_RDONLY);
                    if (fd == -1) {
                        fprintf(stderr, "%s\n", strerror(errno));
                        exit(errno);
                    }

                    dup2(fd,0);
                    close(fd);
                    c->argv[i] = NULL;

                } else if (dirchar == '>' || (dirchar == '2' &&
											c->argv[i][1] == '>')) {
                    int fd = open(c->argv[i+1],O_WRONLY|O_CREAT, 0666);
                    if (fd == -1) {
                        fprintf(stderr, "%s\n", strerror(errno));
                        exit(errno);
                    }

                    dup2(fd,1);

                    if (dirchar == '>')
                        dup2(fd,1);
                    else
                        dup2(fd,2);
                    close(fd);
                    c->argv[i] = NULL;
                }
            }
        }

        if (is_cd) {
            int cd = chdir(c->argv[1]);
            if (cd == -1) {
                fprintf(stderr, "%s\n", strerror(errno));
                dup2(cd_stderr,2); // TODO fix this fugliness, helper?
                dup2(cd_stdout,1);
                dup2(cd_stdin,0);
                close(cd_stderr);
                close(cd_stdin);
                close(cd_stdout);
                c->child_pid = -1;
                return c->pid;
            } else {
                dup2(cd_stderr,2);
                dup2(cd_stdout,1);
                dup2(cd_stdin,0);
                close(cd_stderr);
                close(cd_stdin);
                close(cd_stdout);
                c->child_pid = 0;
                return c->pid;
            }
        } else if ((execvp(c->argv[0],c->argv)) < 0) {
            fprintf(stderr,"%s : command not found\n",c->argv[0]);
            close(cd_stderr);
            close(cd_stdin);
            close(cd_stdout);
            exit(c->pid);
        } else {
			if (!pid) {
                close(cd_stderr);
                close(cd_stdin);
                close(cd_stdout);
            	exit(c->pid);
                }
		}
    }

    return c->pid;
}


// run_list(c)
//    Run the command list starting at `c`.
//
//    PART 1: Start the single command `c` with `start_command`,
//        and wait for it to finish using `waitpid`.
//    The remaining parts may require that you change `struct command`
//    (e.g., to track whether a command is in the background)
//    and write code in run_list (or in helper functions!).
//    PART 2: Treat background commands differently.
//    PART 3: Introduce a loop to run all commands in the list.
//    PART 4: Change the loop to handle conditionals.
//    PART 5: Change the loop to handle pipelines. Start all processes in
//       the pipeline in parallel. The status of a pipeline is the status of
//       its LAST command.
//    PART 8: - Choose a process group for each pipeline.
//       - Call `set_foreground(pgid)` before waiting for the pipeline.
//       - Call `set_foreground(0)` once the pipeline is complete.
//       - Cancel the list when you detect interruption.

void run_list(command* cl) {
    int status = 0;
    int pid = -1;
    int ppid = getpid(); // set parent shell pid
    cl->pid = ppid;
    cl->pgid = ppid;
    setpgid(ppid,ppid);

    while (cl) {

        cl->pid = getpid();

        // if command starts background chain.
        // fork off, run background, and advance
        // non background list to first non
        // background item
        while (cl && cl->bg && ppid == cl->pid) {

            pid = fork();

            // if not child, advance past first background token found
            if (pid) {
                while (cl && cl->ctoken != TOKEN_BACKGROUND)
                    cl = cl->next;
                if (cl != NULL)
                    cl = cl->next;
                else
                    return;
            } else {	// give child it's pid and group pid
                cl->pid = getpid();
                setpgid(pid, pid);
                cl->pgid = cl->pid;
            }
        }

        // handle pipes

        if (cl && cl->ctoken == TOKEN_PIPE) {
            set_foreground(cl->pgid);
            // run all but last pipe command in parallel
            while (cl && cl->ctoken == TOKEN_PIPE) {
                start_command(cl, cl->pgid);
                close(cl->fd[PIPE_WRITE]);
                cl = cl->next;
            }

            // end of while loop is last commmand in pipe case
            start_command(cl,cl->pgid);
            waitpid(cl->child_pid,&status,0);
        } else if (cl) {
			set_foreground(cl->pgid);
            start_command(cl, cl->pgid);
            waitpid(cl->child_pid,&status,0);
        } else {
			set_foreground(0);
            return;
        }
        set_foreground(0);

        if (interrupted && !cl->bg) {
            cl = NULL;
            return;
        }

		// Main shell ran command, aka change dir case
		// setup for conditionals
        if (cl->child_pid < 0)
            status = errno;


        if ((WIFEXITED(status) || cl->child_pid < 0) && cl) {
            if (cl->ctoken == TOKEN_AND && (WEXITSTATUS(status) || cl->child_pid == -1))
                cl = cl->next;
            if (cl->ctoken == TOKEN_OR && (!WEXITSTATUS(status) && cl->child_pid >= 0))
                cl = cl->next;
        }

        // if in forked child subshell for background,
        // exit if command is not bg command or no more commands
        if (cl && cl->pid != ppid && (!cl || cl->ctoken == TOKEN_BACKGROUND
                                        || cl->ctoken == TOKEN_PIPE))
            exit(status);


        if (cl == NULL)
            return;
        cl = cl->next;

        }

}

void mark() {
    // mark for running in background
    command* c = tail;
    while (c) {
        if (c->bg) {
            while (c && c->ctoken != TOKEN_SEQUENCE) {
                c->bg = 1;
                c = c->prev;
            }
        }
        if (c)
            c = c->prev;
    }
}

//
// eval_line(c)
//    Parse the command list in `s` and run it via `run_list`.

void eval_line(const char* s) {
    int type;
    char* token;
    int ppid = getpid();
    // Your code here!

    // build the command
    command* c = command_alloc();
    head = c;
    while ((s = parse_shell_token(s, &type, &token)) != NULL) {

        if (c == NULL)
            c = command_alloc();

        c->pid = ppid;

        if (type == TOKEN_BACKGROUND)
            c->bg = 1;

        if (type == TOKEN_REDIRECTION && !c->redir)
            c->redir = c->argc;


        if (type > TOKEN_REDIRECTION) {
            c->ctoken = type;
            insert_command(c);
            c = NULL;
            free(token);
        } else
            command_append_arg(c, token);
    }

    if (c != NULL)
        insert_command(c);

    // execute it

    mark();
    if (head->argc)
        run_list(head);
    free_command_list(head);
}


int main(int argc, char* argv[]) {
    FILE* command_file = stdin;
    int quiet = 0;

    handle_signal(SIGINT,handler);


    // Check for '-q' option: be quiet (print no prompts)
    if (argc > 1 && strcmp(argv[1], "-q") == 0) {
        quiet = 1;
        --argc, ++argv;
    }

    // Check for filename option: read commands from file
    if (argc > 1) {
        command_file = fopen(argv[1], "rb");
        if (!command_file) {
            perror(argv[1]);
            exit(1);
        }
    }

    // - Put the shell into the foreground
    // - Ignore the SIGTTOU signal, which is sent when the shell is put back
    //   into the foreground
    set_foreground(0);
    handle_signal(SIGTTOU, SIG_IGN);

    char buf[BUFSIZ];
    int bufpos = 0;
    int needprompt = 1;

    while (!feof(command_file)) {
        // Print the prompt at the beginning of the line
        if (needprompt && !quiet) {
            printf("sh61[%d]$ ", getpid());
            fflush(stdout);
            needprompt = 0;
        }

        // Read a string, checking for error or EOF
		interrupted = 0;
        if (fgets(&buf[bufpos], BUFSIZ - bufpos, command_file) == NULL) {
            if (ferror(command_file) && errno == EINTR) {
                // ignore EINTR errors
                clearerr(command_file);
                buf[bufpos] = 0;
				needprompt = 1;
				fprintf(stderr, "\n" );
            } else {
                if (ferror(command_file))
                    perror("sh61");
                break;
            }
        }

        // If a complete command line has been provided, run it
        bufpos = strlen(buf);
        if (bufpos == BUFSIZ - 1 || (bufpos > 0 && buf[bufpos - 1] == '\n')) {
            eval_line(buf);
            bufpos = 0;
            needprompt = 1;
        }

        // Handle zombie processes and/or interrupt requests
        // Your code here!
        while(waitpid(-1,NULL,WNOHANG) > 0);
    }

    return 0;
}
