#include <ruby.h>
#include <ruby/debug.h>

#include "types/event.h"
#include "event_store.h"
#include "current_trace.h"
#include "utils.h"

void create_event(VALUE tp_val, void *_data) {
  Event event = {};
  int for_singleton = false;

  rb_trace_arg_t *trace_arg = rb_tracearg_from_tracepoint(tp_val);

  VALUE klass = rb_tracearg_defined_class(trace_arg);
  VALUE self = rb_tracearg_self(trace_arg);
  VALUE method = rb_tracearg_method_id(trace_arg);
  VALUE self_klass;

  if(FL_TEST(klass, FL_SINGLETON)) {
    klass = rb_ivar_get(klass, rb_intern("__attached__"));
    for_singleton = true;
    self_klass = rb_funcall(self, rb_intern("name"), 0);
  } else {
    VALUE class = rb_funcall(self, rb_intern("class"), 0);
    self_klass = rb_funcall(class, rb_intern("name"), 0);
  }

  event.trace = get_current_trace();
  event.tp_val = tp_val;
  event.trace_arg = trace_arg;
  event.event = rb_tracearg_event_flag(trace_arg);
  event.klass = klass;
  event.self_klass = self_klass;
  event.receiver = rb_funcall(self, rb_intern("st_name"), 0);
  event.method = method;
  event.for_singleton = for_singleton;
  event.at = get_monotonic_m_secs();

  if(event.event == RUBY_EVENT_RAISE)
    event.raised_exception = rb_tracearg_raised_exception(trace_arg);

  produce_event(event);
}
