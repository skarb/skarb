#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef HAVE_GC_H
#include <gc.h>
#elif HAVE_GC_GC_H
#include <gc/gc.h>
#endif /* HAVE_GC_H */

#include "xalloc.h"

void* xmalloc(size_t s) {
    void *ptr = GC_MALLOC(s);
    if (!ptr) {
        perror("xmalloc");
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
