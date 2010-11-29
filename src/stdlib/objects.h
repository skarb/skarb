#ifndef OBJECTS_H_
#define OBJECTS_H_

#include <stdint.h>

typedef struct {
   uint32_t type;
} Object;

#define TO_OBJECT(obj) ((Object *)(obj))

typedef struct {
   Object meta;
   int val;
} Fixnum;

typedef struct {
   Object meta;
   double val;
} Float;

#endif /* OBJECTS_H_ */
