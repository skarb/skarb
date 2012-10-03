#include <glib.h>
#include "array.h"
#include "xalloc.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "nil.h"
#include "true.h"
#include "false.h"
#include "stringclass.h"
#include "blocks.h"
#include "method_cache.h"

s_Array vs_Array = {{{Class_t}, {Array_t}}};

void Array__INIT(Object* x) {
   (as_array(x)->arr = g_array_new(FALSE, FALSE, sizeof(Object*)));
}

Object * Array_new() {
    Array *self = xmalloc(sizeof(Array));
    set_type(self, Array);
    Array__INIT(as_object(self));
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
        return false;
    for (int index = 0; index < length; ++index) {
        // FIXME: Fixnum#== won't compare other types
        Object *cmp = Fixnum__EQ__EQ_(
                g_array_index(as_array(self)->arr, Object*, index),
                g_array_index(as_array(other)->arr, Object*, index));
        if (boolean_value(not(cmp)))
            return false;
    }
    return true;
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

Object * Array_join(Object *self, Object *sep) {
    if (!is_a(sep, String))
        die("TypeError");
    int length = as_array(self)->arr->len;
    if (length == 0)
        return Nil_to__s(nil);
    Object *buf = String_new("");
    for (int index = 0; index < length; ++index) {
        if (index != 0)
            buf = String__PLUS_(buf, sep);
        Object *item = g_array_index(as_array(self)->arr, Object*, index);
        Object *str;
        if(is_a(item, Array)) str = Array_join(item, sep);
        else str = ( (Object*(*)(Object*)) find_method(item->type,
                 l_classes_dictionary, to__s_id, "to__s", 5))(item);
        buf = String__PLUS_(buf, str);
    }
    return buf;
}

Object * Array_map(Object *self) {
    Object *arr = Array_new();
    for (int i = 0; i < as_array(self)->arr->len; ++i) {
        Object *obj = get_block()(self,
                g_array_index(as_array(self)->arr, Object*, i));
        Array_push(arr, obj);
    }
    return arr;
}

Object * Array_max(Object *self) {
    Object *max = g_array_index(as_array(self)->arr, Object*, 0);
    for (int i = 1; i < as_array(self)->arr->len; ++i) {
       Object *obj = g_array_index(as_array(self)->arr, Object*, i);
       Object *compar = ((Object*(*)(Object*,Object*)) find_method(max->type,
              l_classes_dictionary, _LT__id, "<", 1))(max, obj);
       if(boolean_value(compar)) max = obj;
    }
    return max;
}


/*******************************************************************************
(C) 2010-2012 Jan Stępień, Julian Zubek

This file is a part of Skarb -- Ruby to C compiler.

Skarb is free software: you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with Skarb. If not, see <http://www.gnu.org/licenses/>.

*******************************************************************************/
