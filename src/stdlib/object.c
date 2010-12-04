#include <stdio.h>
#include "object.h"
#include "types.h"
#include "fixnum.h"
#include "float.h"

Object * Object_Object_puts(Object *obj) {
  if (is_a(obj, Fixnum))
    printf("%i\n", ((Fixnum*) obj)->val);
  else if (is_a(obj, Float))
    printf("%g\n", ((Float*) obj)->val);
  else
    printf("#<Object:%p>\n", obj);
  return NULL;
}
