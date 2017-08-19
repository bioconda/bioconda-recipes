/**
 * @addtogroup als_Q
 * @ingroup sNMF
 * @{
 * @file als_Q.h
 *
 * @brief set of functions to compute update Q in als algorithm
 */


#ifndef ALS_Q_H
#define ALS_Q_H

#include "../bituint/bituint.h"
#include "../nnlsm/nnlsm.h"
#include "sNMF.h"

/** @brief Update Q (not used, out of date)
 *
 * @param Q 	admixture coefficients (of size NxK)
 * @param F 	ancestral frequencies (of size KxM)
 * @param X 	genome matrice (of size NxM)
 * @param N 	number of individuals
 * @param M 	number of loci
 * @param nc	number of different values in X
 * @param Mp 	number of columns of X
 * @param K	number of clusters
 * @param alpha parameter of the algorithm
 * @param n_param 	allocated memory
void update_Q(double *Q, double *F, bituint *X, int N, int M, int nc, int Mp, 
			int K, double alpha, Nnlsm_param n_param);
 */

/** @brief Update Q with non-negative least square method 
 *
 * @param param	sNMF parameter structure 
 * @param n_param	NNLSM parameter structure 
 */
double update_nnlsm_Q(sNMF_param param, Nnlsm_param n_param);

/** @brief normalize Q
 * 
 * @param Q 	ancestral frequencies (of size NxK)
 * @param N 	number of individuals
 * @param K	number of clusters
 */
void normalize_Q(double *Q, int N, int K);

#endif // ALS_Q_H

/** @} */
