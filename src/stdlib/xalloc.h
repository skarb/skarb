#ifndef XALLOC_H_
#define XALLOC_H_

#include <stdlib.h>

/**
 * Error checking malloc. In case of errors it calls exit(1).
 */
void* xmalloc(size_t size);

/**
 * Error checking malloc. It uses GC_MALLOC_ATOMIC, so the memory it allocates
 * cannot store any pointers. In case of errors it calls exit(1).
 */
void* xmalloc_atomic(size_t size);

/**
 * Error checking calloc. In case of errors it calls exit(1).
 */
void* xcalloc(int nmemb, size_t size);

/**
 * Error checking realloc. In case of errors it calls exit(1).
 */
void* xrealloc(void *ptr, size_t size);

/**
 * A wrapper around the GC_FREE macro.
 */
void xfree(void *ptr);

#endif /* XALLOC_H_ */
