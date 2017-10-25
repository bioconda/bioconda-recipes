/*
    random_projection, file: random_projection.c
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
#include "random_projection.h"
#include "rand.h"

// create_rp (random projection)

void create_rp(double *X, int M, int Mp)
{
	int j;

	for (j = 0; j < M * Mp; j++)
		X[j] = rand_normal_r();	
}

// create_srp (sparse random projection)

void create_srp(double *X, int M, int Mp)
{
	int j;

	for (j = 0; j < M * Mp; j++)
		X[j] = rand_srp();	
}

// create_vsrp (very sparse random projection)

void create_vsrp(double *X, int M, int Mp)
{
	int j;
	double r;
	double tmp1 = 1.0 / (2.0 * sqrt(M));

	for (j = 0; j < M * Mp; j++) {
		r = drand();
		if (r < tmp1)
			X[j] = -1;
		else if (r >= tmp1)
			X[j] = 1;
		else 
			X[j] = 0;
	}
}

// project

void project(double *X, double *P, double *Xp, int N, int M, int Mp)
{
	int i, j, jp;
	double min, max;

	for (i = 0; i < N; i++) {
		for (jp = 0; jp < Mp; jp++) {
			Xp[i * Mp + jp] = 0; 
			for (j = 0; j < M; j++) {
				Xp[i * Mp + jp] += X[i * M + j] * P[j * Mp + jp]; 
			}
			Xp[i * Mp + jp] /= sqrt(Mp); 
		}
	}
	for (jp = 0; jp < Mp; jp++) {
		min = Xp[jp];
		max = Xp[jp];
		for (i = 1; i < N; i++) {
			if (Xp[i * Mp + jp] > max)
				max = Xp[i * Mp + jp];
			if (Xp[i * Mp + jp] < min)
				min = Xp[i * Mp + jp];
		}
		for (i = 0; i < N; i++) {
			Xp[i * Mp + jp] = (Xp[i * Mp + jp] - min) / (max - min);
		}	
	}

}

