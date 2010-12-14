#include "float.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"

/**
 * Casts a given Object to Float.
 */
#define as_float(obj) ((Float*) (obj))

Object * Float_new(double value) {
    Float *self = xmalloc(sizeof(Float));
    set_type(self, Float);
    self->val = value;
    return TO_OBJECT(self);
}

Object * Float__PLUS_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return Float_new(as_float(self)->val + as_float(other)->val);
}

Object * Float__MINUS_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return Float_new(as_float(self)->val - as_float(other)->val);
}

Object * Float__EQ__EQ_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return boolean_to_object(as_float(self)->val == as_float(other)->val);
}

Object * Float__LT_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return boolean_to_object(as_float(self)->val < as_float(other)->val);
}

Object * Float__GT_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return boolean_to_object(as_float(self)->val > as_float(other)->val);
}
