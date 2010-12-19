#ifndef OBJECTS_H_
#define OBJECTS_H_

#include <stdint.h>

typedef struct {
   uint32_t type;
} Object;

#define as_object(obj) ((Object *)(obj))

/**
 * Object#puts. Well, actually it's Kernel#puts but who cares.
 */
Object * Object_puts(Object *obj, Object *what);

/**
 * Checks whether a given object is of a given type. The second parameter should
 * be a name of a type, the '_t' prefix will be added automatically.
 */
#define is_a(obj, type_symbol) ((type_symbol##_t) == as_object(obj)->type)

/**
 * Sets the type of a given object. The second parameter should be a name of a
 * type, the '_t' prefix will be added automatically.
 */
#define set_type(obj, type_symbol) (as_object(obj)->type = (type_symbol##_t))

/**
 * Object#to_s
 */
Object * Object_to_s(Object *obj);

/**
 * Object#==
 */
Object * Object__EQ__EQ_(Object *self, Object *other);

#endif /* OBJECTS_H_ */
