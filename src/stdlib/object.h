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
