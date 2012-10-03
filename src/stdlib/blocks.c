#include <stdlib.h>
#include <glib.h>
#include "blocks.h"

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
