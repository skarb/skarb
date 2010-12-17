#include <stdio.h>
#include <string.h>
#include "object.h"
#include "types.h"
#include "fixnum.h"
#include "float.h"
#include "stringclass.h"
#include "xalloc.h"

/**
 * Outputs a String. It doesn't emit a new line character if the string already
 * ends with one.
 */
static void puts_string(String *str) {
  const char *value = String_to_char_array(TO_OBJECT(str));
  if ('\n' == value[strlen(value) - 1])
    printf("%s", value);
  else
    printf("%s\n", value);
}

Object * Object_Object_puts(Object *obj) {
  if (is_a(obj, Fixnum))
    printf("%i\n", ((Fixnum*) obj)->val);
  else if (is_a(obj, Float))
    printf("%g\n", ((Float*) obj)->val);
  else if (is_a(obj, String))
    puts_string((String*) obj);
  else
    printf("#<Object:%p>\n", obj);
  return NULL;
}

Object * Object_to_s(Object *obj) {
  // TODO: how long can a pointer's string representation be?
  static const int maxlen = sizeof("#<Object:12345678901234567890>");
  char *buffer = xmalloc(maxlen + 1);
  snprintf(buffer, maxlen, "#<Object:%p>", obj);
  return String_new(buffer);
}
