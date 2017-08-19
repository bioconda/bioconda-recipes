/**
 * @addtogroup sylvester
 * @ingroup matrix
 * @{
 * @file sylvester.h
 *
 * @brief solve the sylvester equation AX + XB = C
 */

#ifndef SYLVESTER_H
#define SYLVESTER_H

/**
 * compute the sylvester solution of AX + XB = C
 * TO CHECK
 * 
 * @param A     a matrix (of size MxM)
 * @param B     a matrix (of size NxN)
 * @param C     a matrix (of size MxN)
 * @param X     the output matrix (of size MxN)
 * @param M     the number of lines of C/X
 * @param N     the number of columns of C/X
 */
void sylvester(double *A, double *B, double *C, double *X, int M, int N);

/**
 * compute the schur decomposition of A (of size MxM) in Q
 * TOCHECK
 *
 * @param A	input matrix (of size MxM)
 * @param Q	output matrix (of size MxM)
 * @param M	size
 */
void schur(double *A, double *Q, int M);

#endif // SYLVESTER_H

/** @} */
