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
#include "fixnum.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "float.h"
#include "stringclass.h"
#include "nil.h"
#include "blocks.h"

s_Fixnum vs_Fixnum = {{{Class_t}, {Fixnum_t}}};

/**
 * Used to cache fixnums in range [-1,1]
 */
Fixnum cached_fixnums[] = {{{Fixnum_t}, -1}, {{Fixnum_t}, 0}, {{Fixnum_t}, 1}};

Object * Fixnum_new(int value) {
    if (value == -1 || value == 0 || value == 1)
        return as_object(cached_fixnums + 1 + value);
    Fixnum *self = xmalloc_atomic(sizeof(Fixnum));
    set_type(self, Fixnum);
    Fixnum__INIT(self, value);
    return as_object(self);
}

Object * Fixnum__PLUS_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val + as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val + as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__MINUS_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val - as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val - as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__MINUS_AMP(Object *self) {
    return Fixnum_new(-as_fixnum(self)->val);
}

Object * Fixnum__MUL_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val * as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val * as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__POW_(Object *self, Object *other) {
   if (is_a(other, Fixnum)) {
      int other_val = as_fixnum(other)->val;
      if(other_val == 0) return Fixnum_new(1);
      int val = as_fixnum(self)->val;
      int v = val;
      if(other_val < 0) {
         for(int i = 1; i < -other_val; i++) v *= val;
         return Float_new(1.0f / v);
      }
      for(int i = 1; i < other_val; i++) v *= val;
      return Fixnum_new(v);
   }
   if (is_a(other, Float)) {
      float v = powf((float)as_fixnum(self)->val, (float)as_float(other)->val);
      return Float_new(v);
   }
   die("TypeError");
   return 0;
}

Object * Fixnum__DIV_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val / as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val / as_float(other)->val);
    die("TypeError");
    return 0;
}


Object * Fixnum__EQ__EQ_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val == as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val == as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__LT_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val < as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val < as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__GT_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val > as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val > as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum_to__s(Object *self) {
  static const int maxlen = sizeof("1234567890");
  char *buffer = g_alloca(maxlen + 1);
  snprintf(buffer, maxlen, "%i", as_fixnum(self)->val);
  return String_new(buffer);
}

Object * Fixnum_zero_QMARK(Object *self) {
  return boolean_to_object(as_fixnum(self)->val == 0);
}

Object * Fixnum_times(Object *self) {
  for (int i = 0; i < as_fixnum(self)->val; ++i)
    get_block()(self);
  return nil;
}

Object * Fixnum_upto(Object *self, Object *limit) {
  if (!is_a(limit, Fixnum))
    die("TypeError");
  for (int i = as_fixnum(self)->val; i <= as_fixnum(limit)->val; ++i)
    get_block()(self, Fixnum_new(i));
  return nil;
}
