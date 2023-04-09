#define _POSIX_C_SOURCE 199309L

#include <sys/time.h>
#include <time.h>

long int get_monotonic_m_secs() {
  struct timespec at;
  clock_gettime(CLOCK_MONOTONIC_RAW, &at);

  return at.tv_sec * 1000000 + at.tv_nsec / 1000;
}
