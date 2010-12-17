#ifndef ARRAY_H_
#define ARRAY_H_

#include "object.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GArray;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object meta;
   GArray *arr;
} Array;

/**
 * Casts a given Object to Array.
 */
#define as_array(obj) ((Array*) (obj))

/**
 * Array#new
 */
Object * Array_new();

/**
 * Array#[]
 */
Object * Array__INDEX_(Object *self, Object *other);

/**
 * Array#push
 */
Object * Array_push(Object *self, Object *other);

/**
 * Array#pop
 */
Object * Array_pop(Object *self);

/**
 * Array#shift
 */
Object * Array_shift(Object *self);

/**
 * Array#unshift
 */
Object * Array_unshift(Object *self, Object *other);

/**
 * Array#delete
 */
Object * Array_delete(Object *self, Object *other);

/**
 * Array#==
 */
Object * Array__EQ__EQ_(Object *self, Object *other);

#endif /* ARRAY_H_ */
