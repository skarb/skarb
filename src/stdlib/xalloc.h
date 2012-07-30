#ifndef XALLOC_H_
#define XALLOC_H_

#include <stdlib.h>
#include <gc.h>

#ifndef MEMORY_ALLOC_CHECK

#define xmalloc(x) GC_MALLOC(x)
#define xmalloc_atomic(x) GC_MALLOC_ATOMIC(x)
#define xcalloc(n, x) GC_MALLOC((n)*(x))
#define xrealloc(ptr, x) GC_REALLOC(ptr, x)
#define xfree(ptr) GC_FREE(ptr)

#else
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
#endif

#define SMALLOC_LIMIT 30

#define SMALLOC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     alloca(x) : xmalloc(x))

#define SMALLOC_ATOMIC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     alloca(x) : xmalloc_atomic(x))

#endif /* XALLOC_H_ */
