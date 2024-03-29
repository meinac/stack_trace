#include <ruby.h>

static VALUE inspect_return_values = Qfalse;
static VALUE inspect_arguments = Qfalse;

// We are setting this static variable to gain some performance.
// Otherwise each time we need this, we would need to get the constant
// and make method calls.
VALUE rb_set_inspect_return_values(VALUE self, VALUE val) {
  return inspect_return_values = val;
}

VALUE get_inspect_return_values() {
  return inspect_return_values;
}

VALUE rb_set_inspect_arguments(VALUE self, VALUE val) {
  return inspect_arguments = val;
}

VALUE get_inspect_arguments() {
  return inspect_arguments;
}
