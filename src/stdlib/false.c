#include "false.h"
#include "types.h"
#include "stringclass.h"

FalseClass the_false = { FalseClass_t };
FalseClass *false = &the_false;

s_Object vs_FalseClass = { {{Class_t}, {FalseClass_t}} };

Object *False_to__s(Object *self) {
  static Object *string = 0;
  if (string)
    return string;
  return string = String_new("false");
}

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
