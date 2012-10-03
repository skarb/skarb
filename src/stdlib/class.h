#ifndef CLASS_H_
#define CLASS_H_

#include "object.h"

typedef struct {
  Object parent; 
  Object ctype;
} Class;

typedef struct {
   Class meta;
} s_Class;
extern s_Class vs_Class;

typedef struct {
   Class meta;
} s_Object;
extern s_Object vs_Object;

#define as_class(obj) ((Class *)(obj))

#endif /* CLASS_H_ */

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
