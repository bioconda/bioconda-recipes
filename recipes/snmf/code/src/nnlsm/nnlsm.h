
 /**
 * @addtogroup nnlsm
 * @{
 * @file nnlsm.h
 * @brief compute the Non Negative Least Square solution X>=0 of (AtA)X = AtB.
 * 
 * This algorithm is described in the paper of Kim and Park (2008)
 * Sparse Nonnegative Matrix Factorization for Clustering.
 * 
 * The matlab code is available in the directory nmf_bpas.
 * We use the same notations in this directory as those in the matlab
 * code.
 *
 * The memory for nnlsm can be allocate once for all the call to nnlsm_blockpivot 
 * 
 * TODO:
 * - The comments of sort.h are not clear enough.
 * - The algorithm of sort.h may be improved for large matrices.
 * @}
 */

#ifndef NNLSM_H
#define NNLSM_H

typedef struct _nnlsm_param* Nnlsm_param;

/**
 * @brief structure containing all parameters for nnlsm
 */
typedef struct _nnlsm_param{
        int* P;
        int* Ninf;
        int* PassiveSet;
        int *NonOptSet;
        int* InfeaSet;
        int* NotGood;
        int* Cols3Ix;
        double* subX;
        double* subY;
        double* subAtB;
        int* subPassiveSet;
        int* selectK;
        int* selectN;
        int* breaks;
        int* sortIx;
        double* sAtA;
        double* inVsAtA;
        int* tempSortIx;
        double* Y;
} nnlsm_param;

Nnlsm_param allocate_nnlsm(int N, int K);

void free_nnlsm(Nnlsm_param param);

/* @brief solution of NNLS problem of Kim and Park (2011).
 *
 * @param AtA   matrix of size (KxK)
 * @param AtB   matrix of size (KxN)
 * @param N     number of columns of B
 * @param K     number of columns and lines of A
 * @param X     output matrix of size (KxN)
 * @param Y     output matrix of size (KxN)
 * @param param	parameters structure and memory
 * 
 * @return the number of iterations
 */
int nnlsm_blockpivot(double* AtA, double* AtB, int N, int K, double *X, double *Y, 
	Nnlsm_param param);

#endif // NNLSM_H
