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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <gc.h>
#include "xalloc.h"

#ifdef OBJECT_COUNT
long sa_count;
long ha_count;
#endif

#ifdef MEMORY_ALLOC_CHECK

void* xmalloc(size_t s) {
    void *ptr = GC_MALLOC(s);
    if (!ptr) {
        perror("xmalloc");
        exit(1);
    }
    return ptr;
}

void* xmalloc_atomic(size_t s) {
    void *ptr = GC_MALLOC_ATOMIC(s);
    if (!ptr) {
        perror("xmalloc_atomic");
        exit(1);
    }
    return ptr;
}

void* xcalloc(int n, size_t s) {
    void *ptr = GC_MALLOC(n * s);
    if (!ptr) {
        perror("xcalloc");
        exit(1);
    }
    return memset(ptr, '\0', s);
}

void* xrealloc(void *ptr, size_t s) {
    ptr = GC_REALLOC(ptr, s);
    if (!ptr) {
        perror("realloc");
        exit(1);
    }
    return ptr;
}

void xfree(void *ptr) {
  GC_FREE(ptr);
}

#endif
