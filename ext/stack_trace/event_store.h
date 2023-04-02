#include "types/event.h"

void Init_event_store();
void produce_event(Event event);
void consume_event(void(*func)(Event *event));
