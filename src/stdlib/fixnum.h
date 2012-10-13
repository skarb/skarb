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

#ifndef FIXNUM_H_
#define FIXNUM_H_

#include "object.h"
#include "class.h"

typedef struct {
   Object parent;
   int val;
} Fixnum;

typedef struct {
   Class meta;
} s_Fixnum;
extern s_Fixnum vs_Fixnum;

/**
 * Casts a given Object to Fixnum.
 */
#define as_fixnum(obj) ((Fixnum*) (obj))

/**
 * Inits internal data.
 */
#define Fixnum__INIT(x,y) (as_fixnum(x)->val = y)

/**
 * Fixnum#new
 */
Object * Fixnum_new(int value);

/**
 * Fixnum#+
 */
Object * Fixnum__PLUS_(Object *self, Object *other);

/**
 * Fixnum#-
 */
Object * Fixnum__MINUS_(Object *self, Object *other);

/**
 * Fixnum#-@
 */
Object * Fixnum__MINUS_AMP(Object *self);

/**
 * Fixnum#*
 */
Object * Fixnum__MUL_(Object *self, Object *other);

/**
 * Fixnum#**
 */
Object * Fixnum__POW_(Object *self, Object *other);

/**
 * Fixnum#/
 */
Object * Fixnum__DIV_(Object *self, Object *other);

/**
 * Fixnum#==
 */
Object * Fixnum__EQ__EQ_(Object *self, Object *other);

/**
 * Fixnum#<
 */
Object * Fixnum__LT_(Object *self, Object *other);

/**
 * Fixnum#>
 */
Object * Fixnum__GT_(Object *self, Object *other);

/**
 * Fixnum#to_s
 */
Object * Fixnum_to__s(Object *self);

/**
 * Fixnum#zero
 */
Object * Fixnum_zero_QMARK(Object *self);

/**
 * Fixnum#times
 */
Object * Fixnum_times(Object *self);

/**
 * Fixnum#upto
 */
Object * Fixnum_upto(Object *self, Object *limit);

#endif /* FIXNUM_H_ */
