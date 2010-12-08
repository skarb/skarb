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
 * String#new
 */
Object * String_new(char *value);

#endif /* STRING_H_ */
