#ifndef FIXNUM_H_
#define FIXNUM_H_

#include "object.h"

typedef struct {
   Object meta;
   int val;
} Fixnum;

/**
 * Fixnum#new
 */
Object * Fixnum_new(int value);

#endif /* FIXNUM_H_ */
