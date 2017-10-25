/**
 * @addtogroup solvenormaleqcomb
 * @ingroup nnlsm
 * @{
 * @file solvenormaleqcomb.h
 *
 * @brief functions to solve AtA*Z() = AtB conditionned for PassiveSet
 */

#ifndef SOLVENORMALEQCOMB_H
#define SOLVENORMALEQCOMB_H

#include "nnlsm.h"

/* @brief solve AtA*Z() = AtB conditionned to PassSet 
 *
 * @param AtA   matrix of size (KxK)
 * @param AtB   matrix of size (KxN)
 * @param PassSet	boolean matrix of size (KxN)
 * @param N     number of columns of AtB
 * @param K     number of columns and lines of AtA
 * @param Z     output matrix of size (KxN)
 * @param param	parameter memory and structure
 * 
 * return niter
 */
int solveNormalEqComb (double* AtA, double* AtB, int *PassSet, int N, int K, double* Z, Nnlsm_param param);

/* @brief solve AtA*Z() = AtB conditionned for lines of selectK and columns of selectN 
 *
 * @param AtA   matrix of size (KxK)
 * @param AtB   matrix of size (KxN)
 * @param selectK	boolean vector with lines to solve, of size K
 * @param selectN	boolean vector with columns to solve, of size N
 * @param N     number of columns of AtB
 * @param K     number of columns and lines of AtA
 * @param Z     output matrix of size (KxN)
 */
void solveRegression (double *AtA, double* AtB, int *selectK, int* selectN,
		int sK, int N, int K, double* Z, double *sAtA, double *inVsAtA);

#endif // SOLVENORMALEQCOMB_H


/** @} */
