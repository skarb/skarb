#ifndef TYPES_H_
#define TYPES_H_

/**
 * Numeric identifiers of standard types.
 */
enum {
  Object_t = 0,
  Class_t,
  M_Object_t,
  Fixnum_t,
  Float_t,
  String_t,
  NilClass_t,
  Array_t,
  Hash_t,
  TrueClass_t,
  FalseClass_t,
  /**
   * The following identifier is the first value which can be used for
   * user-defined types.
   */
  FIRST_USER_TYPE
};

#endif /* TYPES_H_ */

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
