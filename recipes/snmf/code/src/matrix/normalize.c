/*
    LFMM, file: normalize.c
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
#include "normalize.h"

// constant_column

void check_constant_column(float *C, int N, int K)
{
	double mean, cov;
	int i, k, count;

	for (k = 0; k < K; k++) {
		// calculate mean
		mean = 0;
		count = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9) {
				mean += C[i * K + k];
				count++;
			}	
		}
		if (count)
			mean /= count;
		else {
			printf("Error: columns '%d' contains only missing data.\n\n", k+1);
			exit(1);
		}
		// calculate cov
		cov = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9)
				cov += (C[i * K + k] - mean) * (C[i * K + k] - mean);
		}
		cov /= (count - 1);
		// error if constant column
		if (!cov) {
		        printf("Error: it seems that line or column %d is constant " 
				"among individuals.\n\n",k+1);
			exit(1);
		}
	}
}

// normalize_cov

void normalize_cov(double *C, int N, int K)
{
	double mean, cov;
	int i, k;

	for (k = 0; k < K; k++) {
		// calculate mean
		mean = 0;
		for (i = 0; i < N; i++)
			mean += C[i * K + k];
		mean /= N;
		// calculate cov
		cov = 0;
		for (i = 0; i < N; i++)
			cov += (C[i * K + k] - mean) * (C[i * K + k] - mean);
		cov /= (N - 1);
		// error if constant column
		if (!cov) {
		        printf("Error: it seems that line or column %d is constant " 
				"among individuals.\n\n",k+1);
			exit(1);
		}
		// normalize
		for (i = 0; i < N; i++)
			C[i * K + k] = (C[i * K + k] - mean) / sqrt(cov);
	}
}

// normalize_cov_I

void normalize_cov_I(double *C, int N, int K)
{
	double mean, cov;
	int i, k, count;

	for (k = 0; k < K; k++) {
		// calculate mean
		mean = 0;
		count = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9) {
				mean += C[i * K + k];
				count++;
			}	
		}
		if (count)
			mean /= count;
		else 
			printf("Error: columns '%d' contains only missing data.\n\n", k+1);
		// calculate cov
		cov = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9)
				cov += (C[i * K + k] - mean) * (C[i * K + k] - mean);
		}
		cov /= (count - 1);
		// error if constant column
		if (!cov) {
		        printf("Error: it seems that line or column %d is constant " 
				"among individuals.\n\n",k+1);
			exit(1);
		}
		// normalize
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9)
				C[i * K + k] = (C[i * K + k] - mean) / sqrt(cov);
		}
	}
}

// normalize_lines

void normalize_lines(double *A, int N, int M)
{
	int i, j;
	double sum;
	for (i = 0; i < N; i++) {
		// sum
		sum = 0.0;
		for (j = 0; j < M; j++) {
			sum += A[i * M + j];
		}
		// normalize
		for (j = 0; j < M; j++) {
			A[i * M + j] /= sum;
		}
	}

}

// normalize_mean_I

void normalize_mean_I(double *C, int N, int K)
{
	double mean;
	int i, k, count;

	for (k = 0; k < K; k++) {
		// calculate mean
		mean = 0;
		count = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9) {
				mean += C[i * K + k];
				count++;
			}	
		}
		mean /= count;
		// normalize
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9)
				C[i * K + k] -= mean;
		}
	}
}

// normalize_mean_I_float

void normalize_mean_I_float(float *C, int N, int K)
{
	float mean;
	int i, k, count;

	for (k = 0; k < K; k++) {
		// calculate mean
		mean = 0;
		count = 0;
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9) {
				mean += C[i * K + k];
				count++;
			}	
		}
		mean /= count;
		// normalize
		for (i = 0; i < N; i++) {
			if (fabs(C[i * K + k]) != 9)
				C[i * K + k] -= mean;
		}
	}
}
