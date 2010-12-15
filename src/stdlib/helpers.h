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

/**
 * Returns an Object representing a given logical value, that is a nil or
 * something which isn't a nil.
 */
Object * boolean_to_object(int value);

/**
 * Prints arguments to stderr and exits with an error status.
 */
void die(const char *format, ...);

/**
 * Performs all required operations which cannot be done statically and have to
 * be done at the very beginning of run time.
 */
void initialize();

#endif /* HELPERS_H_ */
