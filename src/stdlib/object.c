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
  static const char method[] = { 't', 'o', '_', '_', 's', '\0' };
  Object *args[] = { what };
  Object *str = call_method(what->type, classes_dictionary, (char*) method,
      5, args);
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
  return Float_new(drand48());
}
