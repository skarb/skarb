#ifndef ARRAY_H_
#define ARRAY_H_

#include "object.h"
#include "class.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GArray;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object parent;
   GArray *arr;
} Array;

typedef struct {
   Class meta;
} s_Array;
extern s_Array vs_Array;


/**
 * Casts a given Object to Array.
 */
#define as_array(obj) ((Array*) (obj))

/**
 * Inits internal data.
 */
void Array__INIT(Object* x);


/**
 * Array#new
 */
Object * Array_new();

/**
 * Array#[]
 */
Object * Array__INDEX_(Object *self, Object *other);

/**
 * Array#[]=
 */
Object * Array__INDEX__EQ_(Object *self, Object *idx, Object *val);

/**
 * Array#push
 */
Object * Array_push(Object *self, Object *other);

/**
 * Array#pop
 */
Object * Array_pop(Object *self);

/**
 * Array#shift
 */
Object * Array_shift(Object *self);

/**
 * Array#unshift
 */
Object * Array_unshift(Object *self, Object *other);

/**
 * Array#delete
 */
Object * Array_delete(Object *self, Object *other);

/**
 * Array#==
 */
Object * Array__EQ__EQ_(Object *self, Object *other);

/**
 * Array#length
 */
Object * Array_length(Object *self);

/**
 * Array#join
 */
Object * Array_join(Object *self, Object *separator);

/**
 * Array#map
 */
Object * Array_map(Object *self);

/**
 * Array#max
 */
Object * Array_max(Object *self);

#endif /* ARRAY_H_ */

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
