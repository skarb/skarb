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
