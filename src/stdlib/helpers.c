#include <stdlib.h>
#include "helpers.h"
#include "object.h"

int boolean_value(Object *object) {
  return object != NULL;
}
