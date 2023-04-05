#include <ruby.h>

#include "types/event.h"

void process_event(Event *event);
VALUE rb_get_current_trace(VALUE _self);
Trace *get_current_trace();
