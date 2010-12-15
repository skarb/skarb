#include "fixnum.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "float.h"

Object * Fixnum_new(int value) {
    Fixnum *self = xmalloc(sizeof(Fixnum));
    set_type(self, Fixnum);
    self->val = value;
    return TO_OBJECT(self);
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
