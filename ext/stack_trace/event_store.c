/*
* Implements a ring buffer which blocks the producer if
* there is no space left and blocks the consumer if
* there is no event available in the queue.
*/

#include <stdlib.h>
#include <pthread.h>
#include <ruby/digest.h>
#include <time.h>

#include "types/event.h"
#include "debug.h"

#define SIZE 1000
#define TEN_MILLISECONDS 10000000

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

static int wait_event() {
  if(free_space == SIZE) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    ts.tv_nsec += TEN_MILLISECONDS;

    return pthread_cond_timedwait(&has_event, &lock, &ts); // returns 0 if the thread gets signal from another one
  }

  return 0;
}

static Event *claim_event() {
  producer_cursor = producer_cursor % SIZE;

  wait_free_space();

  return store[producer_cursor++];
}

static Event *pull_event() {
  consumer_cursor = consumer_cursor % SIZE;

  if(wait_event() != 0) return NULL; // either timeout or an error

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

void produce_event(Event event) {
  pthread_mutex_lock(&lock);

  Event *slot = claim_event();

  memcpy(slot, &event, sizeof(Event));

  event_produced();

  pthread_mutex_unlock(&lock);
}

void get_event(Event *target, int *status) {
  pthread_mutex_lock(&lock);
  *status = 1;

  Event *event = pull_event();

  if(event != NULL) {
    *status = 0;
    memcpy(target, event, sizeof(Event));

    event_consumed();
  }

  pthread_mutex_unlock(&lock);
}
