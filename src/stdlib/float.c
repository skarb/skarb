#include "float.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"

Float * Float_new(double value) {
    Float *self = xmalloc(sizeof(Float));
    set_type(self, Float);
    self->val = value;
    return self;
}
