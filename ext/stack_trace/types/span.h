#include "types/argument.h"

#ifndef SPAN_H
  #define SPAN_H

  typedef struct SpanS Span;

  struct SpanS {
    long int started_at;
    long int finished_at;

    char *receiver;
    char *klass;
    char *self_klass;
    VALUE method;
    VALUE singleton;
    char *return_value;
    Argument *arguments;
    int arguments_count;
    char *exception;
    Span *caller;
    int children_count;
    Span **children;
  };
#endif
