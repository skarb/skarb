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

#include <string.h>
#include <glib.h>
#include "stringclass.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"
#include "nil.h"
#include "false.h"

s_String vs_String = {{{Class_t}, {String_t}}};

/*
 * Stolen from GLib's gstring.c, adapted for GC_MALLOC_ATOMIC.
 */
static GString* g_string_sized_new_atomic(gsize dfl_size) {
  GString *string = g_slice_new(GString);

  string->allocated_len = dfl_size;
  string->len = 0;
  string->str = xmalloc_atomic(dfl_size);

  string->str[0] = 0;

  return string;
}

/*
 * Stolen from GLib's gstring.c, adapted for GC_MALLOC_ATOMIC.
 */
GString* g_string_new_atomic(const gchar *init) {
  GString *string;

  if (init == NULL || *init == '\0')
      string = g_string_sized_new_atomic(2);
  else {
      gint len;

      len = strlen(init);
      string = g_string_sized_new_atomic(len + 2);

      g_string_append_len(string, init, len);
  }

  return string;
}

Object * String_new(char *value) {
    String *self = xmalloc(sizeof(String));
    set_type(self, String);
    String__INIT(self, value);
    return as_object(self);
}

Object * String__PLUS_(Object *self, Object *other) {
    if (!is_a(other, String))
      die("TypeError");
    const int self_len = as_string(self)->val->len,
              other_len = as_string(other)->val->len;
    char *buffer = g_alloca(self_len + other_len + 1);
    memcpy(buffer, as_string(self)->val->str, self_len + 1);
    memcpy(buffer + self_len, as_string(other)->val->str, other_len + 1);
    return String_new(buffer);
}

Object * String__MUL_(Object *self, Object *other) {
    if (!is_a(other, Fixnum))
      die("TypeError");
    const int self_len = as_string(self)->val->len;
    int times = as_fixnum(other)->val, offset = 0;
    char *buffer = g_alloca(times * self_len + 1);
    while (times--) {
        memcpy(buffer + offset, as_string(self)->val->str, self_len + 1);
        offset += self_len;
    }
    return String_new(buffer);
}

Object * String_length(Object *self) {
    return Fixnum_new(g_utf8_strlen(as_string(self)->val->str, -1));
}

const char * String_to__char__array(Object *self) {
    return as_string(self)->val->str;
}

Object * String_to__s(Object *self) {
    return self;
}

Object * String_to__i(Object *self) {
    return Fixnum_new(atoi(as_string(self)->val->str));
}

Object * String_to__f(Object *self) {
    return Float_new(atof(as_string(self)->val->str));
}

Object * String__INDEX_(Object *self, Object *index) {
    if (!is_a(index, Fixnum))
        die("TypeError");
    if (g_utf8_strlen(as_string(self)->val->str, -1) < as_fixnum(index)->val)
        return nil;
    /*
     * Reserving 6 characters, as required in
     * http://library.gnome.org/devel/glib/stable/glib-Unicode-Manipulation.html
     */
    char buf[6] = {0};
    g_unichar_to_utf8(g_utf8_get_char(
                g_utf8_offset_to_pointer(as_string(self)->val->str,
                    as_fixnum(index)->val)), buf);
    return String_new(buf);
}

Object * String_empty__QMARK__(Object *self) {
    return boolean_to_object(!*as_string(self)->val->str);
}

Object * String__EQ__EQ_(Object *self, Object *other) {
    if (!is_a(other, String))
        return false;
    return boolean_to_object(!g_strcmp0(
                as_string(self)->val->str,
                as_string(other)->val->str));
}
