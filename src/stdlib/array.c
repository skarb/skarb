#include <glib.h>
#include "array.h"
#include "xalloc.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "nil.h"

Object * Array_new() {
    Array *self = xmalloc(sizeof(Array));
    set_type(self, Array);
    self->arr = g_array_new(FALSE, FALSE, sizeof(Object*));
    return as_object(self);
}

Object * Array__INDEX_(Object *self, Object *other) {
    if (!is_a(other, Fixnum))
        die("TypeError");
    int index = as_fixnum(other)->val;
    // TODO: Negative indices, such as arr[-1]
    if (index < 0 || as_array(self)->arr->len <= index)
        return nil;
    return g_array_index(as_array(self)->arr, Object*, index);
}

Object * Array_push(Object *self, Object *other) {
    g_array_append_val(as_array(self)->arr, other);
    return self;
}

Object * Array_pop(Object *self) {
    int last_index = as_array(self)->arr->len - 1;
    Object *last = g_array_index(as_array(self)->arr, Object*, last_index);
    g_array_remove_index(as_array(self)->arr, last_index);
    return last;
}

Object * Array_shift(Object *self) {
    Object *first = g_array_index(as_array(self)->arr, Object*, 0);
    g_array_remove_index(as_array(self)->arr, 0);
    return first;
}

Object * Array_unshift(Object *self, Object *other) {
    g_array_prepend_val(as_array(self)->arr, other);
    return self;
}

Object * Array_delete(Object *self, Object *other) {
    int length = as_array(self)->arr->len;
    for (int index = 0; index < length; ++index) {
        // FIXME: Fixnum#== won't compare other types
        Object *cmp = Fixnum__EQ__EQ_(
                g_array_index(as_array(self)->arr, Object*, index), other);
        if (boolean_value(cmp))
            g_array_remove_index(as_array(self)->arr, index);
    }
    return other;
}

Object * Array__EQ__EQ_(Object *self, Object *other) {
    int length = as_array(self)->arr->len;
    if (length != as_array(other)->arr->len)
        return nil;
    for (int index = 0; index < length; ++index) {
        // FIXME: Fixnum#== won't compare other types
        Object *cmp = Fixnum__EQ__EQ_(
                g_array_index(as_array(self)->arr, Object*, index),
                g_array_index(as_array(other)->arr, Object*, index));
        if (boolean_value(not(cmp)))
            return nil;
    }
    /* TODO: An array is 'true', but a real 'true' would be better */
    return self;
}

Object * Array_length(Object *self) {
    return Fixnum_new(as_array(self)->arr->len);
}

Object * Array__INDEX__EQ_(Object *self, Object *idx, Object *val) {
    if (!is_a(idx, Fixnum))
        die("TypeError");
    int index = as_fixnum(idx)->val, length = as_array(self)->arr->len;
    // TODO: Negative indices, such as arr[-1]
    if (0 <= index && index < length)
        g_array_index(as_array(self)->arr, Object*, index) = val;
    else if (index == length) {
        Array_push(self, val);
    } else {
        int nils_needed = index - length;
        while (nils_needed--)
            Array_push(self, nil);
        Array_push(self, val);
    }
    return val;
}
