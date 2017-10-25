/*
    sNMF, file: thread_bituint.c
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
#include "thread_bituint.h"
#include <string.h>
#include <math.h>
#include <time.h>
#include <float.h>
#include "../bituint/bituint.h"

// thread_fct_bituint

void thread_fct_bituint(bituint *X, double *A, double *B, int K, int Mc, int Mp, 
	int N, int num_thrd, void (*fct) ())
{
	pthread_t *thread;	// pointer to a group of threads
	int i;

	thread = (pthread_t *) malloc(num_thrd * sizeof(pthread_t));
	Multithreading_bituint *Ma = (Multithreading_bituint *) malloc(num_thrd * sizeof(Multithreading_bituint));

	/* this for loop not entered if threadd number is specified as 1 */
	for (i = 1; i < num_thrd; i++) {
		Ma[i] = (Multithreading_bituint) malloc(1 * sizeof(multithreading_bituint));
		Ma[i]->X = X;
		Ma[i]->A = A;
		Ma[i]->B = B;
		Ma[i]->K = K;
		Ma[i]->N = N;
		Ma[i]->Mc = Mc;
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
	Ma[0] = (Multithreading_bituint) malloc(1 * sizeof(multithreading_bituint));
	Ma[0]->X = X;
	Ma[0]->A = A;
	Ma[0]->B = B;
	Ma[0]->K = K;
	Ma[0]->N = N;
	Ma[0]->Mc = Mc;
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
