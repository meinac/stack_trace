#ifndef SPAN_H
  #define SPAN_H

  typedef struct SpanS Span;

  struct SpanS {
    long int started_at;
    long int finished_at;

    VALUE klass;
    VALUE method;
    VALUE singleton;
    Span *caller;
    int children_count;
    Span **children;
  };
#endif
