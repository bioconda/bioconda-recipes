/**
 * @addtogroup als_F
 * @ingroup sNMF
 * @{
 * @file als_F.h
 *
 * @brief set of functions to compute F matrix from als algorithm
 */


#ifndef ALS_F_H
#define ALS_F_H

#include "../bituint/bituint.h"
#include "../nnlsm/blockpivot.h"
#include "sNMF.h"

/** 
 * @brief Update F
 *
 * @param param	sNMF parameters structure
 */
void update_F(sNMF_param param); 

/** 
 * @brief Update F with nnlsm method (out of date)
 *
 * @param F 	ancestral frequencies (of size KxM)
 * @param Q 	admixture coefficients (of size NxK)
 * @param X 	genome matrice (of size NxM)
 * @param N 	number of individuals
 * @param M 	number of loci
 * @param nc	number of different values in X
 * @param Mp 	number of columns of X
 * @param K 	number of clusters
 * @param num_thrd 	number of threads used
 * @param n_param	previously allocated memory
double update_nnlsm_F(double *F, double *Q, bituint *X, int N, int M, int nc, 
	int Mp, int K, int num_thrd, sNMF_param param);
 */

/** @brief normalize F 
 * 
 * @param F 	ancestral frequencies (of size KxM)
 * @param M 	number of loci
 * @param nc	number of different values in X
 * @param K	number of clusters
 */
void normalize_F(double *F, int M, int nc, int K);

#endif // ALS_F_H

/** @} */
