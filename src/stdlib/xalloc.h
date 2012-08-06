#ifndef XALLOC_H_
#define XALLOC_H_

#include <stdlib.h>
#include <gc.h>

#ifdef OBJECT_COUNT
extern long sa_count;
extern long ha_count;
#endif

#ifndef MEMORY_ALLOC_CHECK

#ifdef OBJECT_COUNT

#define xmalloc(x) ha_count++ ? GC_MALLOC(x) : GC_MALLOC(x)
#define xmalloc_atomic(x) ha_count++ ? GC_MALLOC_ATOMIC(x) : GC_MALLOC_ATOMIC(x)

#else

#define xmalloc(x) GC_MALLOC(x)
#define xmalloc_atomic(x) GC_MALLOC_ATOMIC(x)

#endif

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

#ifdef OBJECT_COUNT

#define SMALLOC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     (sa_count++ ? alloca(x) : alloca(x)) : xmalloc(x))

#define SMALLOC_ATOMIC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     (sa_count++ ? alloca(x) : alloca(x)) : xmalloc_atomic(x))

#else

#define SMALLOC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     alloca(x) : xmalloc(x))

#define SMALLOC_ATOMIC(x) (((_stalloc_bytes < SMALLOC_LIMIT) && (_stalloc_bytes += (x))) ? \
                     alloca(x) : xmalloc_atomic(x))

#endif

#endif /* XALLOC_H_ */
