#ifndef BLOCKS_H_
#define BLOCKS_H_

#include "object.h"

/**
 * Sets the current block. It is used before calling a function which expects a
 * block. It's extremely thread-unsafe, as the rest of the current blocks
 * implementation.
 */
void set_block(Object* (*block)(Object*));

/**
 * Unsets the current block by setting it to NULL. It should be called after a
 * function call preceded by a call to set_block.
 */
void unset_block();

/**
 * Returns the current block set by set_block. It should be used inside a
 * function which expects a block.
 */
Object* (*get_block())(Object*);

#endif /* BLOCKS_H_ */
