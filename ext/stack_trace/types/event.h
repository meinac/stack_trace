#include <ruby.h>
#include <ruby/debug.h>
#include <types/trace.h>
#include <stdbool.h>
#include <sys/time.h>

#include "types/argument.h"

#ifndef EVENT_H
  #define EVENT_H

  #define END_OF_TRACE 0xfffffff0
  #define END_OF_OBSOLOTE_TRACE_EVENT 0xffffffff
  #define NOOP_EVENT 0xfffffff1

  typedef struct EventS Event;

  struct EventS {
    Trace *trace;
    rb_event_flag_t event;
    char *receiver;
    VALUE klass;
    VALUE self_klass;
    VALUE method;
    char *return_value;
    Argument *arguments;
    int arguments_count;
    char *raised_exception;
    bool for_singleton;
    long int at;
  };
#endif
