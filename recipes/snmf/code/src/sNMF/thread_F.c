/*
   sNMF, file: thread_F.c
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
#include "thread_F.h"
#include "../bituint/bituint.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>

// slice_temp3_X

void slice_temp3_X(void *G)
{
	Matrix_snmf Ma = (Matrix_snmf) G;
	bituint *X = Ma->R;
	double *temp3 = Ma->out;
	double *F = Ma->F;
	int N = Ma->N;
	int M = Ma->M;
	int Mp = Ma->Mp;
	int K = Ma->K;
	int nc = Ma->nc;
	int Mc = nc*M;
	int Md = Mc / SIZEUINT;
	int nb_data = Md;

	int s = Ma->slice;
	int num_thrd = Ma->num_thrd;
	int from = (s * nb_data) / num_thrd;	// note that this 'slicing' works fine
	int to = ((s + 1) * nb_data) / num_thrd;	// even if SIZE is not divisible by num_thrd
	int i, jd, jm, k1;
	bituint value;

	// F = temp3*X                                                  (M N K)
	for (jd = from; jd<to; jd++) {
		for (i = 0; i < N; i++) {
			value = X[i*Mp+jd];
			for (jm = 0; jm<SIZEUINT; jm++) {
				if (value % 2) {
					for (k1 = 0; k1 < K; k1++)
						F[(jd*SIZEUINT+jm)*K+k1] += temp3[k1*N+i];
				}
				value >>= 1;
			}
		}
	}
}

