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

dict_elem *l_classes_dictionary;

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
  g_slice_set_config(G_SLICE_CONFIG_ALWAYS_MALLOC, 1);
#ifdef MEMORY_ALLOC_CHECK
  GMemVTable vtable = { (gpointer) &xmalloc, (gpointer) &xrealloc, (gpointer) &xfree,
     NULL, NULL, NULL };
#else
  GMemVTable vtable = { (gpointer) &GC_malloc, (gpointer) &GC_realloc,
     (gpointer) &GC_free, NULL, NULL, NULL };
#endif
  g_mem_set_vtable(&vtable);
  clear_cache();
#ifdef OBJECT_COUNT
  sa_count = 0;
  ha_count = 0;
#endif
}

void finalize() {
#ifdef OBJECT_COUNT
  printf("sa_objects: %ld ha_objects:%ld\n", sa_count, ha_count);
#endif
}
void* find_method(int class_id, dict_elem* l_classes_dictionary,
    int fid, char* fname, int len) {
  dict_elem d_elem;
  hash_elem* h_elem;
  cache_elem* c_elem;

  /* Try finding method in cache */
  c_elem = &method_cache[HASH(class_id,fid)];
  if(c_elem->fid == fid && c_elem->cid == class_id)
    return c_elem->function;

  int id = class_id;
  while(1) {
    d_elem = l_classes_dictionary[id];
    if( d_elem.msearch != NULL && (h_elem = d_elem.msearch(fname, len)) != 0 )
      break;
    if(d_elem.parent == -1)
      die("Method \"%s\" in class with id %d not found.\n", fname, class_id);
    id = d_elem.parent;
  }
  if(h_elem->function == NULL)
    die("Method \"%s\" in class with id %d not found.\n", fname, class_id);

  /* Fill cache */
  c_elem->fid = fid;
  c_elem->cid = class_id;
  c_elem->function = h_elem->function;
  
  return h_elem->function;
}

void prepare_argv(Object **ARGV, int argc, char **args) {
  *ARGV = Array_new();
  /* Starting from one, skipping the command name */
  for (int i = 1; i < argc; ++i)
    Array_push(*ARGV, String_new(args[i]));
}

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
