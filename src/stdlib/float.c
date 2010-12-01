#include "float.h"
#include "xalloc.h"

Float * Float_new(double value) {
    Float *self = xmalloc(sizeof(Float));
    self->val = value;
    return self;
}
