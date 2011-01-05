#include <stdlib.h>
#include <glib.h>
#include "blocks.h"

typedef Object* (*block_t)(Object*);

/**
 * The blocks' stack.
 */
static GList *blocks = NULL;

void push_block(block_t block) {
    blocks = g_list_prepend(blocks, block);
}

void pop_block() {
    blocks = blocks->next;
    if (blocks)
        blocks->prev = NULL;
}

block_t get_block() {
    if (!blocks)
        return NULL;
    return blocks->data;
}
