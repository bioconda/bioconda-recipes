/*
   NMF, file: nnlsm.c
   Copyright (C) 2013 François Mathieu, Eric Frichot

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
#include "nnlsm.h"
#include "blockpivot.h"
#include "solvenormaleqcomb.h"
#include "../matrix/inverse.h"

// allocate_nnlsm

Nnlsm_param allocate_nnlsm(int N, int K)
{
	Nnlsm_param param = (Nnlsm_param) malloc(1 * sizeof(nnlsm_param));

	param->P = (int *)calloc(N,sizeof(int));
	param->Ninf = (int *)calloc(N,sizeof(int));
	param->PassiveSet = (int *)calloc(N*K,sizeof(int));
	param->NonOptSet = (int *)calloc(N*K,sizeof(int));
	param->InfeaSet = (int *)calloc(N*K,sizeof(int));
	param->NotGood = (int *)calloc(N,sizeof(int));
	param->Cols3Ix = (int *)calloc(N,sizeof(int));
	param->subX = (double *)calloc(N*K,sizeof(double));
	param->subY = (double *)calloc(N*K,sizeof(double));
	param->subAtB = (double *)calloc(N*K,sizeof(double));
	param->subPassiveSet = (int *)calloc(N*K,sizeof(int));
	param->selectK = (int *)calloc(K,sizeof(int));
	param->selectN = (int *)calloc(N,sizeof(int));
	param->breaks = (int *)calloc(N,sizeof(int));
	param->sortIx = (int *)calloc(N,sizeof(int));
	param->sAtA = (double *)calloc(K*K,sizeof(double));
	param->inVsAtA = (double *)calloc(K*K,sizeof(double));
        param->tempSortIx = (int *)calloc(N,sizeof(int));
        param->Y = (double *)calloc(K*N,sizeof(double));

	return param;
}

// free_nnlsm

void free_nnlsm(Nnlsm_param param)
{
	free(param->P);
	free(param->Ninf);
	free(param->PassiveSet);
	free(param->NonOptSet);
	free(param->InfeaSet);
	free(param->NotGood);
	free(param->Cols3Ix);
	free(param->subX);
	free(param->subY);
	free(param->subAtB);
	free(param->subPassiveSet);
	free(param->selectK);
	free(param->selectN);
	free(param->breaks);
	free(param->sortIx);
	free(param->sAtA);
	free(param->inVsAtA);
	free(param->tempSortIx);
	free(param->Y);
}

// nnlsm_blockpivot

int nnlsm_blockpivot(double* AtA, double* AtB, int N, int K, double *X, double *Y,
	Nnlsm_param param)
{
	int niter = 0, bigiter, zeros;
	int maxiter = 5*K;
	int* P = param->P;
	int* Ninf = param->Ninf;
	int* PassiveSet = param->PassiveSet;
	int* NonOptSet = param->NonOptSet;
	int* InfeaSet = param->InfeaSet;
	int* NotGood = param->NotGood;
	int* Cols3Ix = param->Cols3Ix;
	int NotOptCols_nb, pbar;

	// init
	pbar = 3;
	zeros = parameter_init(PassiveSet, NotGood, Ninf, P, K, N, X);
	if (!zeros)
		niter += XY_update(AtA, AtB, PassiveSet, NotGood, N, N, K, X, Y, param);
	else 
		update_Y(AtA, AtB, X, Y, N, K);
	// opt_param
	opt_param_update(PassiveSet, NotGood, NonOptSet, InfeaSet, X, Y,&NotOptCols_nb, N, K);
	// main loop
	bigiter = 1;
	while (NotOptCols_nb && bigiter <= maxiter) {
		bigiter ++;
		// P and PassiveSet update
		PassiveSet_update(NotGood, Ninf, P, pbar, NonOptSet, PassiveSet, InfeaSet, N, K, Cols3Ix);
		// X and Y update
		niter += XY_update(AtA, AtB, PassiveSet, NotGood, NotOptCols_nb, N, K, X, Y, param);
		// opt_param update
		opt_param_update(PassiveSet, NotGood, NonOptSet, InfeaSet, X , Y, &NotOptCols_nb, N, K);
		bigiter++;
	}

	return niter;
}

