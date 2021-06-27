#include <ruby.h>

#ifdef __has_include
  #if __has_include(<uuid/uuid.h>)
    #define HAS_UUID 1
    #include <uuid/uuid.h>
  #endif
#endif

#ifdef HAS_UUID
  static VALUE rb_uuid(VALUE self) {
    uuid_t binuuid;
    uuid_generate_random(binuuid);
    char uuid[37];
    uuid_unparse(binuuid, uuid);
    VALUE rb_uuid = rb_str_new(uuid, 36);

    return rb_uuid;
  }
#endif

void Init_stack_trace() {
  VALUE mainModule = rb_const_get(rb_cObject, rb_intern("StackTrace"));
  VALUE utilsModule = rb_const_get(mainModule, rb_intern("Utils"));

  #ifdef HAS_UUID
    rb_define_singleton_method(utilsModule, "uuid", rb_uuid, 0);
  #endif
}
