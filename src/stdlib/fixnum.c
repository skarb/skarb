#include "xalloc.h"
#include "objects.h"

Fixnum * Fixnum_new(int value) {
    Fixnum *self = xmalloc(sizeof(Fixnum));
    self->val = value;
    return self;
}
