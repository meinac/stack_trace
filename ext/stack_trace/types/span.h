#ifndef SPAN_H
  #define SPAN_H

  typedef struct SpanS Span;

  struct SpanS {
    long int started_at;
    long int finished_at;

    char *receiver;
    VALUE klass;
    VALUE self_klass;
    VALUE method;
    VALUE singleton;
    VALUE return_value;
    VALUE arguments;
    char *exception;
    Span *caller;
    int children_count;
    Span **children;
  };
#endif
