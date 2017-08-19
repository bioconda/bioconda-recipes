/*
   convert, file: geno2lfmm.c
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
#include "geno2lfmm.h"
#include "geno.h"
#include "../io/io_data_int.h"
#include "../io/io_tools.h"

// geno2lfmm

void geno2lfmm (char *input_file, char* output_file, int *N, int *M)
{
	int *data;

	// number of lines and columns
	*N = nb_cols_geno(input_file);
	*M = nb_lines(input_file, *N);

	// memory allocation
	data = (int *) malloc((*N)*(*M) * sizeof(int));

	// read in geno format
	read_geno(input_file, data, *N, *M);

	// write in lfmm format
	write_data_int(output_file, *N, *M, data);

	// free memory
	free(data);
}


