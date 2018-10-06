/** @file wren.h
*
* @brief Wren configuration and API
*
* @par
* @copyright Copyright © 2018 Doug Currie, Londonderry, NH, USA
*/

#ifndef WREN_H
#define WREN_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/* ############## Configuration ############## */


/** @def WREN_UNALIGNED_ACCESS_OK
* @brief non-zero enables reads and writes of multi-byte values from/to unaligned addresses.
* Default to safe mode: no unaligned accesses.
*/
#ifndef WREN_UNALIGNED_ACCESS_OK
#define WREN_UNALIGNED_ACCESS_OK (0)
#endif

/** @def WREN_BIG_ENDIAN_DATA
* @brief non-zero configures Wren to de/encode multi-byte values in big endian format.
* Default to the most common case: little endian.
*/
#ifndef WREN_BIG_ENDIAN_DATA
#define WREN_BIG_ENDIAN_DATA (0)
#endif

/** Type of a Wren-language value. Must be capable of holding a pointer or an integer
*/
typedef intptr_t wValue;
/* and how to printf it
*/
#define PRVAL "ld"

#if (INTPTR_MAX == INT64_MAX)
#define SIZEOF_WVALUE (8)
#else
#if (INTPTR_MAX == INT32_MAX)
#define SIZEOF_WVALUE (4)
#else
#error "Cannot determine wValue size."
#endif
#endif

// TODO: wIndex


/* ################### API ################### */

// TODO: init, bind_c_function, read_eval_print_loop

#ifdef __cplusplus
}
#endif

#endif /* WREN_H */
