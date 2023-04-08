#include <ruby.h>
#include <pthread.h>
#include <ruby/debug.h>
#include <ruby/thread.h>
#include <stdbool.h>

#include "types/trace.h"
#include "span.h"
#include "debug.h"
#include "current_trace.h"

static VALUE check_proc;

pthread_cond_t trace_finished = PTHREAD_COND_INITIALIZER;
pthread_mutex_t trace_access_mutex = PTHREAD_MUTEX_INITIALIZER;

void free_trace(Trace *trace) {
  free_span(trace->top_span);
  free(trace);
}

void process_obsolote_event(Event *event) {
  // Free this trace as there is no reference to it anymore!
  free_trace(event->trace);
}

void set_check_proc(VALUE proc) {
  check_proc = proc;
}

static VALUE call_proc(VALUE val) {
  Event *event = (Event *)val;

  return rb_funcall(check_proc, rb_intern("call"), 2, event->self_klass, event->method);
}

bool is_tracked_event(Event *event) {
  if(!RTEST(check_proc)) return true; // Check proc is not configured, all the events will be tracked.

  int state;
  VALUE result = rb_protect(call_proc, (VALUE)event, &state); // I don't really like allocating a new array for each call so that's why I use this hack!

  if(state != 0) {
    rb_p(rb_errinfo());

    rb_set_errinfo(Qnil);
  }

  return RTEST(result);
}

void create_new_span(Event *event) {
  if(!is_tracked_event(event)) return;

  Span *new_span = create_span(event);

  add_child(event->trace->current_span, new_span);

  event->trace->current_span = new_span;
}

void close_current_span(Event *event) {
  if(!is_tracked_event(event)) return;

  Trace *trace = event->trace;

  trace->current_span = close_span(trace->current_span, event);
}

void attach_exception(Event *event) {
  Trace *trace = event->trace;

  trace->current_span->exception = event->raised_exception;
}

void close_current_trace(Event *event) {
  pthread_mutex_lock(&trace_access_mutex);
  event->trace->finished = true;
  pthread_cond_broadcast(&trace_finished);
  pthread_mutex_unlock(&trace_access_mutex);
}

void process_event(Event *event) {
  DEBUG("Event received: ", event);

  switch (event->event) {
    case RUBY_EVENT_CALL:
    case RUBY_EVENT_C_CALL:
    case RUBY_EVENT_B_CALL:
      return create_new_span(event);
    case RUBY_EVENT_RETURN:
    case RUBY_EVENT_C_RETURN:
    case RUBY_EVENT_B_RETURN:
      return close_current_span(event);
    case RUBY_EVENT_RAISE:
      return attach_exception(event);
    case END_OF_TRACE:
      return close_current_trace(event);
    case END_OF_OBSOLOTE_TRACE_EVENT:
      return process_obsolote_event(event);
  }
}

// Ruby threads are preemptive(from the kernel and Ruby programmer POV) but forced to be
// cooperative by the VM, therefore, if we don't yield back, other threads won't have chance to run.
// For this reason, we need to call this function with `rb_thread_call_without_gvl` to release the GVL
// while waiting for the trace to be ready without blocking other Ruby programmer-level threads.
void ensure_trace_is_finished() {
  pthread_mutex_lock(&trace_access_mutex);

  while(!get_current_trace()->finished) { // This is the easiest way to wait for the related trace, not the most efficient one though!
    DEBUG_TEXT("Waiting for the trace to be ready...");

    pthread_cond_wait(&trace_finished, &trace_access_mutex);
  }

  pthread_mutex_unlock(&trace_access_mutex);
}

Trace *get_current_trace_without_gvl() {
  rb_thread_call_without_gvl((void *)ensure_trace_is_finished, NULL, NULL, NULL);

  return get_current_trace();
}

VALUE to_ruby_hash(Trace *trace) {
  VALUE hash = rb_hash_new();

  rb_hash_aset(hash, rb_str_new2("spans"), to_ruby_array(trace->top_span->children_count, trace->top_span->children));

  return hash;
}

VALUE rb_get_current_trace(VALUE _self) {
  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE tracePoint = rb_iv_get(main_module, "@trace_point");
  VALUE is_tracepoint_enabled = rb_funcall(tracePoint, rb_intern("enabled?"), 0);

  if(RTEST(is_tracepoint_enabled)) rb_raise(rb_eRuntimeError, "Trace is active!");

  Trace *trace = get_current_trace_without_gvl();
  VALUE ruby_hash = to_ruby_hash(trace);

  return ruby_hash;
}
