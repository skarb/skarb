#ifndef FALSE_H_
#define FALSE_H_

#include "object.h"

typedef Object FalseClass;

extern FalseClass *false;
extern sObject vsFalseClass;

/**
 * False#to_s
 */
Object *False_to_s(Object *self);

#endif /* FALSE_H_ */
