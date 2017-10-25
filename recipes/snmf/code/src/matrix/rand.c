/*
    LFMM, file: rand.c
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
#include <time.h>
#include <sys/types.h>  
#include <unistd.h>
#include "rand.h"
#include "matrix.h"
#include "cholesky.h"
#include "../stats/student_t_distribution.h"

// rand_rp

double rand_srp() {
	double r = drand();

	if (r < 0.166666667)
		return -1;
	else if (r >= 0.833333333)
		return 1;
	else
		return 0;
}

// compare_double 

int compare_double (void const *a, void const *b) {
  	/* definir des pointeurs type's et initialise's
     	avec les parametres */
 	double const *pa = a;
	double const *pb = b;
	int res;

   	/* evaluer et retourner l'etat de l'evaluation (tri croissant) */
        if (*pa < *pb) res = -1;
        if (*pa == *pb) res = 0;
        if (*pa > *pb) res = 1;

	return res;
}

// median

double median(double *p, int n)
{
	double *copy = (double *) calloc(n, sizeof(double));
	int i;
	double res;

	for (i = 0; i < n; i++)
		copy[i] = p[i];

	qsort((void *)copy, n, sizeof(double), compare_double);

	if (n % 2)
		res = copy[(n+1)/2-1];
	else
		res = (copy[(int)floor(n/2)-1] + copy[(int)ceil(n/2)-1]) / 2.0;

	free(copy);
	
	return res;

}

// Don t forget to initialize the random (init_random)

unsigned long mix(unsigned long a, unsigned long b, unsigned long c)
{
    	a=a-b;  a=a-c;  a=a^(c >> 13);
    	b=b-c;  b=b-a;  b=b^(a << 8);
	c=c-a;  c=c-b;  c=c^(b >> 13);
    	a=a-b;  a=a-c;  a=a^(c >> 12);
    	b=b-c;  b=b-a;  b=b^(a << 16);
    	c=c-a;  c=c-b;  c=c^(b >> 5);
    	a=a-b;  a=a-c;  a=a^(c >> 3);
    	b=b-c;  b=b-a;  b=b^(a << 10);
    	c=c-a;  c=c-b;  c=c^(b >> 15);

    	return c;
}

// init_random

void init_random(long long *seed)
{
	unsigned long s = (unsigned long)(*seed);
	if (*seed < 0)
		s = (unsigned long) mix(clock(), time(NULL), getpid());

	srand(s);

	*seed = s;
}

// drand

double drand()
{				/* uniform distribution, (0..1] */
	return (rand() + 1.0) / (RAND_MAX + 1.0);
}

// frand

float frand()
{				/* uniform distribution, (0..1] */
	return (float)(rand() + 1.0) / (RAND_MAX + 1.0);
}

// rand_binary

int rand_binary(double freq)
{
	if (frand() < freq)
		return 1;
	else 
		return 0;
}

// rand_int

int rand_int(int size)
{
	int i;
	float r = frand();
	float sum = 0;

	for (i = 0; i < size; i++) {
		sum += 1.0/size;
		if (r <= sum) {
			return i;
		}
	}
	return -1;
}

// rand_k_among_n

void rand_k_among_n(int* vect, int k, int n)
{
	int i, ip, new;

	if (k < 0 || k > n) {
		printf("Error in rand_k_among_n, %d (k) %d (n)\n", k, n);
		exit(1);
	}

	// for each element to sample
        for (i = 0; i < k; i++) {
                new = -1;
                while (new == -1) {
			// sample new element
                        new = rand_int(n);
                        ip = 0;
			// check that the element is not already selected
                        while (ip < i && new  != -1) {
                                if (new == vect[ip])
                                        new = -1;
				ip++;
                	}
		}
		vect[i] = new;
        }
}

// rand_float

float rand_float(float min, float max)
{
	return frand() * (max - min) + min;
}

// rand_double

double rand_double(double min, double max)
{
	return drand() * (max - min) + min;
}

// rand_matrix_float

void rand_matrix_float(float *A, int M, int N)
{
	int i;
	for (i = 0; i < N * M; i++) {
		A[i] = drand();
	}
}

// rand_matrix_double

void rand_matrix_double(double *A, int M, int N)
{
	int i;
	for (i = 0; i < N * M; i++) {
		A[i] = drand();
	}
}

// rand_normal

double rand_normal(double mean, double var)
{
	return sqrt(var) * sqrt(-2 * log(drand())) * cos(2 * LFMM_PI * drand()) +
	    mean;
}

// rand_normal_r

double rand_normal_r()
{
	return sqrt(-2 * log(drand())) * cos(2 * LFMM_PI * drand());
}

// mvn_rand

void mvn_rand(double *mu, double *L, int D, double *y)
{

	int i, j;
	double *x = (double *) malloc(D * sizeof(double));

	for (i = 0; i < D; i++)
		x[i] = rand_normal_r();

	for (i = 0; i < D; i++) {
		y[i] = mu[i];
		for (j = 0; j < D; j++) {
			y[i] += L[j * D + i] * x[j];
		}
	}

	free(x);
}

// rand_exp

void rand_exp(float alpha, float *r)
{
	*r = -alpha * log(frand());
}

// rand_exp_int

int rand_exp_int(float mean)
{
	float r;
	rand_exp(mean, &r);

	return (int)r + 1;
}

// rand_vector

int rand_vector(double *Pi, int size)
{
	int i;
	double r = (double)frand();
	double sum = 0;

	for (i = 0; i < size; i++) {
		sum += Pi[i];
		if (r <= sum) {
			return i;
		}
	}
	return -1;
}

// rand_gamma

double rand_gamma(int alpha, double beta)
{
	int i = 0;
	double y = 0;

	for (i = 0; i < alpha; i++) {
		y += log(drand());
	}
	y *= -beta;

	return y;
}

// zscore2pvalue in case of normality

long double zscore2pvalue(long double z)
{
	long double tmp = erfcl((long double)( z * M_SQRT1_2))/(long double)(2.0);
	tmp = (long double)(2.0)*tmp;
	return  tmp;
}

// zscore2pvalue_student

double zscore2pvalue_student(double z, int df)
{
	return 2.0 * Student_t_Distribution(-z, df);
}
