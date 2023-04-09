#include <ruby.h>

#include "debug.h"

void serialize_event(char *buffer, Event *event) {
  switch(event->event) {
    case END_OF_TRACE:
      sprintf(buffer, "End of trace");
      return;
    case END_OF_OBSOLOTE_TRACE_EVENT:
      sprintf(buffer, "End of obsolote trace");
      return;
    case NOOP_EVENT:
      sprintf(buffer, "NO-OP event");
      return;
  }

  VALUE method_name = rb_funcall(event->method, rb_intern("name"), 0);
  char *method_name_str = RSTRING_PTR(method_name);

  sprintf(
    buffer,
    "klass: %s, "
    "self: %s, "
    "method: %s, "
    "event: %d, "
    "for_singleton: %d",
    event->klass,
    event->self_klass,
    method_name_str,
    event->event,
    event->for_singleton
  );
}

void serialize_unknown(char *buffer, void *var) {
  sprintf(buffer, "Address: %p", var);
}
