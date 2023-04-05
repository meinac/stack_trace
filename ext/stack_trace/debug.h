#include "types/event.h"

#ifdef ST_DEBUG
  void serialize_event(char *buffer, Event *event);
  void serialize_unknown(char *buffer, void *var);

  static FILE *debug_fp = NULL;

  #define OPEN_DEBUG_FILE() if(!debug_fp) debug_fp = fopen("debug.log", "a")

  #define SERIALIZE_STRUCT(s, buffer) \
    _Generic((s),                     \
      Event*: serialize_event,        \
      default: serialize_unknown      \
    )(buffer, s)

  #define DEBUG(msg, s)                                         \
    do {                                                        \
        OPEN_DEBUG_FILE();                                      \
        char buffer[512];                                       \
        SERIALIZE_STRUCT(s, buffer);                            \
        fprintf(debug_fp, "DEBUG: %s:%d:%s(): " msg "{ %s }\n", \
                __FILE__, __LINE__, __func__, buffer);          \
        fflush(debug_fp);                                       \
    } while(0)

  #define DEBUG_TEXT(msg, ...)                                \
    do {                                                      \
      OPEN_DEBUG_FILE();                                      \
      fprintf(debug_fp, "DEBUG: %s:%d:%s(): " msg "\n",       \
                __FILE__, __LINE__, __func__, ##__VA_ARGS__); \
      fflush(debug_fp);                                       \
    } while(0)
#else
  #define DEBUG(msg, ...)
  #define DEBUG_TEXT(msg, ...)
#endif
