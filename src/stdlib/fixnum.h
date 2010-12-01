#ifndef FIXNUM_H_
#define FIXNUM_H_

#include "objects.h"

typedef struct {
   Object meta;
   int val;
} Fixnum;

/**
 * Fixnum#new
 */
Fixnum * Fixnum_new(int value);

#endif /* FIXNUM_H_ */
