/**
 * @addtogroup thread_matrix
 * @ingroup matrix
 * @{
 * @file thread_matrix.h
 *
 * @brief general function and structure to manage multithreading
	for matrix calculation
 */

#ifndef THREAD_MATRIX_H
#define THREAD_MATRIX_H


/**
 * structure to manage multithreading
 */
typedef struct _multithreading_matrix *Multithreading_matrix;

/**
 * @brief structure containing generic parameters for multithreading
 * 	in matrix functions.
 */
typedef struct _multithreading_matrix {
	double *A;
	double *B;
	double *C;
	int K;
	int N;
	int M;
	double alpha;
	int slice;
	int num_thrd;
} multithreading_matrix;

/** 
 * general multithreading function manager for matrix. Parameters can be NULL.
 *
 * @param A	output matrix (variable size)
 * @param B	matrix (variable size) 
 * @param C	matrix (variable size) 
 * @param K	a size
 * @param M	a size
 * @param N	a size
 * @param alpha	variable
 * @param num_thrd	the number of processes used
 * @param fct	the specific slice function
 */
void thread_fct_matrix(double *A, double *B, double *C, int K, int M,
	int N, double alpha, int num_thrd, void (*fct) ());

#endif // THREAD_H

/** @} */
