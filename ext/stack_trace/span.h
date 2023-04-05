#include <ruby.h>
#include <types/event.h>
#include <types/span.h>

Span *create_span(Event *event);
Span *add_child(Span *parent, Span *child);
Span *close_span(Span *span, Event *event);
void free_span(Span *span);
VALUE to_ruby_array(int count, Span **span);
