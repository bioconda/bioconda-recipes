/**
 * @addtogroup blockpivot
 * @ingroup nnlsm
 * @{
 * @file blockpivot.h
 *
 * @brief functions to manage parameter updates in nnlsm algorithm
 */

#ifndef BLOCKPIVOT_H
#define BLOCKPIVOT_H

#include "nnlsm.h"

/* @brief update Y = AtAX - AtB
 *
 * @param AtA   matrix of size (KxK)
 * @param AtB   matrix of size (KxN)
 * @param X     matrix of size (KxN)
 * @param Y     output matrix of size (KxN)
 * @param N     number of columns of B
 * @param K     number of columns and lines of A
 */
void update_Y(double *AtA, double *AtB, double *X, double *Y, int N, int K);

/* @brief update NonOptSet, InfeaSet, NotGood, and NotOptCols_nb
 *
 * @param PassiveSet	boolean matrix (of size KxN) 
 * @param NotGood	(output) boolean matrix (of size N) 
 * @param NonOptSet	(output) boolean matrix (of size KxN) 
 * @param InfeaSet	(output) boolean matrix (of size KxN) 
 * @param X     matrix of size (KxN)
 * @param Y     matrix of size (KxN)
 * @param NotOptCols_nb	(output) numbre of columns to optimize
 * @param N     number of columns of X and Y
 * @param K     number of columns of X and Y
 */
void opt_param_update(int *PassiveSet, int *NotGood, int *NonOptSet, 
	int* InfeaSet, double* X, double* Y, int* NotOptCols_nb, int N, int K);

/* @brief parameters initialization
 *
 * @param PassiveSet	boolean matrix (of size KxN) initialized with X > 0
 * @param NotGood	boolean matrix (of size N) initialized with ones
 * @param Ninf		matrix (of size N) initialized with 3
 * @param P		matrix (of size N) initialized with K+1
 * @param K     number of columns of PassiveSet
 * @param N     number of lines of PassiveSet
 * @param X     init matrix of size (KxN)
 *
 * @return true if all X are <=0
 */
int parameter_init(int* PassiveSet, int* NotGood, int* Ninf, int* P,int K, 
	int N, double *X);

/* @brief PassiveSet, P, and Ninf update
 *
 * @param NotGood	boolean matrix (of size N)
 * @param Ninf		(output) matrix (of size N)
 * @param P		(output) matrix (of size N)
 * @param pbar		equal 3
 * @param NonOptSet	boolean matrix (of size KxN) 
 * @param PassiveSet	(output) boolean matrix (of size KxN) 
 * @param NotGood	boolean matrix (of size N) 
 * @param InfeaSet	boolean matrix (of size KxN) 
 * @param N     number of lines of PassiveSet
 * @param K     number of columns of PassiveSet
 */
void PassiveSet_update(int *NotGood, int *Ninf, int *P, int pbar, 
	int *NonOptSet, int* PassiveSet, int *InfeaSet, int N, int K, int *Cols3Ix);

/* @brief X and Y update
 *
 * @param AtA   matrix of size (KxK)
 * @param AtB   matrix of size (KxN)
 * @param PassiveSet	boolean matrix (of size KxN) 
 * @param NotGood	boolean matrix (of size N) 
 * @param NotOptCols_nb	number of columns to optimize
 * @param N     number of columns of B
 * @param K     number of columns and lines of A
 * @param X     (output) matrix of size (KxN)
 * @param Y     (output) matrix of size (KxN)
 *
 * @return number of iterations
 */
int XY_update(double *AtA, double *AtB, int *PassiveSet, int *NotGood, 
	int NotOptCols_nb, int N, int K, double *X, double *Y, Nnlsm_param param);

#endif // BLOCKPIVOT_H


/** @} */
