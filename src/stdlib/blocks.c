#include <stdlib.h>
#include "blocks.h"

typedef Object* (*block_t)(Object*);

/**
 * The current block.
 */
static block_t current_block;

void set_block(block_t block) {
    current_block = block;
}

void unset_block() {
    current_block = NULL;
}

block_t get_block() {
    return current_block;
}
