#ifndef FLOAT_H_
#define FLOAT_H_

#include "object.h"

typedef struct {
   Object meta;
   double val;
} Float;

/**
 * Float#new
 */
Object * Float_new(double value);

#endif /* FLOAT_H_ */
