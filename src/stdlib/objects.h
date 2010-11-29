#ifndef OBJECTS_H_
#define OBJECTS_H_

#include <stdint.h>

typedef struct {
   uint32_t type;
} robject;

typedef struct {
   robject meta;
   int val;
} Fixnum;

typedef struct {
   robject meta;
   double val;
} Float;

#endif /* OBJECTS_H_ */
