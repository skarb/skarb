#ifndef BLOCKS_H_
#define BLOCKS_H_

#include "object.h"

/**
 * Sets the current block by putting it on top of the blocks' stack. It is
 * used before calling a function which expects a block. It's extremely
 * thread-unsafe, as the rest of the current blocks implementation.
 */
void push_block(Object* (*block)(Object*));

/**
 * Removes the topmost block from the blocks' stack. It should be called after a
 * function call preceded by a call to push_block.
 */
void pop_block();

/**
 * Returns the topmost block set by push_block. It should be used inside a
 * function which expects a block. If no block has been set NULL is returned.
 */
Object* (*get_block())(Object*);

#endif /* BLOCKS_H_ */
