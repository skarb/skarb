#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <glib.h>
#include <gc.h>
#include "helpers.h"
#include "object.h"
#include "nil.h"
#include "fixnum.h"
#include "xalloc.h"

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

void initialize() {
  GC_INIT();
  GMemVTable vtable = { &xmalloc, &xrealloc, &xfree, NULL, NULL, NULL };
  g_mem_set_vtable(&vtable);
}
