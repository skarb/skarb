#ifndef NIL_H_
#define NIL_H_

#include "object.h"
#include "class.h"

typedef Object NilClass;

extern NilClass *nil;
extern s_Object vs_NilClass;

/**
 * Nil#to_s
 */
Object *Nil_to_s(Object *self);

#endif /* NIL_H_ */
