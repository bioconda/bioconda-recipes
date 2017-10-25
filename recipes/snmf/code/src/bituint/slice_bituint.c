/*
   LFMM, file: slice_bituint.c
   Copyright (C) 2012 Eric Frichot

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

#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include "bituint.h"
#include "slice_bituint.h"
#include "thread_bituint.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>

// slice_tBtX

void slice_tBtX(void *G)
{
	Multithreading_bituint Ma = (Multithreading_bituint) G;
	bituint *X = Ma->X;
	double *A = Ma->A;
	double *B = Ma->B;
	int K = Ma->K;
	int Mp = Ma->Mp;
	int Mc = Ma->Mc;
        int Md = Mc / SIZEUINT;

	int N = Ma->N;
	int nb_data = N;
	int num_thrd = Ma->num_thrd;
	int s = Ma->slice;
	int from = (s * nb_data) / num_thrd;	// note that this 'slicing' works fine
	int to = ((s + 1) * nb_data) / num_thrd;	// even if SIZE is not divisible by num_thrd
	int i, jd, jm, k;
	bituint value;

	// t(B) t(X)
        for (i = from; i < to; i++) {
                for (jd = 0; jd<Md; jd++) {
                        value = X[i*Mp+jd];
                        for (jm = 0; jm<SIZEUINT; jm++) {
                                if (value % 2) {
                                        for (k = 0; k < K; k++)
                                                A[k*N+i] += B[(jd*SIZEUINT+jm)*K+k];
                                }
                                value >>= 1;
                        }
                }
        }
}

// slice_BX

void slice_BX(void *G)
{
	Multithreading_bituint Ma = (Multithreading_bituint) G;
	bituint *X = Ma->X;
	double *A = Ma->A;
	double *B = Ma->B;
	int K = Ma->K;
	int Mp = Ma->Mp;
	int Mc = Ma->Mc;
        int Md = Mc / SIZEUINT;

	int s = Ma->slice;
	int N = Ma->N;
	int nb_data = Md;
	int num_thrd = Ma->num_thrd;
	int from = (s * nb_data) / num_thrd;	
	int to = ((s + 1) * nb_data) / num_thrd;
	int i, jd, jm, k;
	bituint value;

	// B X
        for (jd = from; jd<to; jd++) {
                for (i = 0; i < N; i++) {
                        value = X[i*Mp+jd];
                        for (jm = 0; jm<SIZEUINT; jm++) {
                                if (value % 2) {
                                        for (k = 0; k < K; k++)
                                                A[(jd * SIZEUINT + jm) * K + k] += B[k * N + i];
                                }
                                value >>= 1;
                        }
                }
        }
}

