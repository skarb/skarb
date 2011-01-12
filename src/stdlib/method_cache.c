#include <string.h>
#include "method_cache.h"

cache_elem method_cache[CACHE_SIZE];

void clear_cache() {
  memset(method_cache, 0, CACHE_SIZE);
}

