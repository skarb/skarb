#ifndef CLASS_H_
#define CLASS_H_

#include "object.h"

typedef struct {
  Object parent; 
  Object ctype;
} Class;

typedef struct {
   Class meta;
} sClass;
extern sClass vsClass;

typedef struct {
   Class meta;
} sObject;
extern sObject vsObject;

#define as_class(obj) ((Class *)(obj))

#endif /* CLASS_H_ */
