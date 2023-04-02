#include "debug.h"

void serialize_event(Event *event) {
  printf(
    "klass: %ld, "
    "self: %ld, "
    "event: %d, "
    "for_singleton: %d",
    event->klass,
    event->self,
    event->event,
    event->for_singleton
  );
}

void serialize_unknown(void *var) {
  printf("Address: %p", var);
}
