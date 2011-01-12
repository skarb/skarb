#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <glib.h>
#include <gc.h>
#include <errno.h>
#include <string.h>
#include "helpers.h"
#include "object.h"
#include "nil.h"
#include "true.h"
#include "false.h"
#include "fixnum.h"
#include "xalloc.h"
#include "array.h"
#include "stringclass.h"
#include "method_cache.h"

int boolean_value(Object *object) {
  return object != nil && object != false;
}

Object * not(Object *object) {
  return boolean_to_object(!boolean_value(object));
}

Object * boolean_to_object(int value) {
  return value ? true : false;
}

void die(const char *format, ...) {
  va_list ap;
  va_start(ap, format);
  vfprintf(stderr, format, ap);
  exit(1);
}

void initialize() {
  GC_INIT();
  if (setenv("G_SLICE", "always-malloc", FALSE))
    die("setenv: %s\n", strerror(errno));
  GMemVTable vtable = { &xmalloc, &xrealloc, &xfree, NULL, NULL, NULL };
  g_mem_set_vtable(&vtable);
  clear_cache();
}

Object* call_method(int class_id, dict_elem* classes_dictionary,
    int fid, char* fname, int len, Object** args) {
  dict_elem d_elem;
  hash_elem* h_elem;
  cache_elem* c_elem;

  /* Try finding method in cache */
  c_elem = &method_cache[HASH(class_id,fid)];
  if(c_elem->fid == fid && c_elem->cid == class_id)
    return c_elem->wrapper(args, c_elem->function);

  int id = class_id;
  while(1) {
    d_elem = classes_dictionary[id];
    if( d_elem.msearch != NULL && (h_elem = d_elem.msearch(fname, len)) != 0 )
      break;
    if(d_elem.parent == -1)
      die("Method \"%s\" in class with id %d not found.\n", fname, class_id);
    id = d_elem.parent;
  }
  if(h_elem->wrapper == NULL)
    die("Method \"%s\" in class with id %d not found.\n", fname, class_id);

  /* Fill cache */
  c_elem->fid = fid;
  c_elem->cid = class_id;
  c_elem->wrapper = h_elem->wrapper;
  c_elem->function = h_elem->function;
  
  return h_elem->wrapper(args, h_elem->function);
}

void prepare_argv(Object **ARGV, int argc, char **args) {
  *ARGV = Array_new();
  /* Starting from one, skipping the command name */
  for (int i = 1; i < argc; ++i)
    Array_push(*ARGV, String_new(args[i]));
}
