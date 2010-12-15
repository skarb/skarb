/*
 * Unfortunately this file cannot be named 'string.h' because it's reserved by
 * the POSIX header library. Thus both this file and string.c are named
 * stringclass.{ch}.
 */
#ifndef STRING_H_
#define STRING_H_

#include "object.h"

/*
 * Was glib.h included? Define a fake GString type if it wasn't.
 */
#ifndef GLIB_MAJOR_VERSION
typedef void GString;
#endif /* GString */

typedef struct {
   Object meta;
   GString *val;
} String;

/**
 * Casts a given Object to String.
 */
#define as_string(obj) ((String*) (obj))

/**
 * String#new
 */
Object * String_new(char *value);

/**
 * String#+
 */
Object * String__PLUS_(Object *self, Object *other);

/**
 * String#*
 */
Object * String__MUL_(Object *self, Object *other);

/**
 * String#length
 */
Object * String_length(Object *self);

/**
 * Returns a char array which stores the string.
 */
const char * String_to_char_array(Object *self);

#endif /* STRING_H_ */
