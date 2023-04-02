#include "types/event.h"

#ifdef ST_DEBUG
  void serialize_event(Event *event);
  void serialize_unknown(void *var);

  #define SERIALIZE_STRUCT(s)    \
    _Generic((s),                \
      Event*: serialize_event,   \
      default: serialize_unknown \
    )(s)

  #define DEBUG_TEXT(msg) printf("%s", msg);

  #define DEBUG(msg, s)      \
    do {                     \
        printf("%s", msg);   \
        printf("{");         \
        SERIALIZE_STRUCT(s); \
        printf("}\n");       \
    } while(0)
#else
  #define DEBUG(msg, ...)
  #define DEBUG_TEXT(msg)
#endif
