#include <stdint.h>

typedef struct
{
   uint32_t type;
} robject;

typedef struct
{
   uint32_t type;
   int val;
} Fixnum;

typedef struct
{
   uint32_t type;
   double val;
} Float;

