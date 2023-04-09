#include <ruby.h>
#include <ruby/debug.h>

#include "types/event.h"
#include "event_store.h"
#include "current_trace.h"
#include "utils.h"
#include "configuration.h"
#include "st_name.h"

struct MemoS {
  int i;
  Argument *arguments;
};

static void copy_str(char **target, VALUE string) {
  *target = malloc(sizeof(char) * RSTRING_LEN(string) + 1);

  memcpy(*target, RSTRING_PTR(string), RSTRING_LEN(string));
}

static int extract_kv(VALUE key, VALUE value, VALUE data) {
  struct MemoS *memo = (struct MemoS *)data;

  memo->arguments[memo->i].key = key;
  copy_str(&memo->arguments[memo->i].value, value);

  memo->i++;

  return ST_CONTINUE;
}

static void extract_arguments(Event *event, VALUE tp_val) {
  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE extractor_class = rb_const_get(main_module, rb_intern("ArgumentExtractor"));

  VALUE arguments_hash = rb_funcall(extractor_class, rb_intern("extract"), 1, tp_val);
  VALUE hash_size = rb_funcall(arguments_hash, rb_intern("size"), 0);

  int arguments_count = FIX2INT(hash_size);

  if(arguments_count == 0) return;

  event->arguments_count = arguments_count;
  event->arguments = malloc(sizeof(Argument) * arguments_count);

  struct MemoS memo = { 0, event->arguments };

  rb_hash_foreach(arguments_hash, extract_kv, (VALUE)&memo);
}

void create_event(VALUE tp_val, void *_data) {
  Trace *current_trace = get_current_trace();

  // This can happen if a new thread spawns in trace scope.
  // TODO: Save them with their thread identifier.
  if(current_trace == NULL) return;

  Event event = {};
  int for_singleton = false;

  rb_trace_arg_t *trace_arg = rb_tracearg_from_tracepoint(tp_val);

  VALUE klass = rb_tracearg_defined_class(trace_arg);
  VALUE self = rb_tracearg_self(trace_arg);
  VALUE method = rb_tracearg_method_id(trace_arg);
  VALUE self_klass;

  if(FL_TEST(klass, FL_SINGLETON)) {
    for_singleton = true;
    klass = rb_ivar_get(klass, rb_intern("__attached__"));
    self_klass = self;
  } else {
    self_klass = CLASS_OF(self);
  }

  VALUE receiver = st_name(self, klass);
  VALUE klass_name = get_cname(klass);
  VALUE self_klass_name = get_cname(self_klass);

  if(receiver == Qundef || klass_name == Qundef || self_klass_name == Qundef) return;
  if(!rb_obj_is_kind_of(klass_name, rb_cString) || !rb_obj_is_kind_of(self_klass_name, rb_cString)) return; // These values can be Qnil

  copy_str(&event.receiver, receiver);
  copy_str(&event.klass, klass_name);
  copy_str(&event.self_klass, self_klass_name);

  event.trace = current_trace;
  event.event = rb_tracearg_event_flag(trace_arg);
  event.method = method;
  event.for_singleton = for_singleton;
  event.return_value = NULL;
  event.arguments = NULL;
  event.at = get_monotonic_m_secs();

  if(event.event == RUBY_EVENT_RAISE) {
    VALUE exception = rb_tracearg_raised_exception(trace_arg);
    VALUE exception_to_s = rb_funcall(exception, rb_intern("to_s"), 0);

    copy_str(&event.raised_exception, exception_to_s);
  }

  if(RTEST(get_inspect_arguments()) &&
     (event.event == RUBY_EVENT_CALL || event.event == RUBY_EVENT_C_CALL || event.event == RUBY_EVENT_B_CALL))
    extract_arguments(&event, tp_val);

  if(RTEST(get_inspect_return_values()) &&
     (event.event == RUBY_EVENT_RETURN || event.event == RUBY_EVENT_C_RETURN || event.event == RUBY_EVENT_B_RETURN)) {
    VALUE return_value = rb_tracearg_return_value(trace_arg);
    VALUE return_value_class = rb_obj_class(return_value);
    VALUE return_value_st_name = st_name(return_value, return_value_class);

    if(return_value_st_name != Qundef) copy_str(&event.return_value, return_value_st_name);
  }

  produce_event(event);
}
