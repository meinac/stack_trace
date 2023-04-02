#include <ruby.h>
#include <stdbool.h>
#include <ruby/debug.h>

#include "event_store.h"
#include "event_processor.h"

static bool running = false;
static VALUE ractor;

static VALUE listen_events(VALUE data, VALUE m, int _argc, const VALUE *_argv, VALUE _) {
  running = true;

  while(running) {
    consume_event(&event_processor);
  }

  return Qtrue;
}

static VALUE rb_run(VALUE self) {
  if(running) return Qnil;

  // I will need to register at_exit and kill this thread while closing the application
  VALUE ractor_module = rb_const_get(rb_cObject, rb_intern("Ractor"));
  ractor = rb_block_call(ractor_module, rb_intern("new"), 0, NULL, &listen_events, (VALUE)NULL);

  return Qtrue;
}

static VALUE rb_stop(VALUE self) {
  if(!running) return Qnil;

  running = false;

  // The sidecar might be waiting for an event to arrive
  // so here we are sending a no-op event to break the loop.
  // Same could be done by using `pthread_cond_timedwait` but
  // then I have to do more changes.
  Event event = {};
  event.event = NOOP_EVENT;

  produce_event(event);

  return Qtrue;
}

static VALUE rb_is_running(VALUE self) {
  return running ? Qtrue : Qfalse;
}

void Init_sidecar() {
  VALUE main_module = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE sidecar_class = rb_define_class_under(main_module, "Sidecar", rb_cObject);

  rb_define_singleton_method(sidecar_class, "run", rb_run, 0);
  rb_define_singleton_method(sidecar_class, "stop", rb_stop, 0);
  rb_define_singleton_method(sidecar_class, "running?", rb_is_running, 0);
}
