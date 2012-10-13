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
