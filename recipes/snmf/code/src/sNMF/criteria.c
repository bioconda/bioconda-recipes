/*
   NMF, file: criteria.c
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
#include "criteria.h"
#include "sNMF.h"
#include "../bituint/bituint.h"

// least_square

double least_square(sNMF_param param)
{
	int i, k;
	double like = 0.0;
	double tmp;
	double *Q = param->Q;
	double *F = param->F;
	bituint *X = param->X;

	int N = param->n;
	int K = param->K;
	int Mc = param->Mc;
	int Mp = param->Mp;
	bituint value;
        int Md = Mc / SIZEUINT;
        int Mm = Mc % SIZEUINT;
        int jd, jm;

	// for each individual
        for(i = 0; i < N; i++) {
		// least square part
                for (jd = 0; jd<Md; jd++) {
                        value = X[i*Mp+jd];
                        for (jm = 0; jm<SIZEUINT; jm++) {
				tmp = 0.0;
                                for (k = 0; k < K; k++)
                                	tmp += F[(jd*SIZEUINT+jm)*K+k] * Q[i*K+k];
                                //if (value & mask[jm]) 
                                if (value % 2) 
					like += (1.0-tmp)*(1.0-tmp);
                                else
					like += tmp*tmp;
			value >>=1;
			}
		}
                value = X[i*Mp+Md];
                for (jm = 0; jm<Mm; jm++) {
			tmp = 0.0;
                        for (k = 0; k < K; k++)
                              	tmp += F[(Md*SIZEUINT+jm)*K+k] * Q[i*K+k];
                        //if (value & mask[jm]) 
                        if (value % 2) {
				like += (1.0-tmp)*(1.0-tmp);
                        } else {
				like += tmp*tmp;
			}
		value >>=1;
                }
		/*
		// regularization part
		n1i = 0.0;
		for (k = 0; k < K; k++)
                        n1i += fabs(Q[i*K+k]);
		norm1 += n1i * n1i;
		*/
	}

	// likelihood
	// like += 2*sqrt(alpha)*norm1;

	return like;
}
