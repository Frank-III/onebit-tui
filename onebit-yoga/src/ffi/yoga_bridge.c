// Bridge file to include Yoga headers when available
// This file ensures proper C linkage for Yoga functions

#ifdef HAS_YOGA_HEADERS

#ifdef __cplusplus
extern "C" {
#endif

#include <yoga/Yoga.h>

#ifdef __cplusplus
}
#endif

#endif // HAS_YOGA_HEADERS