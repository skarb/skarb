#ifndef XALLOC_H_
#define XALLOC_H_

#include <stdlib.h>

/**
 * Error checking malloc. In case of errors it calls exit(1).
 */
void* xmalloc(size_t size);

/**
 * Error checking calloc. In case of errors it calls exit(1).
 */
void* xcalloc(int nmemb, size_t size);

/**
 * Error checking realloc. In case of errors it calls exit(1).
 */
void* xrealloc(void *ptr, size_t size);

#endif /* XALLOC_H_ */
