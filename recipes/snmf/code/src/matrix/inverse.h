/**
 * @addtogroup inverse
 * @ingroup matrix
 * @{
 * @file inverse.h
 *
 * @brief functions to inverse matrices
 */

#ifndef INVERSE_H
#define INVERSE_H

/**
 * compute a fast inverse inv of A 
 * 
 * @param A     the matrix to inverse (of size DxD)
 * @param D     the number of lines/columns of A
 * @param ind   the output inverse
 */
void fast_inverse(double *A, int D, double *inv);

/**
 * compute the determinant of a 
 * 
 * @param a     the matrix (of size kxk)
 * @param k     the number of lines/columns of a
 *
 * @return the determinant
 */
double detrm(double *a, int k);

/**
 * compute the inverse inv of num with cofactors
 *
 * @param num	the matrix to inverse (of size fxf)
 * @param f     the number of lines/columns of num
 * @param inv   the output inverse
 */
void cofact(double *num, int f, double *inv);

/**
 * compute the transpose and the inverse of a matrix
 *
 * @param num	the matrix to inverse (of size rxr)
 * @param fac	the cofactors
 * @param r     the number of lines/columns of num
 * @param inv   the output inverse
 */
void trans(double *num, double *fac, int r, double *inv);

#endif // INVERSE_H

/** @} */
