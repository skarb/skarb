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
