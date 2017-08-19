/*
   NMF, file: solvenormaleqcomb.c
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
#include "solvenormaleqcomb.h"
#include "sort.h"
#include "blockpivot.h"
#include "../matrix/inverse.h"

// solveNormalEqComb

int solveNormalEqComb(double* AtA, double* AtB, int *PassSet, 
		int N, int K, double* Z, Nnlsm_param param)
{
	int niter = 0;
	int i, k, prev_i, ip;
	int *selectK = param->selectK;
	int *selectN = param->selectN;
	int *breaks = param->breaks;
	int *sortIx = param->sortIx;
	double *sAtA = param->sAtA;
	double *inVsAtA = param->inVsAtA;
	int all = 1;
	int sK;

	// case where N == 1
	if (N == 1) {
		// fill K
		sK = 0;
		for (k=0;k<K;k++) { 
			selectK[k] = PassSet[k*N+0];
			if (PassSet[k*N+0]) 
				sK++;
		}
		selectN[0] = 1;
		// solve regression
		if (sK)
			solveRegression(AtA,AtB,selectK,selectN,sK,N,K,Z,sAtA,inVsAtA);

		return 0;
	}
	k = 0;
	while (k<K && all) {	
		i = 0;
		while (i<N && all) {	
			all = all && PassSet[k*N+i];
			i++;
		}
		k++;
	}
	// if all PassSet are true
	if (all) {
		// fill selectN and selectK
		for (i=0;i<N;i++) 
			selectN[i] = 1;
		for (k=0;k<K;k++) 
			selectK[k] = 1;
		// solve regression
		solveRegression(AtA,AtB,selectK,selectN,K,N,K,Z,sAtA,inVsAtA);
		niter ++;
	} else {
		// sort PassSet by columns with indices in sortIx
		sortCols(breaks, sortIx, PassSet, K, N, param);
		prev_i = 0;
		selectN[sortIx[N-1]] = 1;
		for (i=1;i<N;i++) {
			// for each similar block of columns in PassSet
			if (breaks[i] || i == N-1) {
				// to manage last column
				if (i == N-1 && !breaks[i])
					i++;
				// fill selectK and selectN
				sK = 0;
				for (k=0;k<K;k++) { 
					selectK[k] = PassSet[k*N+sortIx[i-1]];
					if (PassSet[k*N+sortIx[i-1]]) 
						sK++;
				}
				for (ip=prev_i;ip<i;ip++)
					selectN[sortIx[ip]] = 1;
				// solve regression
				if (sK)
					solveRegression(AtA,AtB,selectK,selectN,sK,N,K,Z,sAtA,inVsAtA);
				// clean selectN
				for (ip=prev_i;ip<i;ip++)
					selectN[sortIx[ip]] = 0;
				prev_i=i;
				niter ++; 
			}
		}
		// last similar block of columns in PassSet
		if (breaks[N-1]) {
			// fill selectK and selectN
			i = N;
			prev_i = N-1;
                        sK = 0;
                        for (k=0;k<K;k++) { 
                                selectK[k] = PassSet[k*N+sortIx[i-1]];
                                if (PassSet[k*N+sortIx[i-1]])
					sK++;
                        }
                        for (ip=prev_i;ip<i;ip++)
                                selectN[sortIx[ip]] = 1;
			// solve regression
                        solveRegression(AtA,AtB,selectK,selectN,sK,N,K,Z,sAtA,inVsAtA);
		}
	}

	return niter;
}

// solveRegression

// update Z, from the regression solution. For SelectK and selectN. 
void solveRegression (double *AtA, double* AtB, int *selectK, int* selectN, 
		int sK, int N, int K, double* Z, double *sAtA, double *inVsAtA)
{
	int k1,k2, sk1, sk2, i;
	// select elements of AtA in selectK
	sk1 = 0;
	for (k1=0; k1<K; k1++) {
		if (selectK[k1]) {
			sk2 = 0;
			for (k2=0; k2<K; k2++) {
				if (selectK[k2]) {
					sAtA[sk1*sK+sk2] = AtA[k1*K+k2];
					sk2 ++;
				}
			}
			sk1 ++;
		}
	}
	// inverse sAtA
	if (sK>1)
		fast_inverse(sAtA,sK,inVsAtA);
	else
		inVsAtA[0] = 1/sAtA[0];

	// calculate for invSata*AtB for selectK and selectN 
	sk1 = 0;
	for (k1=0; k1<K; k1++) {
		if (selectK[k1]) {
			for (i=0; i<N; i++) {
				if (selectN[i]) {
					Z[k1*N+i] = 0;
					sk2 = 0;
					for (k2=0; k2<K; k2++) {
						if (selectK[k2]) {
							Z[k1*N+i] += inVsAtA[sk1*sK+sk2]*AtB[k2*N+i];
							sk2++;
						}
					}
				}
			}
			sk1++;
		} else {
		// for elements not in selectK, fill lines with 0
			for (i=0; i<N; i++) {
				if (selectN[i]) {
					Z[k1*N+i] = 0;
				}
			}
		}
	}
}

