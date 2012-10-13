/*
 * Copyright (c) 2010-2012 Jan Stępień, Julian Zubek
 *
 * This file is a part of Skarb -- a Ruby to C compiler.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
