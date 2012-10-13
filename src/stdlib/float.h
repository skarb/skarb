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

#ifndef FLOAT_H_
#define FLOAT_H_

#include "object.h"
#include "class.h"

typedef struct {
   Object parent;
   double val;
} Float;

typedef struct {
   Class meta;
} s_Float;
extern s_Float vs_Float;

/**
 * Casts a given Object to Float.
 */
#define as_float(obj) ((Float*) (obj))

/**
 * Inits internal data.
 */
#define Float__INIT(x,y) (as_float(x)->val = y)

/**
 * Float#new
 */
Object * Float_new(double value);

/**
 * Float#+
 */
Object * Float__PLUS_(Object *self, Object *other);

/**
 * Float#-
 */
Object * Float__MINUS_(Object *self, Object *other);

/**
 * Float#-@
 */
Object * Float__MINUS_AMP(Object *self);

/**
 * Float#*
 */
Object * Float__MUL_(Object *self, Object *other);

/**
 * Float#/
 */
Object * Float__DIV_(Object *self, Object *other);

/**
 * Float#==
 */
Object * Float__EQ__EQ_(Object *self, Object *other);

/**
 * Float#<
 */
Object * Float__LT_(Object *self, Object *other);

/**
 * Float#>
 */
Object * Float__GT_(Object *self, Object *other);

/**
 * Float#to_s
 */
Object * Float_to__s(Object *self);

/**
 * Float#zero?
 */
Object * Float_zero_QMARK(Object *self);

/**
 * Float#floor
 */
Object * Float_floor(Object *self);

#endif /* FLOAT_H_ */
