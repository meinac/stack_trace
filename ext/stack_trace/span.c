#include "span.h"
#include "utils.h"

#define CHILDREN_BUF_INC_SIZE 10

Span *create_span(Event *event) {
  Span *span = malloc(sizeof(Span));

  span->started_at = event->at;
  span->receiver = event->receiver;
  span->klass = event->klass;
  span->self_klass = event->self_klass;
  span->method = event->method;
  span->return_value = Qundef;
  span->arguments = event->arguments;
  span->exception = NULL;
  span->children_count = 0;
  span->singleton = event->for_singleton ? Qtrue : Qfalse;

  return span;
}

static void allocate_children_buf(Span *parent) {
  parent->children = malloc(CHILDREN_BUF_INC_SIZE * sizeof(Span *));
}

static void reallocate_children_buf(Span *parent) {
  size_t new_size = ((parent->children_count / CHILDREN_BUF_INC_SIZE) + 1) * CHILDREN_BUF_INC_SIZE * sizeof(Span *);

  parent->children = realloc(parent->children, new_size);
}

Span *add_child(Span *parent, Span *child) {
  if(parent->children_count == 0) allocate_children_buf(parent);
  if(parent->children_count % CHILDREN_BUF_INC_SIZE == 0) reallocate_children_buf(parent);

  parent->children[parent->children_count] = child;
  parent->children_count++;
  child->caller = parent;

  return child;
}

Span *close_span(Span *span, Event *event) {
  span->finished_at = event->at;
  span->return_value = event->return_value;

  return span->caller;
}


// Deallocate the memory occupied by span
// and its children.
void free_span(Span *span) {
  int i;

  if(span->children_count > 0) {
    for(i = 0; i < span->children_count; i++)
      free_span(span->children[i]);

    free(span->children);
  }

  free(span);
}

int duration_of(Span *span) {
  return (int)(span->finished_at - span->started_at);
}

VALUE span_to_ruby_hash(Span *span) {
  VALUE hash = rb_hash_new();

  rb_hash_aset(hash, rb_str_new2("receiver"), rb_str_new_cstr(RSTRING_PTR(span->receiver)));
  rb_hash_aset(hash, rb_str_new2("defined_class"), span->klass);
  rb_hash_aset(hash, rb_str_new2("self_class"), span->self_klass);
  rb_hash_aset(hash, rb_str_new2("method_name"), span->method);
  rb_hash_aset(hash, rb_str_new2("singleton"), span->singleton);
  rb_hash_aset(hash, rb_str_new2("duration"), INT2FIX(duration_of(span)));
  rb_hash_aset(hash, rb_str_new2("spans"), to_ruby_array(span->children_count, span->children));

  rb_gc_register_address(&span->receiver);

  if(span->exception != NULL)
    rb_hash_aset(hash, rb_str_new2("exception"), rb_str_new_cstr(span->exception));

  if(span->return_value != Qundef)
    rb_hash_aset(hash, rb_str_new2("return_value"), rb_funcall(span->return_value, rb_intern("st_name"), 0));

  if(span->arguments != Qundef) {
    rb_gc_unregister_address(&span->arguments);

    rb_hash_aset(hash, rb_str_new2("arguments"), span->arguments);
  }

  return hash;
}

VALUE to_ruby_array(int count, Span **spans) {
  int i;
  VALUE children = rb_ary_new();

  for(i = 0; i < count; i++) {
    rb_ary_push(children, span_to_ruby_hash(spans[i]));
  }

  return children;
}
