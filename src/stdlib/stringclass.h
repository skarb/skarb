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
typedef char gchar;
#endif /* GString */

typedef struct {
   Object parent;
   GString *val;
} String;

typedef struct {
   Class meta;
} s_String;
extern s_String vs_String;

/**
 * Casts a given Object to String.
 */
#define as_string(obj) ((String*) (obj))

/**
 * Inits internal data.
 */
#define String__INIT(x,y) (as_string(x)->val = g_string_new_atomic(y))

/*
 * Stolen from GLib's gstring.c, adapted for GC_MALLOC_ATOMIC.
 */
GString* g_string_new_atomic(const gchar *init);

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
const char * String_to__char__array(Object *self);

/**
 * String#to_s
 */
Object * String_to__s(Object *self);

/**
 * String#to_i
 */
Object * String_to__i(Object *self);

/**
 * String#to_f
 */
Object * String_to__f(Object *self);

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
