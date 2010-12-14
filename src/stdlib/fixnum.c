#include "fixnum.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"

Object * Fixnum_new(int value) {
    Fixnum *self = xmalloc(sizeof(Fixnum));
    set_type(self, Fixnum);
    self->val = value;
    return TO_OBJECT(self);
}

Object * Fixnum__PLUS_(Object *self, Object *other) {
    // TODO: type check and error reporting
    return Fixnum_new(((Fixnum*) self)->val +
            ((Fixnum*) other)->val);
}
