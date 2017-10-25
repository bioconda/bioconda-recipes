/*
   LFMM, file: slice_matrix.c
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
#include "slice_matrix.h"
#include "thread_matrix.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>

// slice_tBB

void slice_tBB(void *G)
{
	Multithreading_matrix Ma = (Multithreading_matrix) G;
	double *A = Ma->A;
	double *B = Ma->B;
	int K = Ma->K;
	int M = Ma->M;

	int nb_data = K;
	int num_thrd = Ma->num_thrd;
	int s = Ma->slice;
	int from = (s * nb_data) / num_thrd;	// note that this 'slicing' works fine
	int to = ((s + 1) * nb_data) / num_thrd;	// even if SIZE is not divisible by num_thrd
	int j, k1, k2;

	// t(B) B
        for (k1 = from; k1 < to; k1++) {
                for (j = 0; j < M; j++) {
                        for (k2 = 0; k2 < K; k2++) {
                                A[k1*K+k2] += B[j*K+k1] * B[j*K+k2];
                        }
                }
        }
}

