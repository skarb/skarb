#include <stdlib.h>
#include "helpers.h"
#include "object.h"
#include "nil.h"
#include "fixnum.h"

int boolean_value(Object *object) {
  return object != nil;
}

Object * not(Object *object) {
  return boolean_to_object(!boolean_value(object));
}

Object * boolean_to_object(int value) {
  // TODO: replace with FalseClass and TrueClass objects.
  return value ? Fixnum_new(1) : nil;
}
