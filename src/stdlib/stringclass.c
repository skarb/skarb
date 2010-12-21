#include <string.h>
#include <glib.h>
#include "stringclass.h"
#include "xalloc.h"
#include "object.h"
#include "types.h"
#include "helpers.h"
#include "fixnum.h"

sString vsString = {{{Class_t}, {String_t}}};

Object * String_new(char *value) {
    String *self = xmalloc(sizeof(String));
    set_type(self, String);
    self->val = g_string_new(value);
    return as_object(self);
}

Object * String__PLUS_(Object *self, Object *other) {
    if (!is_a(other, String))
      die("TypeError");
    const int self_len = as_string(self)->val->len,
              other_len = as_string(other)->val->len;
    char *buffer = g_alloca(self_len + other_len + 1);
    strncpy(buffer, as_string(self)->val->str, self_len + 1);
    strncpy(buffer + self_len, as_string(other)->val->str, other_len + 1);
    return String_new(buffer);
}

Object * String__MUL_(Object *self, Object *other) {
    if (!is_a(other, Fixnum))
      die("TypeError");
    const int self_len = as_string(self)->val->len;
    int times = as_fixnum(other)->val, offset = 0;
    char *buffer = g_alloca(times * self_len + 1);
    while (times--) {
        strncpy(buffer + offset, as_string(self)->val->str, self_len + 1);
        offset += self_len;
    }
    return String_new(buffer);
}

Object * String_length(Object *self) {
    // Works only with UTF-8.
    char *arr = as_string(self)->val->str;
    int chars = 0, byte = 0;
    while (arr[byte]) {
        if ((arr[byte] & 0xc0) != 0x80)
            ++chars;
        ++byte;
    }
    return Fixnum_new(chars);
}

const char * String_to_char_array(Object *self) {
    return as_string(self)->val->str;
}

Object * String_to_s(Object *self) {
    return self;
}
