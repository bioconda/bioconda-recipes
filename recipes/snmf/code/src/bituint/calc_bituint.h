/**
 * @addtogroup calc_bituint
 * @ingroup bituint
 * @{
 * @file calc_bituint.h
 *
 * @brief set of matrix operations with a bituint matrix.
 * The code can be optimized for a specific size of matrices. 
 */

#ifndef CALC_BITUINT_H
#define CALC_BITUINT_H

#include <stdint.h>
#include "bituint.h"

/**
 * calculate A = transpose(B) * transpose(X)
 * For a code optimized in term of memory access, it is assumed that K<= N << Mc.
 *
 * @param A 	output matrix (of size KxN)
 * @param X	bituint matrix (of size NxMp) with nxMc binary elements
 * @param B	matrix (of size McxK)
 * @param K	number of columns of B (K << ou <= N << Mc for optimization)
 * @param Mp	number of columns of X
 * @param Mc	number of bituint elements in one line of X
 * @param N	number of lines of X
 * @param num_thrd 	number of CPUs used for the calculation (windows version
			not multithreaded) 
 */
void tBtX(double *A, bituint *X, double *B, int K, int Mp, int Mc, int N, 
	int num_thrd);


/**
 * calculate t(A) = B X
 * For a code optimized in term of memory access, it is assumed that K<= N << Mc.
 * 
 * @param A 	output matrix (of size McxK)
 * @param X	bituint matrix (of size NxMp) with nxMc binary elements
 * @param B	matrix (of size KxN)
 * @param K	number of lines of B (K << ou <= N << Mc for optimization)
 * @param Mp	number of columns of X
 * @param Mc	number of bituint elements in one line of X
 * @param N	number of lines of X
 * @param num_thrd 	number of CPUs used for the calculation (windows version
			not multithreaded) 
 */
void BX(double *A, bituint *X, double *B, int K, int Mp, int Mc, int N,
	int num_thrd); 

#endif // CALC_BITUINT_H

/** @} */
