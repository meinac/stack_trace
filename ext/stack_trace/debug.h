#include "types/event.h"

#ifdef ST_DEBUG
  void serialize_event(Event *event);
  void serialize_unknown(void *var);

  #define SERIALIZE_STRUCT(s)    \
    _Generic((s),                \
      Event*: serialize_event,   \
      default: serialize_unknown \
    )(s)

  #define DEBUG(msg, s)      \
    do {                     \
        printf("%s", msg);   \
        printf("{");         \
        SERIALIZE_STRUCT(s); \
        printf("}\n");       \
    } while(0)

    #define DEBUG_TEXT(msg, ...)    \
      do {                          \
        printf(msg, ##__VA_ARGS__); \
        printf("\n");               \
      } while(0)
#else
  #define DEBUG(msg, ...)
  #define DEBUG_TEXT(msg)
#endif
