/*
   convert, file: geno.c
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
#include "geno.h"
#include "../io/io_error.h"
#include "../io/io_tools.h"

// read_geno

void read_geno(char *input_file, int *data, int N, int M)
{
	FILE *m_File=NULL;
	int j = 0;
	char *szbuff = (char *) calloc(5*N, sizeof(char));
	int max_char_per_line = 5*N;
	int warning = 0;

	// open file
	m_File = fopen_read(input_file);

	// first line
	while(fgets(szbuff,max_char_per_line,m_File) && (j<M)) {
		// fill current line
		fill_line_geno(data, M, N, j, input_file, m_File, szbuff, &warning);
		j ++;
	}

	// check the number of lines
	test_line(input_file, m_File, j, M);

	// close file
	fclose(m_File);

	// free memory
	free(szbuff);
}

// fill_line_geno

void fill_line_geno(int* data, int M, int N, int j, char *file_data, FILE* m_File, 
	char *szbuff, int *warning)
{
	int i = 0;
	char token;

	// get first token
	token = szbuff[i];

	// for all token
	while(token != EOF && token != 10 && i<N) {

		// fill current column
		data[i*M+j] = (int)(token - 48);
		// if not 9, 1, 2 or 0
		if (!(*warning) && token != '9' && token != '1' && token != '2' && token != '0') {
			printf("Warning: some genotypes are not 0, 1, 2 or 9.\n");
			printf("\t First warning at ligne %d, column %d.\n\n", j+1, i+1);
			*warning = 1;
		}
		i++;

		// next column
		token = szbuff[i];
	}
	// check the number of columns
	test_column(file_data, m_File, i, j+1, N, &token);
}

// write_geno

void write_geno(char *output_file, int N, int M, int *data)
{
	FILE *file = NULL;
	int i, j;
	// open file
	file = fopen_write(output_file);

	// write dat
	for (j = 0; j < M; j++) {
		for (i = 0; i < N; i++) {
			fprintf(file, "%d", data[i * M + j]);
		}
		fprintf(file, "\n");
	}
	// close file
	fclose(file);
}

// write_geno_line

// not used 
void write_geno_line(FILE* File, int* line, int N)
{
	int i = 0;

	for (i = 0; i < N; i++)
		fprintf(File, "%d", line[i]);

	fprintf(File,"\n");
}
