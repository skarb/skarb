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

#ifndef HELPERS_H_
#define HELPERS_H_


#include "object.h"
#include "class.h"

/**
 * Structures used in static class dictionary.
 * */
typedef struct {
  char *name;
  void *function;
  Object* (*wrapper)(Object**, void*);
} hash_elem;

typedef struct {
  int parent;
  hash_elem *(*msearch) (char *, unsigned int);
  void *fields;
} dict_elem;

extern dict_elem *l_classes_dictionary;

/**
 * Returns the value of a given object in a boolean context.
 */
int boolean_value(Object *object);

/**
 * Returns a logical negation of the value of a given object.
 */
Object * not(Object *object);

/**
 * Returns an Object representing a given logical value, that is a nil or
 * something which isn't a nil.
 */
Object * boolean_to_object(int value);

/**
 * Prints arguments to stderr and exits with an error status.
 */
void die(const char *format, ...);

/**
 * Performs all required operations which cannot be done statically and have to
 * be done at the very beginning of run time.
 */
void initialize();

void finalize();

/**
 * Looks for a method through inheritance hierarchy and returns it or causes the
 * program to die with an error.
 */
void* find_method(int, dict_elem*, int, char*, int);

/**
 * Initializes the ARGV constants. It assignes a new array to the memory
 * location pointed by the first argument and pushes all but the first element
 * of main's argv table.
 */
void prepare_argv(Object **ARGV, int argc, char **args);

#endif /* HELPERS_H_ */
