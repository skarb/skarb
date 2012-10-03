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
