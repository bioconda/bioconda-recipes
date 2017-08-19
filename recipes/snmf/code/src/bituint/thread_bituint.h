/**
 * @addtogroup thread_bituint
 * @ingroup bituint
 * @{
 * @file thread_bituint.h
 *
 * @brief general function and structure to manage multithreading
 */

#ifndef THREAD_BITUINT_H
#define THREAD_BITUINT_H

#include "../bituint/bituint.h"

/**
 * structure to manage multithreading
 */
typedef struct _multithreading_bituint *Multithreading_bituint;

/**
 * @brief structure containing generic parameters for multithreading
 * 	in bituint functions.
 */
typedef struct _multithreading_bituint {
	bituint *X;
	double *A;
	double *B;
	int K;
	int N;
	int Mc;
	int Mp;
	int slice;
	int num_thrd;
} multithreading_bituint;

/** 
 * general multithreading function manager for bituint. Parameters can be NULL.
 *
 * @param X	bituint data matrix
 * @param A	output matrix (variable size)
 * @param B	matrix (variable size) 
 * @param K	a size
 * @param Mc	number of binary elements in a line of X
 * @param Mp	number of bituint columns in a line of X
 * @param N	a size
 * @param num_thrd	the number of processes used
 * @param fct	the specific slice function
 */
void thread_fct_bituint(bituint *X, double *A, double *B, int K, int Mc, int Mp,
	int N, int num_thrd, void (*fct) ());

#endif // THREAD_H

/** @} */
