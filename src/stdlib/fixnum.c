#include <stdio.h>
#include <glib.h>
#include "fixnum.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "float.h"
#include "stringclass.h"

/**
 * Used to cache fixnums in range [-1,1]
 */
Fixnum cached_fixnums[] = {{{Fixnum_t}, -1}, {{Fixnum_t}, 0}, {{Fixnum_t}, 1}};

Object * Fixnum_new(int value) {
    if (value == -1 || value == 0 || value == 1)
        return as_object(cached_fixnums + 1 + value);
    Fixnum *self = xmalloc_atomic(sizeof(Fixnum));
    set_type(self, Fixnum);
    self->val = value;
    return as_object(self);
}

Object * Fixnum__PLUS_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val + as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val + as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__MINUS_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val - as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val - as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__MUL_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val * as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val * as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__DIV_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return Fixnum_new(as_fixnum(self)->val / as_fixnum(other)->val);
    else if (is_a(other, Float))
        return Float_new(as_fixnum(self)->val / as_float(other)->val);
    die("TypeError");
    return 0;
}


Object * Fixnum__EQ__EQ_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val == as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val == as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__LT_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val < as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val < as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum__GT_(Object *self, Object *other) {
    if (is_a(other, Fixnum))
        return boolean_to_object(as_fixnum(self)->val > as_fixnum(other)->val);
    else if (is_a(other, Float))
        return boolean_to_object(as_fixnum(self)->val > as_float(other)->val);
    die("TypeError");
    return 0;
}

Object * Fixnum_to_s(Object *self) {
  static const int maxlen = sizeof("1234567890");
  char *buffer = g_alloca(maxlen + 1);
  snprintf(buffer, maxlen, "%i", as_fixnum(self)->val);
  return String_new(buffer);
}

Object * Fixnum_zero_QMARK(Object *self) {
  return boolean_to_object(as_fixnum(self)->val == 0);
}
