/*
   bituint, file: calc_bituint.c
   Copyright (C) 2014 Eric Frichot

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
#include "io_geno_bituint.h"
#include "bituint.h"
#include "slice_bituint.h"
#include "thread_bituint.h"
#include "calc_bituint.h"
#include "../io/io_error.h"
#include "../io/io_tools.h"
#include "../matrix/data.h"
#include <errno.h>

// tBtX

void tBtX(double *A, bituint *X, double *B, int K, int Mp, int Mc,
		int N, int num_thrd)
{
	int Md = Mc / SIZEUINT;
	int Mm = Mc % SIZEUINT;
	int i, k1, jd, jm;
	bituint value;

	// B*t(X)                                                       (M N K)
	zeros(A,K*N);

#ifndef WIN32
	// multi-threaded non windows version
	if (num_thrd > 1) {
		thread_fct_bituint(X, A, B, K, Mc, Mp, N, num_thrd, slice_tBtX);
	} else {
#endif
		// uni-threaded or windows version
		for (jd = 0; jd<Md; jd++) {
			for (i = 0; i < N; i++) {
				value = X[i*Mp+jd];
				for (jm = 0; jm<SIZEUINT; jm++) {
					if (value % 2) {
						for (k1 = 0; k1 < K; k1++)
							A[k1*N+i] += B[(jd*SIZEUINT+jm)*K+k1];
					}
					value >>= 1;
				}
			}
		}
#ifndef WIN32
	}
#endif
	// last columns
	for (i = 0; i < N; i++) {
		value = X[i*Mp+Md];
		for (jm = 0; jm<Mm; jm++) {
			if (value % 2) {
				for (k1 = 0; k1 < K; k1++)
					A[k1*N+i] += B[(Md*SIZEUINT+jm)*K+k1];
			}
			value >>= 1;
		}
	}
}


// BX

void BX(double *A, bituint *X, double *B, int K, int Mp, int Mc, int N,
		int num_thrd)
{
        int i, k1;
        int Md = Mc / SIZEUINT;
        int Mm = Mc % SIZEUINT;
        int jm, jd;
        bituint value;

        // A = B*X  
        zeros(A,K*Mc);

#ifndef WIN32
	// multi-threaded non windows version
	if (num_thrd > 1) {
		thread_fct_bituint(X, A, B, K, Mc, Mp, N, num_thrd, slice_BX);
	} else {
#endif
		// uni-threaded or windows version
		for (jd = 0; jd<Md; jd++) {
			for (i = 0; i < N; i++) {
				value = X[i*Mp+jd];
				for (jm = 0; jm<SIZEUINT; jm++) {
					if (value % 2) {
						for (k1 = 0; k1 < K; k1++)
							A[(jd*SIZEUINT+jm)*K+k1] += B[k1*N+i];
					}
					value >>= 1;
				}
			}
		}
#ifndef WIN32
	}
#endif
	// last columns
	for (i = 0; i < N; i++) {
		value = X[i*Mp+Md];
		for (jm = 0; jm<Mm; jm++) {
			if (value % 2) {
				for (k1 = 0; k1 < K; k1++)
					A[(Md*SIZEUINT+jm)*K+k1] += B[k1*N+i];
			}
			value >>= 1;
		}
	}
} 

