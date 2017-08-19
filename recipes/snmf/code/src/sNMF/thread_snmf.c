/*
    sNMF, file: thread_snmf.c
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
#include "thread_snmf.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>
#include "../bituint/bituint.h"

// thread_fct_snmf

void thread_fct_snmf(bituint *R, double *out, double *Q, double *F, 
		int nc, int K, int M, int Mp, int N, int num_thrd, void (*fct) ())
{
	pthread_t *thread;	// pointer to a group of threads
	int i;

	thread = (pthread_t *) malloc(num_thrd * sizeof(pthread_t));
	Matrix_snmf *Ma = (Matrix_snmf *) malloc(num_thrd * sizeof(Matrix_snmf));

	/* this for loop not entered if threadd number is specified as 1 */
	for (i = 1; i < num_thrd; i++) {
		Ma[i] = (Matrix_snmf) malloc(1 * sizeof(matrix_snmf));
		Ma[i]->R = R;
		Ma[i]->out = out;
		Ma[i]->Q = Q;
		Ma[i]->F = F;
		Ma[i]->nc = nc;
		Ma[i]->K = K;
		Ma[i]->N = N;
		Ma[i]->M = M;
		Ma[i]->Mp = Mp;
		Ma[i]->num_thrd = num_thrd;
		Ma[i]->slice = i;
		/* creates each thread working on its own slice of i */
		if (pthread_create
		    (&thread[i], NULL, (void *)fct, (void *)Ma[i])) {
			perror("Can't create thread");
			free(thread);
			exit(1);
		}
	}

	/* main thread works on slice 0 so everybody is busy
	 * main thread does everything if thread number is specified as 1*/
	Ma[0] = (Matrix_snmf) malloc(1 * sizeof(matrix_snmf));
	Ma[0]->R = R;
	Ma[0]->out = out;
	Ma[0]->Q = Q;
	Ma[0]->F = F;
	Ma[0]->nc = nc;
	Ma[0]->K = K;
	Ma[0]->N = N;
	Ma[0]->M = M;
	Ma[0]->Mp = Mp;
	Ma[0]->num_thrd = num_thrd;
	Ma[0]->slice = 0;
	/* creates each thread working on its own slice of i */
	fct(Ma[0]);

	/*main thead waiting for other thread to complete */
	for (i = 1; i < num_thrd; i++)
		pthread_join(thread[i], NULL);

	for (i = 0; i < num_thrd; i++)
		free(Ma[i]);
	free(Ma);
	free(thread);
}
