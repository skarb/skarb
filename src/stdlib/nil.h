#ifndef NIL_H_
#define NIL_H_

#include "object.h"
#include "class.h"

typedef Object NilClass;

extern NilClass *nil;
extern sObject vsNilClass;

/**
 * Nil#to_s
 */
Object *Nil_to_s(Object *self);

#endif /* NIL_H_ */
