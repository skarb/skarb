#ifndef HELPERS_H_
#define HELPERS_H_

#include "object.h"

/**
 * Returns the value of a given object in a boolean context.
 */
int boolean_value(Object *object);

/**
 * Returns a logical negation of the value of a given object.
 */
Object * not(Object *object);

#endif /* HELPERS_H_ */
