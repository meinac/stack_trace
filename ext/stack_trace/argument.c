#include "argument.h"

void free_arguments(Argument *arguments, int count) {
  int i;

  for(i = 0; i < count; i++) {
    if(arguments[i].value != NULL) free(arguments[i].value);
  }

  free(arguments);
}
