#ifndef CLASS_H_
#define CLASS_H_

#include "object.h"

typedef struct {
  Object parent; 
  Object ctype;
} Class;

typedef struct {
   Class meta;
} s_Class;
extern s_Class vs_Class;

typedef struct {
   Class meta;
} s_Object;
extern s_Object vs_Object;

#define as_class(obj) ((Class *)(obj))

#endif /* CLASS_H_ */
