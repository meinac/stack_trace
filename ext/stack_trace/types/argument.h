#include <ruby.h>

#ifndef ARGUMENT_H
  #define ARGUMENT_H

  typedef struct ArgumentS Argument;

  struct ArgumentS {
    VALUE key;
    char *value;
  };
#endif
