#include <glib.h>
#include "hash.h"
#include "nil.h"
#include "xalloc.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"

sHash vsHash = {{{Class_t}, {Hash_t}}};

/*
 * Implements GEqualFunc, used for comparing keys in the hash.
 */
static gboolean equal_func(gconstpointer a, gconstpointer b) {
    // FIXME: works only with Fixnums
    return boolean_value(Fixnum__EQ__EQ_(as_object(a), as_object(b)));
}

static guint hash_func(gconstpointer obj) {
    // FIXME: we need some reasonable hashing mechanism
    return as_object(obj)->type;
}

Object * Hash_new() {
    Hash *self = xmalloc(sizeof(Hash));
    set_type(self, Hash);
    self->hash = g_hash_table_new(hash_func, equal_func);
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
