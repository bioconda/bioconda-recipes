/*
   sNMF, file: thread_Q.c
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

#include <stdlib.h>
#include <stdio.h>
#include "thread_snmf.h"
#include "thread_Q.h"
#include "../bituint/bituint.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>

// slice_F_tF

void slice_F_TF(void *G)
{
        Matrix_snmf Ma = (Matrix_snmf) G;
        double *temp1 = Ma->out;
        double *F = Ma->F;
        int M = Ma->M;
        int K = Ma->K;
        int nc = Ma->nc;
        int Mc = nc*M;
        int nb_data = K;

        int s = Ma->slice;
        int num_thrd = Ma->num_thrd;
        int from = (s * nb_data) / num_thrd;    // note that this 'slicing' works fine
        int to = ((s + 1) * nb_data) / num_thrd;        // even if SIZE is not divisible by num_thrd
        int j, k1, k2;

	// F t(F)	
        for (k1 = from; k1 < to; k1++) {
        	for (j = 0; j < Mc; j++) {
                        for (k2 = 0; k2 < K; k2++) {
                                temp1[k1*K+k2] += F[j*K+k1] * F[j*K+k2];
                        }
                }
        }
}

// slice F_TX

void slice_F_TX(void *G)
{
        Matrix_snmf Ma = (Matrix_snmf) G;
        bituint *X = Ma->R;
        double *temp3 = Ma->out;
        double *F = Ma->F;
        int M = Ma->M;
        int N = Ma->N;
        int Mp = Ma->Mp;
        int K = Ma->K;
        int nc = Ma->nc;
        int Mc = nc*M;
        int Md = Mc / SIZEUINT;
        int nb_data = N;

        int s = Ma->slice;
        int num_thrd = Ma->num_thrd;
        int from = (s * nb_data) / num_thrd;    // note that this 'slicing' works fine
        int to = ((s + 1) * nb_data) / num_thrd;        // even if SIZE is not divisible by num_thrd
        int jd, jm, i, k1;
	bituint value;

	// F t(X)
        for (i = from; i < to; i++) {
		for (jd = 0; jd<Md; jd++) {
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

