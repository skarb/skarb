#ifndef OBJECTS_H_
#define OBJECTS_H_

#include <stdint.h>

typedef struct {
   uint32_t type;
} Object;


#define as_object(obj) ((Object *)(obj))

/**
 * Object#puts. Well, actually it's Kernel#puts but who cares.
 */
Object * Object_puts(Object *obj, Object *what);

/**
 * Checks whether a given object is of a given type. The second parameter should
 * be a name of a type, the '_t' prefix will be added automatically.
 */
#define is_a(obj, type_symbol) ((type_symbol##_t) == as_object(obj)->type)

/**
 * Sets the type of a given object. The second parameter should be a name of a
 * type, the '_t' prefix will be added automatically.
 */
#define set_type(obj, type_symbol) (as_object(obj)->type = (type_symbol##_t))

/**
 * Object#to_s
 */
Object * Object_to__s(Object *obj);

/**
 * Object#==
 */
Object * Object__EQ__EQ_(Object *self, Object *other);

/**
 * Object.rand
 */
Object * Object_rand(Object *self);

/**
 * Object.nil?
 */
Object * Object_nil__QMARK(Object *self);

#endif /* OBJECTS_H_ */

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
