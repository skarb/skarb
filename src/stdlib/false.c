#include "false.h"
#include "types.h"
#include "stringclass.h"

FalseClass the_false = { FalseClass_t };
FalseClass *false = &the_false;

sObject vsFalseClass = { {FalseClass_t} };

Object *False_to_s(Object *self) {
  static Object *string = 0;
  if (string)
    return string;
  return string = String_new("false");
}
