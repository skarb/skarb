/*
 * Unfortunately this file cannot be named 'string.h' because it's reserved by
 * the POSIX header library. Thus both this file and string.c are named
 * stringclass.{ch}.
 */
#ifndef STRING_H_
#define STRING_H_

#include "object.h"

typedef struct {
   Object meta;
   char *val;
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

#endif /* STRING_H_ */
