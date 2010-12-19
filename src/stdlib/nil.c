#include "nil.h"
#include "types.h"
#include "stringclass.h"

NilClass the_nil = { NilClass_t };
NilClass *nil = &the_nil;

Object *Nil_to_s(Object *self) {
  static Object *string = 0;
  if (string)
    return string;
  return string = String_new("");
}
