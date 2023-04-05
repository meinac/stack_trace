#include <ruby.h>
#include <ruby/debug.h>

#include "sidecar.h"
#include "event_producer.h"
#include "event_store.h"
#include "current_trace.h"
#include "trace.h"
#include "configuration.h"

static rb_event_flag_t traced_events() {
  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));

  rb_event_flag_t events = 0;

  VALUE configuration = rb_funcall(main_module, rb_intern("configuration"), 0);
  VALUE trace_ruby = rb_funcall(configuration, rb_intern("trace_ruby"), 0);
  VALUE trace_c = rb_funcall(configuration, rb_intern("trace_c"), 0);

  if(RTEST(trace_ruby)) events |= RUBY_EVENT_CALL | RUBY_EVENT_RETURN;
  if(RTEST(trace_c)) events |= RUBY_EVENT_C_CALL | RUBY_EVENT_C_RETURN;
  if(events != 0) events |= RUBY_EVENT_RAISE;

  return events;
}

VALUE rb_trace_point(VALUE self) {
  VALUE tracePoint = rb_iv_get(self, "@trace_point");

  if(NIL_P(tracePoint)) {
    tracePoint = rb_tracepoint_new(Qnil, traced_events(), create_event, NULL);
    rb_iv_set(self, "@trace_point", tracePoint);
  }

  return tracePoint;
}

void Init_stack_trace() {
  rb_ext_ractor_safe(true);

  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE configuration_class = rb_const_get(main_module, rb_intern("Configuration"));

  rb_define_singleton_method(main_module, "trace_point", rb_trace_point, 0);
  rb_define_singleton_method(main_module, "start_trace", rb_create_trace, 0);
  rb_define_singleton_method(main_module, "complete_trace", rb_send_eot, 0);
  rb_define_singleton_method(main_module, "current", rb_get_current_trace, 0);

  rb_define_method(configuration_class, "inspect_return_values=", rb_set_inspect_return_values, 1);
  rb_define_method(configuration_class, "inspect_arguments=", rb_set_inspect_arguments, 1);

  Init_event_store();
  Init_sidecar();
}
