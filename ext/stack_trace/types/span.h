#ifndef SPAN_H
  #define SPAN_H

  typedef struct SpanS Span;

  struct SpanS {
    long int started_at;
    long int finished_at;

    VALUE klass;
    VALUE self_klass;
    VALUE receiver;
    VALUE method;
    VALUE singleton;
    VALUE exception;
    Span *caller;
    int children_count;
    Span **children;
  };
#endif
