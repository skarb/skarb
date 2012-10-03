#ifndef XALLOC_H_
#define XALLOC_H_

#include <stdlib.h>
#include <gc.h>

#ifndef alloca
#define alloca(x) __builtin_alloca(x)
#endif

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

/*******************************************************************************
(C) 2010-2012 Jan Stępień, Julian Zubek

This file is a part of Skarb -- Ruby to C compiler.

Skarb is free software: you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with Skarb. If not, see <http://www.gnu.org/licenses/>.

*******************************************************************************/
