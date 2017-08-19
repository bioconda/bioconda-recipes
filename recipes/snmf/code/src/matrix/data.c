/*
    matrix, file: data.c
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "data.h"
#include "error_matrix.h"
#include "rand.h"

// zeros

void zeros(double *A, int n)
{
	int i;

	for (i = 0; i < n; i++)
		A[i] = 0;
}

// check_mat

int check_mat(double *A, int n, int nd, int nD)
{
	int i;

	for (i = 0; i < n; i++) {
		if (isnan(A[i * nD + nd]))
			return 1;
	}
	return 0;
}

// update_m

void update_m(double *beta, int n, int nb)
{
	int i;

	for (i = 0; i < n; i++)
		beta[i] /= nb;
}

// create_I

void create_I(float *dat, int *I, int N, int M)
{
	int i;

	for (i = 0; i < N * M; i++) {
		if (dat[i] == 9 || dat[i] == -9)
			I[i] = 0;
		else
			I[i] = 1;
	}
}

