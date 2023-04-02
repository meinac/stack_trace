#include "types/event.h"

#ifdef ST_DEBUG
  void serialize_event(Event *event);
  void serialize_unknown(void *var);

  #define SERIALIZE_STRUCT(s)       \
    _Generic((s),                   \
      Event*: serialize_event,       \
      default: serialize_unknown    \
    )(s)

  #define DEBUG(msg, ...)                                           \
    do {                                                            \
        printf("%s", msg);                                          \
                                                                    \
        if ((sizeof((void*[]){__VA_ARGS__}) / sizeof(void*)) > 0) { \
          printf("{");                                              \
          SERIALIZE_STRUCT(__VA_ARGS__);                            \
          printf("}\n");                                            \
        } else {                                                    \
          printf("\n");                                             \
        }                                                           \
    } while(0)
#else
  #define DEBUG(msg, ...)
#endif
