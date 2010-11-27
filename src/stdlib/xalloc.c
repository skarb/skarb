#include <stdlib.h>
#include <stdio.h>
#include "xalloc.h"

void* xmalloc(size_t s) {
    void *ptr = malloc(s);
    if (!ptr) {
        perror("xmalloc");
        exit(1);
    }
    return ptr;
}

void* xcalloc(int n, size_t s) {
    void *ptr = calloc(n, s);
    if (!ptr) {
        perror("xcalloc");
        exit(1);
    }
    return ptr;
}

void* xrealloc(void *ptr, size_t s) {
    ptr = realloc(ptr, s);
    if (!ptr) {
        perror("realloc");
        exit(1);
    }
    return ptr;
}
