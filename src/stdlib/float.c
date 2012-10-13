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

#include <stdio.h>
#include <math.h>
#include <glib.h>
#include "float.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "stringclass.h"

s_Float vs_Float = {{{Class_t}, {Float_t}}};

Object * Float_new(double value) {
    Float *self = xmalloc_atomic(sizeof(Float));
    set_type(self, Float);
    Float__INIT(self, value);
    return as_object(self);
}

Object * Float__PLUS_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val + as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val + as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__MINUS_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val - as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val - as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__MINUS_AMP(Object *self) {
    return Float_new(-as_float(self)->val);
}


Object * Float__MUL_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val * as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val * as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__DIV_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val / as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val / as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__EQ__EQ_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val == as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val ==
            (double) as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__LT_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val < as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val < as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__GT_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val > as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val > as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float_to__s(Object *self) {
  static const int maxlen = sizeof("1234567890.1234567890");
  char *buffer = g_alloca(maxlen + 1);
  snprintf(buffer, maxlen, "%g", as_float(self)->val);
  return String_new(buffer);
}

Object * Float_zero_QMARK(Object *self) {
  return boolean_to_object(as_float(self)->val == 0);
}

Object * Float_floor(Object *self) {
  return Fixnum_new(floor(as_float(self)->val));
}
