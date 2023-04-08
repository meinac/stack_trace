#include "st_name.h"

static VALUE extract_st_name(VALUE object) {
  return rb_funcall(object, rb_intern("st_name"), 0);
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

static VALUE object_name_for_cObject(VALUE object, VALUE klass) {
  int status;

  VALUE st_name = rb_protect(extract_st_name, object, &status);

  if(status != 0) {
    rb_set_errinfo(Qnil);

    return object_name_for_cBasicObject(object, klass);
  } else {
    return st_name;
  }
}

VALUE st_name(VALUE object, VALUE klass) {
  if(rb_obj_is_kind_of(object, rb_cObject)) {
    return object_name_for_cObject(object, klass);
  } else if(rb_obj_is_kind_of(object, rb_cBasicObject)) {
    return object_name_for_cBasicObject(object, klass);
  } else {
    return Qundef;
  }
}
