#include <types/span.h>
#include <stdbool.h>

#ifndef TRACE_H
  #define TRACE_H

  typedef struct TraceS Trace;

  struct TraceS {
    Span *top_span;
    Span *current_span;
    bool finished;
    bool active;
  };
#endif
