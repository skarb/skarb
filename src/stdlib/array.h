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
