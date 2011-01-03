#ifndef FALSE_H_
#define FALSE_H_

#include "object.h"
#include "class.h"

typedef Object FalseClass;

extern FalseClass *false;
extern s_Object vs_FalseClass;

/**
 * False#to_s
 */
Object *False_to__s(Object *self);

#endif /* FALSE_H_ */
