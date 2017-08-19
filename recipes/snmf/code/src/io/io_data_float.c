/*
    io, file: io_data_float.c
    Copyright (C) 2012 Eric Frichot

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
#include "io_data_float.h"
#include "io_error.h"
#include "io_tools.h"
#include "../matrix/error_matrix.h"

// read_data_float

void read_data_float(char *file_data, int N, int M, float *dat)
{
        FILE *m_File = NULL;
        int i = 0;
        int j = 0;
        int max_char_per_line = MAX_LENGTH_NB_FLOAT * M + 20;
        char *szbuff;
        char *token;

	// allocate memory
	szbuff = (char *) malloc(max_char_per_line * sizeof(char));

	// open file
        m_File = fopen_read(file_data);

        i = 0;
        while (fgets(szbuff, max_char_per_line, m_File) && (i < N)) {
                j = 0;
                // cut line with split character SEP (" ")
                token = strtok(szbuff, SEP);
                // read elements and register them in dat
                while (token && j < M) {
                        //printf("%s\n",token);
                        dat[i * M + j] = (float)atof(token);
			// next elements
                        token = strtok(NULL, SEP);
                        j++;
                }
                i++;
		// check the number of columns
		test_column(file_data, m_File, j, i, M, token);
        }
	// check the number of lines
	test_line(file_data, m_File, i, N);

	// close file
        fclose(m_File);

	// free memory
	free(szbuff);
}

// write_data_float

void write_data_float(char *file_data, int N, int M, float *dat)
{
        FILE *file = NULL;
        int i, j;

	// open file
        file = fopen_write(file_data);
        if (!file)
                print_error_global("open", file_data, 0);
	// write dat
        for (i = 0; i < N; i++) {
                for (j = 0; j < M - 1; j++) {
                        fprintf(file, "%G ", dat[i * M + j]);
                }
                fprintf(file, "%G", dat[i * M + (M - 1)]);
                fprintf(file, "\n");
        }
	// close file
        fclose(file);
}

// print_data_float

void print_data_float(float *dat, int N, int M)
{
        int i, j;
	// write dat
        for (i = 0; i < N; i++) {
                for (j = 0; j < M - 1; j++) {
                        printf("%G ", dat[i * M + j]);
                }
                printf("%G", dat[i * M + (M - 1)]);
                printf("\n");
        }
}
