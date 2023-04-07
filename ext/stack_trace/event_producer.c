#include <ruby.h>
#include <ruby/debug.h>

#include "types/event.h"
#include "event_store.h"
#include "current_trace.h"
#include "utils.h"
#include "configuration.h"

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

static VALUE object_name_for_cBasicObject(VALUE object, VALUE klass) {
  VALUE cname;

  if(rb_obj_is_kind_of(klass, rb_cClass)) {
    cname = rb_class_name(klass);
  } else if(rb_obj_is_kind_of(klass, rb_cModule)) {
    cname = rb_mod_name(klass);
  } else {
    return Qundef; // This is still possible!
  }

  return rb_sprintf("#<%"PRIsVALUE":%p>", cname, (void*)object);
}

static VALUE object_name_for_cObject(VALUE object) {
  return rb_funcall(object, rb_intern("st_name"), 0);
}

static VALUE get_object_name(VALUE object, VALUE klass) {
  if(rb_obj_is_kind_of(object, rb_cObject)) {
    return object_name_for_cObject(object);
  } else if(rb_obj_is_kind_of(object, rb_cBasicObject)) {
    return object_name_for_cBasicObject(object, klass);
  } else {
    return Qundef;
  }
}

void create_event(VALUE tp_val, void *_data) {
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

  VALUE receiver = get_object_name(self, klass);

  if(receiver == Qundef) return;

  copy_str(&event.receiver, receiver);

  event.trace = get_current_trace();
  event.tp_val = tp_val;
  event.trace_arg = trace_arg;
  event.event = rb_tracearg_event_flag(trace_arg);
  event.klass = klass;
  event.self_klass = self_klass;
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
    VALUE return_value_st_name = rb_funcall(return_value, rb_intern("st_name"), 0);

    copy_str(&event.return_value, return_value_st_name);
  }

  produce_event(event);
}
