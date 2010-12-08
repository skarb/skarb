#include "stringclass.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"

Object * String_new(char *value) {
    String *self = xmalloc(sizeof(String));
    set_type(self, String);
    /* TODO: we aren't making a copy of value assuming that it won't be freed or
     * overwritten. This assumption may be invalid so it may be wise to allocate
     * some space and make a copy. */
    self->val = value;
    return TO_OBJECT(self);
}
