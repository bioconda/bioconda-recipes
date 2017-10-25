/**
 * @addtogroup thread_Q
 * @ingroup sNMF
 * @{
 * @file thread_Q.h
 *
 * @brief multithreaded part of the functions to compute 
 * 	  new values of Q
 */

#ifndef THREAD_Q_H
#define THREAD_Q_H

/**
 * compute a slice of F transpose(X)
 *
 * @param G     a specific structure for multi-threading
 */
void slice_F_TX(void *G);

/**
 * compute a slice of F transpose(F)
 *
 * @param G     a specific structure for multi-threading
 */
void slice_F_TF(void *G);

#endif // THREAD_Q_H

/** @} */
