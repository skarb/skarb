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
