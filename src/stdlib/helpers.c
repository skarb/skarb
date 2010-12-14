#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
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

void die(const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  vfprintf(stderr, format, ap);
  exit(1);
}
