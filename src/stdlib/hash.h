#ifndef HASH_H_
#define HASH_H_

#include "object.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GHashTable;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object meta;
   GHashTable *hash;
} Hash;

/**
 * Casts a given Object to Hash.
 */
#define as_hash(obj) ((Hash*) (obj))

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

#endif /* HASH_H_ */
