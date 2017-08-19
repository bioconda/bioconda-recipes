/**
 * @addtogroup matrix
 * @ingroup matrix
 * @{
 * @file matrix.h
 * 
 * @brief set of matrix operations
 * 
 * TODO:
 * - check schur and sylvester decomposition.
 */

#ifndef MATRIX_H
#define MATRIX_H
#include <math.h>

/**
 * compute unbiased variance of x
 * 
 * @param x	vector
 * @param n	size of x
 */
double variance(double *x, int n);

/**
 * comparaison function of two elements (for qsort)
 *
 * @param a	first element
 * @param b	second element
 *
 * return a - b;
 */
int compare (const void* a, const void* b);

/**
 * return the indexes of data sorted (increasing order) (using qsort) 
 *
 * @param data	matrix to sort
 * @param index	indices 
 * @param n	size of data, index
 */
 void sort_index(double *data, int *index, int n);

/**
 * compute min(a, b)
 * 
 * @param a 	first int
 * @param b	second int
 * 
 * @return min(a, b)
 */
int imin(int a, int b);

/**
 * compute max(a, b)
 * 
 * @param a 	first int
 * @param b	second int
 * 
 * @return max(a, b)
 */
int imax(int a, int b);

/**
 * calculate for each line k of A the squared sum (divided by 2) plus epsilon
 * 
 * @param A	the matrix (of size (KxM)
 * @param K	the number of lines of A
 * @param M	the number of columns of A
 * @param res	the output vector (of size K)
 * @param epsilon	the value of epsilon
 */
void dble_sum2(double *A, int K, int M, double *res, double epsilon);

/**
 * calculate the squared sum of A
 *
 * @param A 	the matrix (of size, size)
 * @param size 	the size of A
 * 
 * @return the squared sum
 */
double dble_sum(double *A, int size);

/**
 * copy vector in into vector out
 *
 * @param in 	vector to copy (of size, size)
 * @param out	vector to copy in (of size, size)
 * @param size	size of in and out
 */
void copy_vect(double *in, double *out, int size);


/**
 * transpose m (double) of size h x w (from Rosetta code)
 *
 * @param m	the matrix (hxw)
 * @param w	number of columns
 * @param h	number of lines
 */
void transpose_double (double *m, int w, int h);

/**
 * transpose m (float) of size h x w (from Rosetta code)
 *
 * @param m	the matrix (hxw)
 * @param w	number of columns
 * @param h	number of lines
 */
void transpose_float (float *m, int w, int h);

/**
 * transpose m (float) of size h x w (from Rosetta code)
 *
 * @param m	the matrix (hxw)
 * @param w	number of columns
 * @param h	number of lines
 */
void transpose_int (int *m, int w, int h);

/**
 * compute transpose(B) * B + alpha
 * The code is optimized in term of memory access, for K << N.
 * Function multithreaded for large N.
 *
 * @param A	the output matrix (of size KxK)
 * @param B	matrix (of size NxK)
 * @param alpha	
 * @param N
 * @param K	
 * @param num_thrd	number of CPUs used for multi-threading
 */
void tBB_alpha(double *A, double *B, double alpha, int N, int K, int num_thrd);

#endif // MATRIX_H

/** @} */
