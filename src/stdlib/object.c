#include <stdio.h>
#include <string.h>
#include "object.h"
#include "types.h"
#include "stringclass.h"
#include "xalloc.h"
#include "nil.h"
#include "helpers.h"

/**
 * Outputs a String. It doesn't emit a new line character if the string already
 * ends with one.
 */
static void puts_string(String *str) {
  const char *value = String_to_char_array(as_object(str));
  if ('\n' == value[strlen(value) - 1])
    printf("%s", value);
  else
    printf("%s\n", value);
}

Object * Object_puts(Object *self, Object *what) {
  static const char method[] = { 4, 't', 'o', '_', 's', '\0' };
  Object *args[] = { what };
  Object *str = call_method(what->type, classes_dictionary, (char*) method,
      args);
  if (!is_a(str, String))
    die("Internal error");
  puts_string((String*) str);
  return nil;
}

Object * Object_to_s(Object *obj) {
  // TODO: how long can a pointer's string representation be?
  static const int maxlen = sizeof("#<Object:12345678901234567890>");
  char *buffer = xmalloc(maxlen + 1);
  snprintf(buffer, maxlen, "#<Object:%p>", obj);
  return String_new(buffer);
}
