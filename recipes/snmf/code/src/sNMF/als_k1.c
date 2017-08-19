/*
   sNMF, file: als_k1.c
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
#include <string.h>
#include <math.h>
#include "als_k1.h"
#include "sNMF.h"
#include "../bituint/bituint.h"

// ALS

void ALS_k1(sNMF_param param)
{
	int i, j, c, jc, jd, jm;
	int nc = param->nc;
	int N = param->n;
	int M = param->L;
	int *count_nc = (int *) calloc(param->nc, sizeof(int));
	double *F = param->F;

	// calculate Q
	for (i = 0; i < N; i++)
		param->Q[i] = 1; 

	// calculate F
        // for all SNPs
        for (j = 0; j < M; j++) {
		// init
                for (c = 0; c < nc; c++)
			count_nc[c] = 0;
                // for all individuals, count
                for (i = 0; i < N; i++) {
                        for (c = 0; c < nc; c++) {
                                jc = nc * j + c;
                                jd = jc / SIZEUINT; // column in dat
                                jm = jc % SIZEUINT; // mask element
                                if (param->X[i * param->Mp + jd] & mask[jm])
					count_nc[c]++;
                        }
                }
		// frequencies
                for (c = 0; c < nc; c++)
			F[j*nc+c] = (double)count_nc[c] / (double) (N);
        }

        for(j = 0; j < M; j++) {
                for (c = 0; c < nc; c++) {
                        if (fabs(F[nc*j+c]) < 0.0001)
                                F[nc*j+c] = 0.0001;
                        if (fabs(1-F[nc*j+c]) < 0.0001)
                                F[nc*j+c] = 1-0.0001;
                }
        }

	free(count_nc);
}

