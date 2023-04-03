/*
* Implements a ring buffer which blocks the producer if
* there is no space left and blocks the consumer if
* there is no event available in the queue.
*/

#include <stdlib.h>
#include <pthread.h>
#include <ruby/digest.h>

#include "types/event.h"
#include "debug.h"

#define SIZE 1000

pthread_cond_t has_space = PTHREAD_COND_INITIALIZER;
pthread_cond_t has_event = PTHREAD_COND_INITIALIZER;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

static Event **store;
int producer_cursor = 0, consumer_cursor = 0, free_space = SIZE;

void Init_event_store() {
  store = malloc(sizeof(Event *) * SIZE);

  int i;

  for(i = 0; i < SIZE; i++) {
    store[i] = malloc(sizeof(Event));
  }
}

static void wait_free_space() {
  if(free_space == 0) pthread_cond_wait(&has_space, &lock);
}

static void wait_event() {
  if(free_space == SIZE) {
    DEBUG_TEXT("No event left, checking for interrupts.");

    rb_thread_check_ints(); // Otherwise the GC stucks!

    pthread_cond_wait(&has_event, &lock);
  }
}

static Event *claim_event() {
  producer_cursor = producer_cursor % SIZE;

  wait_free_space();

  return store[producer_cursor++];
}

static Event *pull_event() {
  consumer_cursor = consumer_cursor % SIZE;

  wait_event();

  return store[consumer_cursor++];
}

static void event_produced() {
  DEBUG_TEXT("Event produced. Free space: %d", free_space - 1);

  free_space--;

  pthread_cond_signal(&has_event);
}

static void event_consumed() {
  free_space++;

  pthread_cond_signal(&has_space);
}

// Takes a callback function which populates the event information.
void produce_event(Event event) {
  pthread_mutex_lock(&lock);

  Event *slot = claim_event();

  memcpy(slot, &event, sizeof(Event));

  event_produced();

  pthread_mutex_unlock(&lock);
}

// Takes a callback function which consumes the event.
void consume_event(void(*processor_func)(Event *event)) {
  pthread_mutex_lock(&lock);

  Event *event = pull_event();

  processor_func(event);

  event_consumed();

  pthread_mutex_unlock(&lock);
}
