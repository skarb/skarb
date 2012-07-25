#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <gc.h>
#include "xalloc.h"

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
