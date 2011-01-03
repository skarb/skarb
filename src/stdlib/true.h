#ifndef TRUE_H_
#define TRUE_H_

#include "object.h"
#include "class.h"

typedef Object TrueClass;

extern TrueClass *true;
extern s_Object vs_TrueClass;

/**
 * True#to_s
 */
Object *True_to__s(Object *self);

#endif /* TRUE_H_ */
