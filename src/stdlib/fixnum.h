#ifndef FIXNUM_H_
#define FIXNUM_H_

#include "object.h"
#include "class.h"

typedef struct {
   Object parent;
   int val;
} Fixnum;

typedef struct {
   Class meta;
} sFixnum;
extern sFixnum vsFixnum;

/**
 * Casts a given Object to Fixnum.
 */
#define as_fixnum(obj) ((Fixnum*) (obj))

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
 * Fixnum#*
 */
Object * Fixnum__MUL_(Object *self, Object *other);

/**
 * Fixnum#/
 */
Object * Fixnum__DIV_(Object *self, Object *other);

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

/**
 * Fixnum#to_s
 */
Object * Fixnum_to_s(Object *self);

/**
 * Fixnum#zero
 */
Object * Fixnum_zero_QMARK(Object *self);

#endif /* FIXNUM_H_ */
