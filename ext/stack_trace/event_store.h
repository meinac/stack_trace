#include "types/event.h"

void Init_event_store();
void produce_event(Event event);
void get_event(Event *target, int *status);
