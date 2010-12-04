#ifndef OBJECTS_H_
#define OBJECTS_H_

#include <stdint.h>

typedef struct {
   uint32_t type;
} Object;

#define TO_OBJECT(obj) ((Object *)(obj))

/**
 * Object#puts. Well, actually it's Kernel#puts but who cares.
 */
Object * Object_Object_puts(Object *obj);

/**
 * Checks whether a given object is of a given type. The second parameter should
 * be a name of a type, the '_t' prefix will be added automatically.
 */
#define is_a(obj, type_symbol) ((type_symbol##_t) == TO_OBJECT(obj)->type)

/**
 * Sets the type of a given object. The second parameter should be a name of a
 * type, the '_t' prefix will be added automatically.
 */
#define set_type(obj, type_symbol) (TO_OBJECT(obj)->type = (type_symbol##_t))

#endif /* OBJECTS_H_ */
