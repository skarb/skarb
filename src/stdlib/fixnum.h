#ifndef FIXNUM_H_
#define FIXNUM_H_

#include "object.h"

typedef struct {
   Object meta;
   int val;
} Fixnum;

/**
 * Fixnum#new
 */
Object * Fixnum_new(int value);

/**
 * Fixnum#+
 */
Object * Fixnum__PLUS_(Object *self, Object *other);

/**
 * Fixnum#-
 */
Object * Fixnum__MINUS_(Object *self, Object *other);

/**
 * Fixnum#==
 */
Object * Fixnum__EQ__EQ_(Object *self, Object *other);

/**
 * Fixnum#<
 */
Object * Fixnum__LT_(Object *self, Object *other);

/**
 * Fixnum#>
 */
Object * Fixnum__GT_(Object *self, Object *other);

#endif /* FIXNUM_H_ */
