#ifndef HASH_H_
#define HASH_H_

#include "object.h"
#include "class.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GHashTable;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object parent;
   GHashTable *hash;
} Hash;

typedef struct {
   Class meta;
} s_Hash;
extern s_Hash vs_Hash;

/**
 * Casts a given Object to Hash.
 */
#define as_hash(obj) ((Hash*) (obj))

/**
 * Inits internal data.
 */
void Hash__INIT(Object* x);

/**
 * Hash#new
 */
Object * Hash_new();

/**
 * Hash#[]
 */
Object * Hash__INDEX_(Object *self, Object *key);

/**
 * Hash#[]=
 */
Object * Hash__INDEX__EQ_(Object *self, Object *key, Object *value);

/**
 * Hash#delete
 */
Object * Hash_delete(Object *self, Object *key);

/**
 * Hash#keys
 */
Object * Hash_keys(Object *self);

#endif /* HASH_H_ */
