/**
 * @addtogroup thread_F
 * @ingroup sNMF
 * @{
 * @file thread_F.h
 *
 * @brief multithreaded part of the functions to compute 
 * 	  new values for F.
 */

#ifndef THREAD_F_H
#define THREAD_F_H

/**
 * compute a slice of temp3 X
 *
 * @param G     a specific structure for multi-threading
 */
void slice_temp3_X(void *G);

#endif // THREAD_F_H

/** @} */
