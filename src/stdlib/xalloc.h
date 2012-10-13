/*
 * Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
 *
 * This file is a part of Skarb -- a Ruby to C compiler.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
