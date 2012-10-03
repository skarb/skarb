#ifndef METHOD_CACHE_H_
#define METHOD_CACHE_H_

/*
 * The following solution is inspired by Ruby's 1.9 vm_method.c
 */

#include "object.h"

#define CACHE_SIZE 0x800
#define CACHE_MASK 0x7ff

#define HASH(a,b) ((((a)>>3)^(b)) & CACHE_MASK)

typedef struct {
  int fid;
  int cid;
  void *function;
  Object* (*wrapper)(Object**, void*);
} cache_elem;

extern cache_elem method_cache[];

/**
 * Clears cache by executing memset
 */
void clear_cache();


/**
 * Numeric identifiers of methods name from standard library.
 */
enum {
  to__s_id = 0,
  puts_id,
  rand_id,
  _EQ__EQ__id,
  _PLUS__id,
  _MINUS__id,
  _MUL__id,
  _DIV__id,
  _LT__id,
  _GT__id,
  zero_QMARK_id,
  times_id,
  upto_id,
  floor_id,
  length_id,
  to__i_id,
  to__f_id,
  _INDEX__id,
  empty__QMARK__id,
  _INDEX__EQ__id,
  pop_id,
  push_id,
  shift_id,
  unshift_id,
  delete_id,
  join_id,
  map_id,
  keys_id
};

#endif /* METHOD_CACHE_H_ */

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
