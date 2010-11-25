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
