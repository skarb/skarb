/*
 * Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
 *
 * This file is a part of Skarb -- a Ruby to C compiler.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <glib.h>
#include "hash.h"
#include "nil.h"
#include "xalloc.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "stringclass.h"
#include "array.h"
#include "method_cache.h"

s_Hash vs_Hash = {{{Class_t}, {Hash_t}}};

/*
 * Implements GEqualFunc, used for comparing keys in the hash.
 */
static gboolean equal_func(gconstpointer a, gconstpointer b) {
    return boolean_value(
        ( (Object*(*)(Object*,Object*)) find_method(as_object(a)->type,
           l_classes_dictionary, _EQ__EQ__id, "==", 2))(as_object(a),
           as_object(b)));
}

static guint hash_func(gconstpointer obj) {
    // FIXME: we need some reasonable hashing mechanism
    return as_object(obj)->type;
}

void Hash__INIT(Object* x)
{
   as_hash(x)->hash = g_hash_table_new(hash_func, equal_func);
}

Object * Hash_new() {
    Hash *self = xmalloc(sizeof(Hash));
    set_type(self, Hash);
    Hash__INIT(as_object(self));
    return as_object(self);
}

Object * Hash__INDEX_(Object *self, Object *key) {
    Object *value = g_hash_table_lookup(as_hash(self)->hash, key);
    return value ? value : nil;
}

Object * Hash__INDEX__EQ_(Object *self, Object *key, Object *value) {
    g_hash_table_insert(as_hash(self)->hash, key, value);
    return value;
}

Object * Hash_delete(Object *self, Object *key) {
    Object *value = g_hash_table_lookup(as_hash(self)->hash, key);
    if (value) {
        g_hash_table_remove(as_hash(self)->hash, key);
        return value;
    }
    return nil;
}

Object * Hash_keys(Object *self) {
    GList *keys_list = g_hash_table_get_keys(as_hash(self)->hash);
    Object *keys = Array_new();
    while (keys_list) {
        Array_push(keys, as_object(keys_list->data));
        keys_list = keys_list->next;
    }
    return keys;
}
