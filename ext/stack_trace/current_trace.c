#include "current_trace.h"
#include "event_store.h"
#include "types/event.h"

static __thread Trace *current_trace = NULL;

Trace *get_current_trace() {
  return current_trace;
}

VALUE rb_create_trace(VALUE _self) {
  if(current_trace != NULL) {
    current_trace->active = false;

    Event event = {};
    event.trace = current_trace;
    event.event = END_OF_OBSOLOTE_TRACE_EVENT;

    produce_event(event); // This will tell sidecar to free the memory
  }

  Span *span = malloc(sizeof(Span));
  span->children_count = 0;
  span->caller = NULL;

  current_trace = malloc(sizeof(Trace));
  current_trace->finished = false;
  current_trace->top_span = span;
  current_trace->current_span = span;
  current_trace->active = true;

  return Qtrue;
}

VALUE rb_send_eot(VALUE _self) {
  Event event = {};
  event.trace = current_trace;
  event.event = END_OF_TRACE;

  produce_event(event);

  return Qtrue;
}
