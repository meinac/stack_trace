#include <ruby.h>

#include "types/trace.h"

Trace *get_current_trace(void);
VALUE rb_create_trace(VALUE _self);
VALUE rb_send_eot(VALUE _self);
