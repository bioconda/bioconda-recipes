/**
 * @addtogroup diagonalize
 * @ingroup matrix
 * @{
 * @file diagonalize.h
 *
 * @brief function to diagonalize symetric matrices
 */

#ifndef DIAGONALIZE_H
#define DIAGONALIZE_H

/**
 * compute eigenvalues and eigenvectors of symetric matrix 
 * 
 * @param cov   the matrix to diagonalize (of size NxN)
 * @param N	the size of cov
 * @param K	the number of eigenvalues/vectors to compute
 * @param val	eigenvalues vectors (of size K)
 * @param vect	eigenvectors matrix (of size NxK)
 */
void diagonalize(double *cov, int N, int K, double *val, double *vect);

#endif // DIAGONALIZE_H

/** @} */
