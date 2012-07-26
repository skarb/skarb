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
} s_Fixnum;
extern s_Fixnum vs_Fixnum;

/**
 * Casts a given Object to Fixnum.
 */
#define as_fixnum(obj) ((Fixnum*) (obj))

/**
 * Inits internal data.
 */
#define Fixnum__INIT(x,y) (as_fixnum(x)->val = y)

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
 * Fixnum#-@
 */
Object * Fixnum__MINUS_AMP(Object *self);

/**
 * Fixnum#*
 */
Object * Fixnum__MUL_(Object *self, Object *other);

/**
 * Fixnum#**
 */
Object * Fixnum__POW_(Object *self, Object *other);

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
Object * Fixnum_to__s(Object *self);

/**
 * Fixnum#zero
 */
Object * Fixnum_zero_QMARK(Object *self);

/**
 * Fixnum#times
 */
Object * Fixnum_times(Object *self);

/**
 * Fixnum#upto
 */
Object * Fixnum_upto(Object *self, Object *limit);

#endif /* FIXNUM_H_ */
