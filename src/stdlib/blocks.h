#ifndef BLOCKS_H_
#define BLOCKS_H_

#include "object.h"

/**
 * A pointer to a function accepting one or more Object pointers and returning a
 * pointer to an Object. Used to represent blocks.
 */
typedef Object* (*block_t)(Object*, ...);

/**
 * Sets the current block by putting it on top of the blocks' stack. It is
 * used before calling a function which expects a block. It's extremely
 * thread-unsafe, as the rest of the current blocks implementation.
 */
void push_block(block_t block);

/**
 * Removes the topmost block from the blocks' stack. It should be called after a
 * function call preceded by a call to push_block.
 */
void pop_block();

/**
 * Returns the topmost block set by push_block. It should be used inside a
 * function which expects a block. If no block has been set NULL is returned.
 */
block_t get_block();

#endif /* BLOCKS_H_ */

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
