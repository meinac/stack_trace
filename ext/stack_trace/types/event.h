#include <ruby.h>
#include <ruby/debug.h>
#include <types/trace.h>
#include <stdbool.h>
#include <sys/time.h>

#ifndef EVENT_H
  #define EVENT_H

  #define END_OF_TRACE 0xfffffff0
  #define END_OF_OBSOLOTE_TRACE_EVENT 0xffffffff
  #define NOOP_EVENT 0xfffffff1

  typedef struct EventS Event;

  struct EventS {
    Trace *trace;
    VALUE tp_val;
    rb_event_flag_t event;
    rb_trace_arg_t *trace_arg;
    VALUE klass;
    VALUE self;
    VALUE method;
    bool for_singleton;
    long int at;
  };
#endif
