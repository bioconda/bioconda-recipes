/*
    matrix, file: cholesky.c
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
#include <math.h>
#include "error_matrix.h"

// cholesky (from the web)

void cholesky(double *A, int n, double *L)
{
	double s;
	int i, j, k;

	if (L == NULL)
		print_error_global("interne", NULL, 0);

	for (i = 0; i < n; i++)
		for (j = 0; j < (i + 1); j++) {
			s = 0;
			for (k = 0; k < j; k++)
				s += L[i * n + k] * L[j * n + k];
			L[i * n + j] = (i == j) ?
			    sqrt(A[i * n + i] - s) :
			    (1.0 / L[j * n + j] * (A[i * n + j] - s));
		}
}
