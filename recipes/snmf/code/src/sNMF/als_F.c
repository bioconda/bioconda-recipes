/*
   sNMF, file: als_F.c
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
#include "als_F.h"
#include "../matrix/matrix.h"
#include "../matrix/rand.h"
#include "../matrix/data.h"
#include "../matrix/inverse.h"
#include "../matrix/normalize.h"
#include "../io/print_bar.h"
#include "als_Q.h"
#include "../bituint/calc_bituint.h"

#ifndef WIN32
	#include "thread_F.h"
	#include "thread_snmf.h"
#endif

// update_F

void update_F(sNMF_param param) 
{
	int i, j, k1, k2;
	double *temp1 = param->temp1;
	double *temp2 = param->tempQ;
	double *temp3 = param->temp3;
	int K = param->K;
	int N = param->n;
	int Mc = param->Mc;

	//computation of temp1 = transpose(Q)*Q
	tBB_alpha(param->temp1, param->Q, 0.0, N, K, 1);

	//computation of temp2 = inverse(transpose(Q)*Q)
	fast_inverse(temp1, K, temp2);

	//computation of temp3 = temp2*transpose(Q) 
	for (k1 = 0; k1 < K; k1++) {
		for (i = 0; i < N; i++) {
			temp3[k1*N+i] = 0;
			for (k2 = 0; k2 < K; k2++) {
				temp3[k1*N+i] += temp2[k1*K+k2] * param->Q[i*K+k2];
			}
		}
	}

	// calculate t(F) = temp3 * X
	BX(param->F, param->X, param->temp3, K, param->Mp, param->Mc,
		N, param->num_thrd);

	// projection on F >= 0
	for (j = 0; j<K*Mc; j++)
		param->F[j] = fmax(param->F[j],0);
}

// update_nnlsm_F (not used)

/*
double update_nnlsm_F(double *F, double *Q, bituint *X, int N, int M, int nc, 
		int Mp, int K, int num_thrd, sNMF_param mem) 
{
	int i,j,k1,k2;
	double res;

	int Mc = mem->Mc;
	int Md = Mc / SIZEUINT;
	int Mm = Mc % SIZEUINT;
	int jd, jm;
	bituint value;
	double* temp1 = mem->temp1;
	double* temp3 = mem->temp3;
	double* Y = mem->Y;

	// bullshit
	k1 = num_thrd;

	// t(Q)*Q
	zeros(temp1,K*K);
	for (i = 0; i < N; i++) {
		for (k1 = 0; k1 < K; k1++) {
			for (k2 = 0; k2 < K; k2++) {
				temp1[k1*K+k2] += Q[i*K+k1] * Q[i*K+k2];
			}
		}
	}
	// t(Q)*X
	zeros(temp3,K*Mc);
	for (i = 0; i < N; i++) {
		for (jd = 0; jd<Md; jd++) {
			value = X[i*Mp+jd];
			for (jm = 0; jm<SIZEUINT; jm++) {
				if (value & mask[jm]) {
					for (k1 = 0; k1 < K; k1++) 
						temp3[k1*Mc+jd*SIZEUINT+jm] += Q[i*K+k1];
				}
			}
		}
		value = X[i*Mp+Md];
		for (jm = 0; jm<Mm; jm++) {
			if (value & mask[jm]) {
				for (k1 = 0; k1 < K; k1++) 
					temp3[k1*Mc+Md*SIZEUINT+jm] += Q[i*K+k1];
			}
		}
	}

	// solve F
	nnlsm_blockpivot(temp1,temp3,Mc,K,F,Y,NULL);

	// update criteria
	res = 0.0;
	for (j = 0; j < Mc*K; j++) {
		res += fabs(Y[j]);
	}

	return res;
}
*/

// normalize_F

void normalize_F(double *F, int M, int nc, int K)
{
	int j, k, c;
	double sum;

	for(j = 0; j < M; j++) {
		for(k = 0; k < K; k++) {
			// for stability
			sum = 0.0;
			for(c = 0; c < nc; c++) 
				sum += F[(nc*j+c)*K+k];
			if (sum) {
				for(c = 0; c < nc; c++) 
					F[(nc*j+c)*K+k]/= sum;
			}
		}
	}
}

