#include <stdio.h>
#include <glib.h>
#include "float.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "stringclass.h"

sFloat vsFloat = {{{Class_t}, {Float_t}}};

Object * Float_new(double value) {
    Float *self = xmalloc_atomic(sizeof(Float));
    set_type(self, Float);
    self->val = value;
    return as_object(self);
}

Object * Float__PLUS_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val + as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val + as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__MINUS_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val - as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val - as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__MUL_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val * as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val * as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__DIV_(Object *self, Object *other) {
    if (is_a(other, Float))
        return Float_new(as_float(self)->val / as_float(other)->val);
    else if (is_a(other, Fixnum))
        return Float_new(as_float(self)->val / as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__EQ__EQ_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val == as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val ==
            (double) as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__LT_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val < as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val < as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float__GT_(Object *self, Object *other) {
    if (is_a(other, Float))
        return boolean_to_object(as_float(self)->val > as_float(other)->val);
    else if (is_a(other, Fixnum))
        return boolean_to_object(as_float(self)->val > as_fixnum(other)->val);
    die("TypeError");
    return 0;
}

Object * Float_to_s(Object *self) {
  static const int maxlen = sizeof("1234567890.1234567890");
  char *buffer = g_alloca(maxlen + 1);
  snprintf(buffer, maxlen, "%g", as_float(self)->val);
  return String_new(buffer);
}

Object * Float_zero_QMARK(Object *self) {
  return boolean_to_object(as_float(self)->val == 0);
}
