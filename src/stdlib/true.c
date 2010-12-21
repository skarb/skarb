#include "true.h"
#include "types.h"
#include "stringclass.h"

TrueClass the_true = { TrueClass_t };
TrueClass *true = &the_true;

sObject vsTrueClass = { {{Class_t},{TrueClass_t}} };

Object *True_to_s(Object *self) {
  static Object *string = 0;
  if (string)
    return string;
  return string = String_new("true");
}
