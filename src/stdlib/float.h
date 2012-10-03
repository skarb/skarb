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
 * Inits internal data.
 */
#define Float__INIT(x,y) (as_float(x)->val = y)

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
