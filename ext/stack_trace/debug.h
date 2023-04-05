#include "types/event.h"

#ifdef ST_DEBUG
  void serialize_event(char *buffer, Event *event);
  void serialize_unknown(char *buffer, void *var);

  #define SERIALIZE_STRUCT(s, buffer) \
    _Generic((s),                     \
      Event*: serialize_event,        \
      default: serialize_unknown      \
    )(buffer, s)

  #define DEBUG(msg, s)                                       \
    do {                                                      \
        char buffer[512];                                     \
        SERIALIZE_STRUCT(s, buffer);                          \
        fprintf(stderr, "DEBUG: %s:%d:%s(): " msg "{ %s }\n", \
                __FILE__, __LINE__, __func__, buffer);        \
    } while(0)

  #define DEBUG_TEXT(msg, ...)    \
    do {                          \
      fprintf(stderr, "DEBUG: %s:%d:%s(): " msg "\n",         \
                __FILE__, __LINE__, __func__, ##__VA_ARGS__); \
    } while(0)
#else
  #define DEBUG(msg, ...)
  #define DEBUG_TEXT(msg, ...)
#endif
