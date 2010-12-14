#ifndef FLOAT_H_
#define FLOAT_H_

#include "object.h"

typedef struct {
   Object meta;
   double val;
} Float;

/**
 * Float#new
 */
Object * Float_new(double value);

/**
 * Float#+
 */
Object * Float__PLUS_(Object *self, Object *other);

/**
 * Float#-
 */
Object * Float__MINUS_(Object *self, Object *other);

/**
 * Float#==
 */
Object * Float__EQ__EQ_(Object *self, Object *other);

/**
 * Float#<
 */
Object * Float__LT_(Object *self, Object *other);

/**
 * Float#>
 */
Object * Float__GT_(Object *self, Object *other);

#endif /* FLOAT_H_ */
