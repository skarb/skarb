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
