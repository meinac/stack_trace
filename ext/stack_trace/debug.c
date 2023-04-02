#include <ruby.h>

#include "debug.h"

void serialize_event(Event *event) {
  switch(event->event) {
    case END_OF_TRACE:
      printf("End of trace");
      return;
    case END_OF_OBSOLOTE_TRACE_EVENT:
      printf("End of obsolote trace");
      return;
    case NOOP_EVENT:
      printf("NO-OP event");
      return;
  }

  VALUE klass_name = rb_funcall(event->klass, rb_intern("name"), 0);
  VALUE self_name = rb_funcall(event->self, rb_intern("name"), 0);
  VALUE method_name = rb_funcall(event->method, rb_intern("name"), 0);

  char *klass_name_str = RSTRING_PTR(klass_name);
  char *self_name_str = RSTRING_PTR(self_name);
  char *method_name_str = RSTRING_PTR(method_name);

  printf(
    "klass: %s, "
    "self: %s, "
    "method: %s, "
    "event: %d, "
    "for_singleton: %d",
    klass_name_str,
    self_name_str,
    method_name_str,
    event->event,
    event->for_singleton
  );
}

void serialize_unknown(void *var) {
  printf("Address: %p", var);
}
