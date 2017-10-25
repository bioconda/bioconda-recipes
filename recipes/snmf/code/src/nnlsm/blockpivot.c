/*
   NMF, file: blockpivot.c
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
#include "blockpivot.h"
#include "solvenormaleqcomb.h"
#include "../matrix/inverse.h"

// update_Y

void update_Y(double *AtA, double *AtB, double *X, double *Y, int N, int K)
{
	int i, k1, k2;
	double temp;
	// calculate Y = AtAX - AtB
	for (k1=0;k1<K;k1++) {
		for (i=0; i < N; i++) {
			temp = 0;
			for (k2=0;k2<K;k2++) 
				temp += AtA[k1*K+k2]*X[k2*N+i];
			Y[k1*N+i] = temp - AtB[k1*N+i];
		}
	}
}

// parameter_init

int parameter_init(int* PassiveSet, int* NotGood, int* Ninf, int* P,int K, int N, double *X)
{
	int k,i, all = 1;
	// PassiveSet init
	for (k=0;k<K;k++) {
		for (i=0;i<N;i++) {
			PassiveSet[k*N+i] = X[k*N+i] > 0;
			all = all &&  X[k*N+i] == 0;
		}
	}
	// NotGood init
	for (i=0;i<N;i++)	
		NotGood[i] = 1;
	// init P, Ninf
	for (i=0;i<N;i++) {
		P[i] = 3;
		Ninf[i] = K+1;
	}

	return all;
}

// opt_param_update

void opt_param_update(int *PassiveSet, int *NotGood, int *NonOptSet, 
	int* InfeaSet, double *X, double *Y, int* NotOptCols_nb, int N, int K)
{
	int i, k, prevNotGood;
	// NonOptSet, InfeaSet, NotGood update
	for (i=0;i<N;i++) {
		prevNotGood = NotGood[i];
		NotGood[i] = 0;
		for (k=0;k<K;k++) {
			if(prevNotGood && Y[k*N+i] < 0 && !PassiveSet[k*N+i]) {
				NonOptSet[k*N+i] = 1;
				NotGood[i] ++;
			} else {
				NonOptSet[k*N+i] = 0;
			}
			if(prevNotGood && X[k*N+i] < 0 && PassiveSet[k*N+i]) {
				InfeaSet[k*N+i] = 1;
				NotGood[i] ++;
			} else {
				InfeaSet[k*N+i] = 0;
			}
		}
	}			
	// update NotOptCols_nb
	*NotOptCols_nb = 0;
	for (i=0;i<N;i++) {
		if (NotGood[i])
			(*NotOptCols_nb)++;
	}
}

// PassiveSet_update

void PassiveSet_update(int *NotGood, int *Ninf, int *P, int pbar, 
	int *NonOptSet, int* PassiveSet, int *InfeaSet, int N, int K, int *Cols3Ix)
{
	int i, k;

	for (i=0;i<N;i++) {
		Cols3Ix[i] = 0;
		if (NotGood[i]) {
			// Cols1[i]
			if (NotGood[i] < Ninf[i]) {
				P[i] = pbar;
				Ninf[i] = NotGood[i];
				for (k=0;k<K;k++) {
					if (NonOptSet[k*N+i])
						PassiveSet[k*N+i] = 1;
					else if (InfeaSet[k*N+i])
						PassiveSet[k*N+i] = 0;
				}
			} else {
				// Cols2[i]
				if (P[i] >= 1) {
					P[i] --;
					for (k=0;k<K;k++) {
						if (NonOptSet[k*N+i])
						PassiveSet[k*N+i] = 1;
						else if (InfeaSet[k*N+i])
							PassiveSet[k*N+i] = 0;
					}
				// Cols3[i]
				} else {
					Cols3Ix[i] = 1;
				}
			}
		}
	}
	// Cols3[i]
	for (i=0;i<N;i++) {
		if (Cols3Ix[i]) {
			k = K-1;
			while (k >= 0 && !(NonOptSet[k*N+i] || InfeaSet[k*N+i])) 
				k--;
			PassiveSet[k*N+i] = !PassiveSet[k*N+i];
		}
	}
}

// XY_update

int XY_update(double *AtA, double *AtB, int *PassiveSet, int *NotGood, 
	int NotOptCols_nb, int N, int K, double *X, double *Y, Nnlsm_param param)
{
	double *subX = param->subX;
	double *subY = param->subY;
	double *subAtB = param->subAtB;
	int *subPassiveSet = param->subPassiveSet;
	int k,i, subiter, si;
	int sN = NotOptCols_nb;	

	// if all columns have to be updated
	if (NotOptCols_nb == N) {
		// solve X
		subiter = solveNormalEqComb(AtA, AtB, PassiveSet, NotOptCols_nb, K, X, param);
		// update Y
		update_Y(AtA, AtB, X, Y, NotOptCols_nb, K);
		
		return subiter;
	}

	// fill subAtB, subPassiveSet, subX, and subY
	for (k=0;k<K;k++) {
		si = 0;
		for (i=0;i<N;i++) {
			if (NotGood[i]) {
				subX[k*sN+si] = X[k*N+i];
				subAtB[k*sN+si] = AtB[k*N+i];
				subPassiveSet[k*sN+si] = PassiveSet[k*N+i];
				si ++;
			}
		}
	}

	// solve X
	subiter = solveNormalEqComb(AtA, subAtB, subPassiveSet, NotOptCols_nb, K, subX, param);

	// for stability
	for (k=0;k<K;k++) {
		si = 0;
		for (i=0;i<N;i++) { // not all i used
			if (NotGood[i]) {
				if (fabs(subX[k*sN+si])< 1e-5) 
					subX[k*sN+si] = 1e-5;
				X[k*N+i] = subX[k*sN+si];
				si ++;
			}
		}
	}

	// update_Y
	update_Y(AtA, subAtB, subX, subY, NotOptCols_nb, K);
	// for stability
	for (k=0;k<K;k++) {
		si = 0;
		for (i=0;i<N;i++) {
			if (NotGood[i]) {
				if (fabs(subY[k*sN+si])< 1e-5)
					subY[k*sN+si] = 1e-5;
				Y[k*N+i] = subY[k*sN+si];
				si ++;
			}
		}
	}

	return subiter;
}
