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
