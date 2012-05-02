#ifndef ARRAY_H_
#define ARRAY_H_

#include "object.h"
#include "class.h"

#ifndef GLIB_MAJOR_VERSION
typedef void GArray;
#endif /* GLIB_MAJOR_VERSION */

typedef struct {
   Object parent;
   GArray *arr;
} Array;

typedef struct {
   Class meta;
} s_Array;
extern s_Array vs_Array;


/**
 * Casts a given Object to Array.
 */
#define as_array(obj) ((Array*) (obj))

/**
 * Inits internal data.
 */
void Array__INIT(Object* x);


/**
 * Array#new
 */
Object * Array_new();

/**
 * Array#[]
 */
Object * Array__INDEX_(Object *self, Object *other);

/**
 * Array#[]=
 */
Object * Array__INDEX__EQ_(Object *self, Object *idx, Object *val);

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

/**
 * Array#length
 */
Object * Array_length(Object *self);

/**
 * Array#join
 */
Object * Array_join(Object *self, Object *separator);

/**
 * Array#map
 */
Object * Array_map(Object *self);

#endif /* ARRAY_H_ */
