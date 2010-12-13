#include <stdlib.h>
#include "helpers.h"
#include "object.h"
#include "nil.h"

int boolean_value(Object *object) {
  return object != nil;
}
