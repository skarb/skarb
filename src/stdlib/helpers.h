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

extern dict_elem classes_dictionary[];

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

/**
 * Looks for a method through inheritance hierarchy and calls it or causes the
 * program to die with an error.
 */
Object* call_method(int, dict_elem*, char*, Object**);

/**
 * Initializes the ARGV constants. It assignes a new array to the memory
 * location pointed by the first argument and pushes all but the first element
 * of main's argv table.
 */
void prepare_argv(Object **ARGV, int argc, char **args);

#endif /* HELPERS_H_ */
