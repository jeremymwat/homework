#include "io61.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <limits.h>
#include <errno.h>
#include <sys/mman.h>

#define CACHESIZE 16384
#define NDEBUG
#include <assert.h>

// io61.c
//    YOUR CODE HERE!

// io61_file
//    Data structure for io61 file wrappers. Add your own stuff.

struct io61_file {
	char cache[CACHESIZE];
	int fd;
	int index; 
	int fmode;
	char* mapped;
	size_t size;
	off_t filepos;
	off_t filesize;
};


// io61_fdopen(fd, mode)
//    Return a new io61_file that reads from and/or writes to the given
//    file descriptor `fd`. `mode` is either O_RDONLY for a read-only file
//    or O_WRONLY for a write-only file. You need not support read/write
//    files.

io61_file* io61_fdopen(int fd, int mode) {

	assert(fd >= 0);

	io61_file* f = (io61_file*) malloc(sizeof(io61_file));
	f->fd = fd;

	f->index = 0, f->filepos = 0; f->fmode = mode; 
	f->filesize = io61_filesize(f); 


	assert(f->fmode == O_WRONLY || f->fmode == O_RDONLY);    

	// Test for mmap capability, if not set filepos as a flag value for warming cache
	if (mode == O_RDONLY && f->filesize > 0) {
		f->mapped = mmap(NULL, f->filesize, PROT_READ, MAP_SHARED, f->fd, 0);
		} else { 
			f->mapped = MAP_FAILED;
			f->filepos = -1; 
		} 

	return f;
}


// io61_close(f)
//    Close the io61_file `f` and release all its resources, including
//    any buffers.

int io61_close(io61_file* f) {
	io61_flush(f);
	if (f->mapped != MAP_FAILED) {
		munmap((char *) f->mapped, f->filesize);
	}
	int r = close(f->fd);
	free(f);
	return r;
}


// io61_readc(f)
//    Read a single (unsigned) character from `f` and return it. Returns EOF
//    (which is -1) on error or end-of-file.

int io61_readc(io61_file* f) {

	unsigned char buf[1];
	if (io61_read(f, (char *) buf, 1) == 1)
		return buf[0];
	else
		return EOF;
}


// io61_read(f, buf, sz)
//    Read up to `sz` characters from `f` into `buf`. Returns the number of
//    characters read on success; normally this is `sz`. Returns a short
//    count if the file ended before `sz` characters could be read. Returns
//    -1 an error occurred before any characters were read.

ssize_t io61_read(io61_file* f, char* buf, size_t sz) {
	// Get read from cache, check for cache size vs request, handle
	// larger request if larger than cache and possibly larger than valid read
	///* 


	if (sz == 0) return 0;

	if (f->filepos == -1 ) { // cache warming
		f->filepos = 0; 
		f->size = read(f->fd, f->cache, CACHESIZE);   

	}

	// Memory mapped IO
	if (f->mapped != MAP_FAILED && f->mapped != 0) {

		if (f->filepos >= f->filesize) {

			return EOF;
		}
		off_t end_pos = f->filepos + sz;
		if (end_pos >= f->filesize) {
			size_t writable = sz - (end_pos - f->filesize);
			memcpy(buf, f->mapped + f->filepos, writable);
			f->filepos = f->filesize;
			return writable;
		}
		memcpy(buf, f->mapped + f->filepos, sz);
		f->filepos += sz;
		return sz;
	}


	// If memory mapping failed, single slot cache


	int bytes_read = 0;

	int extra_read = sz - (f->size - f->index);


	// read stays within cache case
	//	if (extra_read != sz) {
	if (extra_read < 1 ) { 
		memcpy(buf, (void *) (f->cache + f->index), sz);
		f->index += sz;
		f->filepos += sz; // maintain file position indicator
		return sz;
	} else if (extra_read >= 1 && f->size < CACHESIZE) { // file smaller than cache, but read larger
		int avail = f->size - f->index;
		if (avail <= 0) return 0;
		memcpy(buf, (char *) (f->cache + f->index), avail);
		f->index = f->size;
		f->filepos += avail;
		return avail;
	} else {	// reading larger than cache
		assert(sz - extra_read < sz);
		memcpy(buf, (void *) (f->cache + f->index), sz-extra_read); // copy remaining cache
		f->size = read(f->fd, f->cache, CACHESIZE); // read in next portion to cache
		f->index = 0; // reset index
		bytes_read =+ sz - extra_read;
		f->filepos += bytes_read; // recursive call will keep this correct
		return bytes_read + io61_read(f, buf + bytes_read, extra_read);

		return -1;
	}

}


// io61_writec(f)
//    Write a single character `ch` to `f`. Returns 0 on success or
//    -1 on error.

int io61_writec(io61_file* f, int ch) {

	return io61_write(f, (const char *) &ch, 1);
}


// io61_write(f, buf, sz)
//    Write `sz` characters from `buf` to `f`. Returns the number of
//    characters written on success; normally this is `sz`. Returns -1 if
//    an error occurred before any characters were written.

ssize_t io61_write(io61_file* f, const char* buf, size_t sz) {

	if (f->index + sz <= CACHESIZE) { // Write can fit in cache

		assert(f->index <= CACHESIZE);

		memcpy(&(f->cache[f->index]), buf, sz);
		f->index += sz;
		f->filepos += sz;

		assert(f->index <= CACHESIZE);
		return sz;
	} else { // Write is larger than cache
		size_t avail_cache = CACHESIZE - f->index;
		size_t new_cache = sz - avail_cache;

		//
		assert(f->index <= CACHESIZE);
		assert(avail_cache <= CACHESIZE);
		//

		memcpy(&(f->cache[f->index]), buf, avail_cache);
		size_t ret = write(f->fd, f->cache, CACHESIZE);

		assert(ret == CACHESIZE);
		assert(f->index + avail_cache == CACHESIZE);

		f->index = 0;
		f->filepos += avail_cache;
		return ret + io61_write(f, buf + avail_cache, new_cache);
	}

}


// io61_flush(f)
//    Forces a write of all buffered data written to `f`.
//    If `f` was opened read-only, io61_flush(f) may either drop all
//    data buffered for reading, or do nothing.

int io61_flush(io61_file* f) {

	if (f->fmode == O_RDONLY)
		return 0;
	if (f->index == write(f->fd, f->cache, f->index)) {
		f->index = 0;
		return 0; 
	}
	else 
		return -1;
	return 0;
}

// Small helper to avoid copy pasting in io61_seek function
int io61_seekhelper(io61_file* f, off_t pos) {

	off_t r = lseek(f->fd, (off_t) pos, SEEK_SET);
	if (r == (off_t) pos) 
		return 0;
	else
		return -1;

}


// io61_seek(f, pos)
//    Change the file pointer for file `f` to `pos` bytes into the file.
//    Returns 0 on success and -1 on failure.

int io61_seek(io61_file* f, off_t pos) {

	if (f->mapped != MAP_FAILED && f->mapped != 0) {
		io61_flush(f);    
		f->filepos = pos;
		return 0;
	}


	if (f->fmode != O_RDONLY || f->mapped != MAP_FAILED)
		io61_flush(f); // Ensure writes go the correct place in the file before seeking  
	else {
		off_t rel_pos = pos - f->filepos;
		int halfcache = CACHESIZE / 2;

		// On seek, cache is placed so filepos is in the middle of the cache
		// for reverse read performance

		if (f->index + rel_pos >= CACHESIZE || f->index + rel_pos < 0) {// seek out of cache

			if (pos - (CACHESIZE / 2) < 0) { // near beginning of file

				int ret = io61_seekhelper(f, 0);
				f->index = pos;
				f->filepos = pos;
				f->size =  read(f->fd, f->cache, CACHESIZE);
				return ret;

			} else { 

				int ret = io61_seekhelper(f, pos -  halfcache);
				f->size = read(f->fd, f->cache, CACHESIZE);
				f->index = halfcache;
				f->filepos = pos;
				return ret;

			}

		} else { // seek within cache
			f->index += rel_pos;
			f->filepos = pos;
			return 0;
		}

	}


	off_t r = lseek(f->fd, (off_t) pos, SEEK_SET);
	if (r == (off_t) pos) {
		f->filepos = r;
		return 0;
	} else
		return -1;
}


// You shouldn't need to change these functions.

// io61_open_check(filename, mode)
//    Open the file corresponding to `filename` and return its io61_file.
//    If `filename == NULL`, returns either the standard input or the
//    standard output, depending on `mode`. Exits with an error message if
//    `filename != NULL` and the named file cannot be opened.

io61_file* io61_open_check(const char* filename, int mode) {
	int fd;
	if (filename)
		fd = open(filename, mode, 0666);
	else if ((mode & O_ACCMODE) == O_RDONLY)
		fd = STDIN_FILENO;
	else
		fd = STDOUT_FILENO;
	if (fd < 0) {
		fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		exit(1);
	}
	return io61_fdopen(fd, mode & O_ACCMODE);
}


// io61_filesize(f)
//    Return the size of `f` in bytes. Returns -1 if `f` does not have a
//    well-defined size (for instance, if it is a pipe).

off_t io61_filesize(io61_file* f) {
	struct stat s;
	int r = fstat(f->fd, &s);
	if (r >= 0 && S_ISREG(s.st_mode))
		return s.st_size;
	else
		return -1;
}


// io61_eof(f)
//    Test if readable file `f` is at end-of-file. Should only be called
//    immediately after a `read` call that returned 0 or -1.

int io61_eof(io61_file* f) {
	char x;
	ssize_t nread = read(f->fd, &x, 1);
	if (nread == 1) {
		fprintf(stderr, "Error: io61_eof called improperly\n\
				(Only call immediately after a read() that returned 0 or -1.)\n");
		abort();
	}
	return nread == 0;
}
