#ifndef HASH_H_
#define HASH_H_

#include "object.h"
#include "class.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GHashTable;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object parent;
   GHashTable *hash;
} Hash;

typedef struct {
   Class meta;
} s_Hash;
extern s_Hash vs_Hash;

/**
 * Casts a given Object to Hash.
 */
#define as_hash(obj) ((Hash*) (obj))

/**
 * Inits internal data.
 */
void Hash__INIT(Object* x);

/**
 * Hash#new
 */
Object * Hash_new();

/**
 * Hash#[]
 */
Object * Hash__INDEX_(Object *self, Object *key);

/**
 * Hash#[]=
 */
Object * Hash__INDEX__EQ_(Object *self, Object *key, Object *value);

/**
 * Hash#delete
 */
Object * Hash_delete(Object *self, Object *key);

/**
 * Hash#keys
 */
Object * Hash_keys(Object *self);

#endif /* HASH_H_ */

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
