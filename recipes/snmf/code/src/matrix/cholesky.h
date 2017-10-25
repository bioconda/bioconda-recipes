/**
 * @addtogroup cholesky
 * @ingroup matrix
 * @{
 * @file cholesky.h
 *
 * @brief function to compute the lower cholesky decomposition of a matrix
 */

#ifndef CHOLESKY_H
#define CHOLESKY_H

/**
 * compute the lower cholesky decomposite L of A, A = LL^T
 *
 * @param A	the matrix to decompose (of size nxn)
 * @param n	the size of columns/lines of A
 * @param L	the output cholesky decomposition
 */
void cholesky(double *A, int n, double *L);

#endif // CHOLESKY_H

/** @} */
