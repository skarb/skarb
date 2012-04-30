#ifndef FLOAT_H_
#define FLOAT_H_

#include "object.h"
#include "class.h"

typedef struct {
   Object parent;
   double val;
} Float;

typedef struct {
   Class meta;
} s_Float;
extern s_Float vs_Float;

/**
 * Casts a given Object to Float.
 */
#define as_float(obj) ((Float*) (obj))

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
 * Float#-@
 */
Object * Float__MINUS_AMP(Object *self);

/**
 * Float#*
 */
Object * Float__MUL_(Object *self, Object *other);

/**
 * Float#/
 */
Object * Float__DIV_(Object *self, Object *other);

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

/**
 * Float#to_s
 */
Object * Float_to__s(Object *self);

/**
 * Float#zero?
 */
Object * Float_zero_QMARK(Object *self);

/**
 * Float#floor
 */
Object * Float_floor(Object *self);

#endif /* FLOAT_H_ */
