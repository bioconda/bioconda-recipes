/*
    matrix, file: diagonalize.c
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

#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include "diagonalize.h"
#include "../lapack/f2c.h"
#include "../lapack/lpk.h"

// diagonalize (with lapack)
#include "../io/io_data_double.h"

void diagonalize(double *cov, int N, int K, double *val, double *vect)
{
	long int n = (long int)N;
	long int M = (long int)K;
	double abstol = 1e-10;
	long int *supp = (long int *) malloc (2 * N * sizeof(long int));
	long int lwork = 26*N;
	double *work = (double *)calloc(lwork, sizeof(double));
	long int liwork = 10*N;
	long int *iwork = (long int *)calloc(liwork, sizeof(double));
	long int info;
	double vl = 0.0, vu = 0.0;
	char jobz = 'V', range = 'I', uplo = 'U';
	long int il =  (long int)N-K+1;
	long int ul = (long int)N;
	double *valp = (double *) calloc(N, sizeof(double));
	double *vectp = (double *) calloc(N * N, sizeof(double));
	int i, k;

	dsyevr_((char *) (&jobz), (char *) (&range) , (char *) (&uplo), (integer *) (&n), (doublereal *) cov, 
	(integer *) (&n), (doublereal *) (&vl), (doublereal *) (&vu), (integer *) (&il) , (integer *) (&ul), 
	(doublereal *) (&abstol), (integer *) (&M), (doublereal *) valp,
        (doublereal *) vectp, (integer *) (&n), (integer *)supp, (doublereal *)work,
        (integer *) (&lwork), (integer *)iwork, (integer *) (&liwork), (integer *) (&info));

	// copy results
	for (k = 0; k < K; k++) {
		val[k] = valp[K-(k+1)];
		if (val[k] < 0 && abs(val[k]) < 1e-10) 
			val[k] = 0;
	}
	
	for (k = 0; k < K; k++)
		for (i = 0; i < N; i++)
			vect[i * K + k] = vectp[(K - (k + 1)) * N + i];

	free(valp);
	free(vectp);
	free(supp);
	free(work);
	free(iwork);
}
