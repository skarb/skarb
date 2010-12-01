#include "fixnum.h"
#include "xalloc.h"
#include "object.h"

Fixnum * Fixnum_new(int value) {
    Fixnum *self = xmalloc(sizeof(Fixnum));
    self->val = value;
    return self;
}
