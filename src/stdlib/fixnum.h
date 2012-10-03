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

/*******************************************************************************
(C) 2010-2012 Jan Stępień, Julian Zubek

This file is a part of Skarb -- Ruby to C compiler.

Skarb is free software: you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Skarb is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with Skarb. If not, see <http://www.gnu.org/licenses/>.

*******************************************************************************/
