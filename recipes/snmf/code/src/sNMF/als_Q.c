/*
   sNMF, file: als_Q.c
   Copyright (C) 2013 François Mathieu, Eric Frichot

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "als_Q.h"
#include "../matrix/matrix.h"
#include "../matrix/rand.h"
#include "../matrix/data.h"
#include "../matrix/inverse.h"
#include "../matrix/normalize.h"
#include "../io/print_bar.h"
#include "../bituint/bituint.h"
#include "../bituint/calc_bituint.h"

#ifndef WIN32
	#include "thread_Q.h"
	#include "thread_snmf.h"
#endif

// update_nnlsm_Q

double update_nnlsm_Q(sNMF_param param, Nnlsm_param n_param)
{
	int i, k;
	int K = param->K;
	int N = param->n;
	double *Y = param->Y;
	double *Q = param->Q;

	double res;

	// compute temp1 = t(F) * F + alpha
	tBB_alpha(param->temp1, param->F, param->alpha, param->Mc, param->K,
		param->num_thrd);	

	// compute temp3 = t(F) t(X)
	tBtX(param->temp3, param->X, param->F, param->K, param->Mp, 
		param->Mc, N, param->num_thrd);

	// solve tempQ >= 0, to minimize ||temp1 * tempQ - temp3||_F
	nnlsm_blockpivot(param->temp1, param->temp3, N, param->K, 
		param->tempQ, param->Y, n_param);

	// update Q
	for(i = 0; i < N; i++) 
		for(k = 0; k < K; k++) 
			Q[i*K+k] = param->tempQ[k*N+i];

	// new output criteria, based on Kim and Park criterion
	res = 0.0; 
	for(i = 0; i < N; i++)
		for(k = 0; k < K; k++)
			if (Q[i * K + k] > 0 || Y[k * N + i] < 0)
				res += Y[k * N + i] * Y[k * N + i];

	return sqrt(res);
}


// normalize_Q

void normalize_Q(double *Q, int N, int K)
{
	normalize_lines(Q, N, K);
}

// udpate_Q (not used) TODO / decreprated

/*
void update_Q(double *Q, double *F, bituint *X, int N, int M, int nc, int Mp, 
		int K, 	double alpha, sNMF_param param) {

	int i, j, k1, k2;
	double *temp1 = param->temp1;
	double *temp2 = param->tempQ;
	double *temp3 = param->temp3;

	int Mc = nc*M;
	int Md = Mc / SIZEUINT;
	int Mm = Mc % SIZEUINT;
	int jd, jm;
	bituint value;

	zeros(F,Mc*K);
	//computation of t(F)*F
	for (j = 0; j < Mc; j++) {
		for (k1 = 0; k1 < K; k1++) {
			for (k2 = 0; k2 < K; k2++) {
				temp1[k1*K+k2] += F[j*K+k1] * F[j*K+k2];
				temp1[k1*K+k2] += alpha;
			}
		}
	}

	//inverse of t(F)*F
	fast_inverse(temp1, K, temp2);

	// t(F)*t(X)							(M N K)
	zeros(temp3,K*N);

	if (num_thrd > 1) {
		thread_fct_snmf(X, temp3, NULL, F, nc, K, M, Mp, N, num_thrd, slice_F_TX);
	} else {
		for (jd = 0; jd<Md; jd++) {
			for (i = 0; i < N; i++) {
				value = X[i*Mp+jd];
				for (jm = 0; jm<SIZEUINT; jm++) {
					if (value % 2) {
						for (k1 = 0; k1 < K; k1++) 
							temp3[k1*N+i] += F[(jd*SIZEUINT+jm)*K+k1];
					}
					value >>= 1;
				}
			}
		}
	}

	for (i = 0; i < N; i++) {
		value = X[i*Mp+Md];
		for (jm = 0; jm<Mm; jm++) {
			if (value % 2) {
				for (k1 = 0; k1 < K; k1++) 
					temp3[k1*N+i] += F[(Md*SIZEUINT+jm)*K+k1];
			}
			value >>= 1;
		}
	}

	// temp2 * temp3
	zeros(Q,K*N);
	for(k1 = 0; k1 < K; k1++) {
		for(k2 = 0; k2 < K; k2++) {
			for(i = 0; i < N; i++) {
				Q[i*K+k2] += temp2[k2*K+k1] * temp3[k1*N+i];
			}
		}
	}

	// Q[Q < 0] = 0.0;
	for(j = 0; j < N; j++) 
		for(i = 0; i < K; i++) 
			Q[j*K+i] = fmax(Q[j*K+i],0);
}
*/

