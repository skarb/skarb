#include "fixnum.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "nil.h"

// FIXME: we need a real true
#define true Fixnum_new(1)

/**
 * Casts a given Object to Fixnum.
 */
#define as_fixnum(obj) ((Fixnum*) (obj))

Object * Fixnum_new(int value) {
    Fixnum *self = xmalloc(sizeof(Fixnum));
    set_type(self, Fixnum);
    self->val = value;
    return TO_OBJECT(self);
}

Object * Fixnum__PLUS_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return Fixnum_new(as_fixnum(self)->val + as_fixnum(other)->val);
}

Object * Fixnum__MINUS_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return Fixnum_new(as_fixnum(self)->val - as_fixnum(other)->val);
}

Object * Fixnum__EQ__EQ_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return (as_fixnum(self)->val == as_fixnum(other)->val) ?
        true : nil;
}

Object * Fixnum__LT_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return (as_fixnum(self)->val < as_fixnum(other)->val) ?
        true : nil;
}

Object * Fixnum__GT_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return (as_fixnum(self)->val > as_fixnum(other)->val) ?
        true : nil;
}
