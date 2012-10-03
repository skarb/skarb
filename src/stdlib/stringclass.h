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
