#include <stdlib.h>
#include "helpers.h"
#include "object.h"
#include "nil.h"
#include "fixnum.h"

int boolean_value(Object *object) {
  return object != nil;
}

Object * not(Object *object) {
  return boolean_value(object) ? nil : Fixnum_new(1);
}
