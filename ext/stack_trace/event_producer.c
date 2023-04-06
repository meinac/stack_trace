#include <ruby.h>
#include <ruby/debug.h>

#include "types/event.h"
#include "event_store.h"
#include "current_trace.h"
#include "utils.h"
#include "configuration.h"

VALUE extract_arguments(VALUE tp_val) {
  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE extractor_class = rb_const_get(main_module, rb_intern("ArgumentExtractor"));

  VALUE arguments = rb_funcall(extractor_class, rb_intern("extract"), 1, tp_val);
  rb_gc_register_address(&arguments);

  return arguments;
}

void copy_str(char **target, VALUE string) {
  *target = malloc(sizeof(char) * RSTRING_LEN(string) + 1);

  memcpy(*target, RSTRING_PTR(string), RSTRING_LEN(string));
}

void create_event(VALUE tp_val, void *_data) {
  Event event = {};
  int for_singleton = false;

  rb_trace_arg_t *trace_arg = rb_tracearg_from_tracepoint(tp_val);

  VALUE klass = rb_tracearg_defined_class(trace_arg);
  VALUE self = rb_tracearg_self(trace_arg);
  VALUE receiver = rb_funcall(self, rb_intern("st_name"), 0);
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
  event.method = method;
  event.for_singleton = for_singleton;
  event.return_value = NULL;
  event.arguments = Qundef;
  event.at = get_monotonic_m_secs();

  copy_str(&event.receiver, receiver);

  if(event.event == RUBY_EVENT_RAISE) {
    VALUE exception = rb_tracearg_raised_exception(trace_arg);
    VALUE exception_to_s = rb_funcall(exception, rb_intern("to_s"), 0);

    copy_str(&event.raised_exception, exception_to_s);
  }

  if(RTEST(get_inspect_arguments()) &&
     (event.event == RUBY_EVENT_CALL || event.event == RUBY_EVENT_C_CALL || event.event == RUBY_EVENT_B_CALL))
    event.arguments = extract_arguments(tp_val);

  if(RTEST(get_inspect_return_values()) &&
     (event.event == RUBY_EVENT_RETURN || event.event == RUBY_EVENT_C_RETURN || event.event == RUBY_EVENT_B_RETURN)) {
    VALUE return_value = rb_tracearg_return_value(trace_arg);
    VALUE return_value_st_name = rb_funcall(return_value, rb_intern("st_name"), 0);

    copy_str(&event.return_value, return_value_st_name);
  }

  produce_event(event);
}
