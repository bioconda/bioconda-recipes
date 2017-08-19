/*
   createDataSet, file: createDataSet.c
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
#include "../io/io_tools.h"
#include "../io/io_error.h"
#include "register_cds.h"
#include "print_cds.h"
#include "error_cds.h"
#include "../sNMF/print_snmf.h"
#include "../matrix/rand.h"
#include "../matrix/data.h"
#include "../matrix/matrix.h"

// createDataSet

void createDataSet(char* input_file, long long seed, double e, char* output_file) 
{
	int N = 0;			// number of individuals
	int M = 0;			// number of SNPs
	int X;				// genotype 
	
	// local parameters
	int i, j;

        // local parameters to read files
        FILE *in_File = NULL;
        FILE *out_File = NULL;
        char token;

	init_random(&seed);

        // count the number of lines and columns
        N = nb_cols_geno(input_file);
        M = nb_lines(input_file, N);

	// write command line summary
	print_summary_cds(N, M, seed, e, input_file, output_file);

        // open files 
        in_File = fopen(input_file, "r");
        out_File = fopen(output_file, "w");

        if (!in_File)
                print_error_global("open", input_file, 0);
        if (!out_File)
                print_error_global("open", output_file, 0);

	// read and write at the same time
        j = 0;
      	while (!feof(in_File) & (j < M)) {

                // read a line
                i = 0;
	        token = (char)fgetc(in_File);

		// for each column of the line
	        while(token != EOF && token != '\n' && i<N) {

	                X = (int)(token - '0');
			//  write the new genotype	
                	if (frand() < e) 
				fprintf(out_File,"9");
			else 
				fprintf(out_File,"%d",X);

                         i++;
	        	 token = (char)fgetc(in_File);
                }
		fprintf(out_File,"\n");

		// test the number of columns
		test_column(input_file, in_File, i, j, N, &token);
                j++;
	}

	// close file
	fclose(in_File);	
	fclose(out_File);

        printf("\n Write genotype file with masked data, %s:\t\tOK.\n\n",output_file);
}

