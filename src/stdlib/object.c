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
#include <string.h>
#include <stdlib.h>
#include "object.h"
#include "types.h"
#include "stringclass.h"
#include "xalloc.h"
#include "nil.h"
#include "helpers.h"
#include "float.h"
#include "method_cache.h"
#include "true.h"
#include "false.h"

s_Object vs_Object = {{{Class_t},{Object_t}}};

/**
 * Outputs a String. It doesn't emit a new line character if the string already
 * ends with one.
 */
static void puts_string(String *str) {
  const char *value = String_to__char__array(as_object(str));
  if ('\n' == value[strlen(value) - 1])
    printf("%s", value);
  else
    printf("%s\n", value);
}

Object * Object_puts(Object *self, Object *what) {
  Object* str = ((Object*(*)(Object*)) find_method(what->type, l_classes_dictionary,
        to__s_id, "to__s", 5))(what);
  if (!is_a(str, String))
    die("Internal error");
  puts_string((String*) str);
  return nil;
}

Object * Object_to__s(Object *obj) {
  // TODO: how long can a pointer's string representation be?
  static const int maxlen = sizeof("#<Object:12345678901234567890>");
  char *buffer = xmalloc(maxlen + 1);
  snprintf(buffer, maxlen, "#<Object:%p>", obj);
  return String_new(buffer);
}

Object * Object__EQ__EQ_(Object *self, Object *other) {
  return boolean_to_object(self == other);
}

Object * Object_rand(Object *self) {
#ifdef WIN32
   return Float_new((double)(rand())/RAND_MAX);
#else
   return Float_new(drand48());
#endif
}

Object * Object_nil__QMARK(Object *self) {
  if(self->type == NilClass_t) return true;
  return false;
}
