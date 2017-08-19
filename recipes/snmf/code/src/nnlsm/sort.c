/*
   NMF, file: sort.c
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
#include "sort.h"

// sortCols

void sortCols(int* breaks, int* sortIx, int* X, int K, int N, Nnlsm_param param)
{
	int i;
	int* tempSortIx = param->tempSortIx;
	// init
	for (i = 0; i < N; i++) {
		breaks[i] = 0;
		sortIx[i] = i;
	}
	breaks[0] = 1;
	// recursive call
	sortColsRec(breaks, sortIx, X, K, N, 0, N, 0,tempSortIx);
	//free(tempSortIx);
}

// sortColsRec

void sortColsRec(int* breaks, int* sortIx, int* X, int K, int N, int startN, 
		 int endN,int k, int* tempSortIx)
{
	int i,il = startN, ir = endN;
	//int* tempSortIx; 
	// special cases
	if(startN >= endN)
		return;
	if (endN - startN == 1) { 	// only one element
		breaks[startN] = 1;
		return;
	}
	for (i = 0; i < endN - startN; i++)
		tempSortIx[i] = sortIx[startN + i];
	// for all columns in our range
	for(i = startN; i < endN; i++) { 
		if (X[k * N + tempSortIx[i - startN]]) { 
			ir--;
			// add the index on the right of sortIx
			sortIx[ir] = tempSortIx[i - startN];	
		} else { 
			// add the index on the left of sortIx
			sortIx[il] = tempSortIx[i - startN];
			il++;
		} 
	}

	if (il != ir) {
		// Internal Error. This property should be always verified.
		printf("Internal error: il != ir, in sortColsRec\n");
		//free(tempSortIx);
		exit(1);
	}
	// add a break (ie true) at the index where the value (false/true) change
	//breaks[startN] = 1;
	if (il != startN && ir != endN) 
		breaks[ir] = 1;

	k++;	// for next line
	if (k < K) { // if not last line
		// sort columns with false on the current line
		sortColsRec(breaks,sortIx,X,K,N,startN,il,k,tempSortIx);
		// sort columns with true on the current line
		sortColsRec(breaks,sortIx,X,K,N,ir,endN,k,tempSortIx);
	}
}
