#include <sys/time.h>

long int get_monotonic_m_secs() {
  struct timespec at;
  clock_gettime(CLOCK_MONOTONIC_RAW, &at);

  return at.tv_sec * 1000000 + at.tv_nsec / 1000;
}
