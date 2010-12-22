/*
 * Unfortunately this file cannot be named 'string.h' because it's reserved by
 * the POSIX header library. Thus both this file and string.c are named
 * stringclass.{ch}.
 */
#ifndef STRING_H_
#define STRING_H_

#include "object.h"
#include "class.h"

/*
 * Was glib.h included? Define a fake GString type if it wasn't.
 */
#ifndef GLIB_MAJOR_VERSION
typedef void GString;
#endif /* GString */

typedef struct {
   Object parent;
   GString *val;
} String;

typedef struct {
   Class meta;
} sString;
extern sString vsString;

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

/**
 * String#to_s
 */
Object * String_to_s(Object *self);

/**
 * String#to_i
 */
Object * String_to_i(Object *self);

/**
 * String#to_f
 */
Object * String_to_f(Object *self);

/**
 * String#[]
 */
Object * String__INDEX_(Object *self, Object *index);

/**
 * String#empty?
 */
Object * String_empty__QMARK__(Object *self);

/**
 * String#==
 */
Object * String__EQ__EQ_(Object *self, Object *other);

#endif /* STRING_H_ */
