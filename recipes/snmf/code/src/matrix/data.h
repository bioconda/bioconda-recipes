/**
 * @addtogroup data
 * @ingroup matrix
 * @{
 * @file data.h
 *
 * @brief set of functions to manage data matrices
 */

#ifndef DATA_H
#define DATA_H

/**
 * set A to 0
 *
 * @param A	the matrix A (of size n)
 * @param n	the size of A
 */
void zeros(double *A, int n);

/**
 * check if column nd of A contains NaN elements
 * 
 * @param A	the matrix A (of size nxnD)
 * @param n	the number of lines of A
 * @param nd	the column of A to check
 * @param nD	the number of columns of A
 *
 * @return true if the column nd of A contains Nan element
 */
int check_mat(double *A, int n, int nd, int nD);

/**
 * divide all elements of beta by nb
 *
 * @param beta	the matrix to divide (of size n)
 * @param n	the size of beta
 * @param nb	the divisor
 */
void update_m(double *beta, int n, int nb);

/**
 * create I the missing matrix from dat
 *
 * @param dat	the data matrix (of size NxM)
 * @param I	the missing matrix (of size NxM), equals 0 if dat equals -9, 0 otherwise
 * @param N	the number of lines of dat
 * @param M	the number of columns of dat
 */
void create_I(float *dat, int *I, int N, int M);

#endif // DATA_H

/** @} */
