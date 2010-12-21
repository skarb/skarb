#ifndef TRUE_H_
#define TRUE_H_

#include "object.h"
#include "class.h"

typedef Object TrueClass;

extern TrueClass *true;
extern sObject vsTrueClass;

/**
 * True#to_s
 */
Object *True_to_s(Object *self);

#endif /* TRUE_H_ */
