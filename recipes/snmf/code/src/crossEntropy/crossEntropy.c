/*
   crossEntropy, file: crossEntropy.c
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "../io/io_data_double.h"
#include "../io/io_tools.h"
#include "../io/io_error.h"
#include "../sNMF/print_snmf.h"
#include "register_ce.h"
#include "print_ce.h"
#include "error_ce.h"

// crossEntropy

void crossEntropy(char* input_file, char* input_file_I, char* input_file_Q, char* input_file_F,
	int K, int m, double *all_ce, double *missing_ce)
{
        //parameters initialization
	int N = 0;			// number of individuals
	int M = 0;			// number of SNPs	
	double *Q;			// matrix for ancestral admixture coefficients (of size NxK)
	double *F;			// matrix for ancestral allele frequencies (of size M x nc xK)
	int* X;				// data matrix "without" missing data 
	int* I;				// data matrix with missing data
	int nc;				// ploidy, 3 if 0,1,2 , 2 if 0,1 (number of factors)

	// local parameters 
	long double iE, aE;
	long double *qfc;
	int i, j, k, n;
	long int naE, niE;

	// local parameters to read files
        FILE *m_File = NULL;
        FILE *m_FileI = NULL;
        char token, *tok;
        int max_char_per_line;
        char *szbuff; 
        char *szbuffI; 

        // fix the number of possible factors 
        if (!m)
                m = 2;
	nc = m + 1;

        // count the number of lines and columns
        N = nb_cols_geno(input_file);
        M = nb_lines(input_file, N);
	max_char_per_line = 5*N;
        szbuff = (char *) calloc(5*N, sizeof(char));
        szbuffI = (char *) calloc(5*N, sizeof(char));

        // write command line summary
	print_summary_ce(N, M, K, m, input_file, input_file_Q, input_file_F, input_file_I);

	// memory allocation
	qfc = (long double *) calloc(nc,sizeof(long double));
	X = (int *) calloc(N,sizeof(int));
	I = (int *)calloc(N,sizeof(int));

	// read of Q and F
	Q = (double *) calloc(N*K,sizeof(double));    
	read_data_double(input_file_Q,N,K,Q); 
	F = (double *) calloc(K*nc*M,sizeof(double));  
	read_data_double(input_file_F,nc*M,K,F);

	// open files 
        m_File = fopen(input_file, "r");
        m_FileI = fopen(input_file_I, "r");

        if (!m_File)
        	print_error_global("open", input_file, 0);
        if (!m_FileI)
        	print_error_global("open", input_file_I, 0);

	// read line by line and compute criterions
        j = 0;
	iE = 0.0;
	aE = 0.0; 
	naE = 0;
	niE = 0;
	while (fgets(szbuff, max_char_per_line, m_File) && 
		fgets(szbuffI, max_char_per_line, m_FileI) &&  (j < M)) {

		// read of the X line
                i = 0;
                token = szbuff[i];
               	while(token != EOF && token != '\n' && i<N) {
		         X[i] = (int)(token - '0');
                         i++;
                         token = szbuff[i];
                }
		// test the number of columns
		test_column(input_file, m_File, i, j+1, N, &token);
		
		// read of I line
                i = 0;
                token = szbuffI[i];
               	while(token != EOF && token != '\n' && i<N) {
		         I[i] = (int)(token - '0');
                         i++;
                	 token = szbuffI[i];
                }
		// test the number of columns
		test_column(input_file_I, m_FileI, i, j+1, N, &token);

		// for this line criterion
		for (i = 0; i < N; i++) {
			for (n = 0; n < nc; n++) 
                               	qfc[n] = 0.0;
			// if not real missing data
			if (X[i] != 9) {
				// calculate prediction
				for (k = 0; k < K; k++) {
					for (n = 0; n < nc; n++) 
                                        	qfc[n] += Q[i*K+k]*F[(nc*j+n)*K+k];
				}
				// calculate CE no masked data
				if (I[i] != 9) {
					for (n = 0; n < nc; n++) {
						if (X[i] == n)
							aE += -log(qfc[n]);
					}
					naE ++;
				// calculate CE masked data
				} else if (I[i] == 9) {
					for (n = 0; n < nc; n++) {
						if (X[i] == n)
							iE += -log(qfc[n]);
					}
					niE ++;
				}
			}
		}
                j++;
	} 

	// check the number of lines
	test_line(input_file, m_File, j, M);
	tok = fgets(szbuffI, max_char_per_line, m_FileI);
	test_line(input_file_I, m_FileI, j, M);

	// calculate ce
	*all_ce = aE/naE;
	*missing_ce = iE/niE;

	// print output
	printf("Cross-Entropy (all data):\t %G\n",(double)(*all_ce));
	if (niE)
		printf("Cross-Entropy (masked data):\t %G\n",(double)(*missing_ce));

	// close file
        fclose(m_File);
        fclose(m_FileI);

	//free memory
	free(szbuff);
	free(szbuffI);
	free(Q);
	free(F);
	free(I);
	free(qfc);
	free(X);
}

