/*
 *     convert, file: ancestrymap.c
 *     Copyright (C) 2013 Eric Frichot
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "ancestrymap.h"
#include "geno.h"
#include "../io/io_tools.h"
#include "../io/io_error.h"
#include "../io/io_data_int.h"
#include "../io/read.h"
#include "register_convert.h"

// ancestrymap2geno

void ancestrymap2geno (char *input_file, char* output_file, int *N, int *M)
{
	int *data;
	int nb;
	double tmp;

	// number of lines and columns
	*N = nb_ind_ancestrymap(input_file);
	nb = nb_lines(input_file, 1000);
	tmp = (double)nb / (double)(*N);
	if (tmp != floor(tmp)) {
		printf("Error: incorrect number of lines in %s.\n",input_file);
		exit(1);
	}
	*M = (int)tmp;

	// allocate_memory
	data = (int *) malloc((*N)*(*M) * sizeof(int));

	// read in ancestrymap format
	read_ancestrymap(input_file, *N, *M, data);

	// write in geno format
	write_geno(output_file, *N, *M, data);

	// free memory
	free(data);
}


// ancestsrymap2lfmm

void ancestrymap2lfmm (char *input_file, char* output_file, int *N, int *M)
{
	int *data;
	int nb;
	double tmp;

	// set the number of individuals (N) and the number of loci (M)
	*N = nb_ind_ancestrymap(input_file);
	nb = nb_lines(input_file, 1000);
	tmp = (double)nb / (double)(*N);
	if (tmp != floor(tmp)) {
		printf("Error: incorrect number of lines in %s.\n",input_file);
		exit(1);
	}
	*M = (int)tmp;

	// allocate memory
	data = (int *) malloc((*N)*(*M) * sizeof(int));

	// read in ancestrymap format
	read_ancestrymap(input_file, *N, *M, data);

	// write in lfmm format
	write_data_int(output_file, *N, *M, data);

	// free memory
	free(data);
}


// read_ancestrymap

void read_ancestrymap (char* input_file, int N, int M, int* data)
{
	FILE *File = NULL;
	int i, j, allele;
	char tmp[512] = "";
	char ref[512] = "";
	int max_char_per_line = 1000;
	char szbuff[max_char_per_line];
	int warning = 0;

	// open input file
	File = fopen_read(input_file);

	j = 0;
	i = 0;
	// while not the end of the file
	//	or not too many SNPs (j < M-1)
	//	or last SNP but not too many ind (j == (M-1) && i< N))
	while (fgets(szbuff,max_char_per_line, File) && (j < M-1 || (j == (M-1) && i< N))) {

		// read line
		read_line_ancestrymap(szbuff, &allele, tmp, i+1, j+1, input_file, &warning);

		// first SNP, save SNP name
		if (j == 0 && i == 0)
			strcpy(ref, tmp);

		// new SNP
		if (strcmp(ref, tmp) != 0) {
			// test if the number individual for the line is ok
			test_column (input_file, File, i, j+1, N, NULL);
			// new line
			i = 0;
			j++;
			// save new SNP name
			strcpy(ref, tmp);
		} 

		// write genotype
		data[i * M + j] = allele;

		i++;
	}
	test_column (input_file, File, i, j+1, N, NULL);

	// test the number of lines
	test_line(input_file, File, j+1, M);

	fclose(File);
}

// read_line

void read_line_ancestrymap(char *szbuff, int *allele, char *name, int i, int j, 
		char *input, int *warning) 
{
	char* token;

	// read first column
	token = strtok(szbuff, SEP);
	if (token) {
		// save SNP name
		strcpy (name, token);
		// read second column
		token = strtok(NULL, SEP);
		if (token) {	
			// read the third column
			token = strtok(NULL, SEP);
			if (token) {
				// save the genotype
				*allele = (int)atoi(token);
			} else {
			// only 2 columns
				printf("Error while reading %s file at individual %d,"
						" SNP %d.\n\n", input, i, j);
				exit(1);
			}
		} else {
		// only 1 column
			printf("Error while reading %s file at individual %d,"
					" SNP %d.\n\n", input, i, j);
			exit(1);
		}
	} else {
	// no column
		printf("Error while reading %s file at individual %d,"
				" SNP %d.\n\n", input, i,j);
		exit(1);
	}

	// if not 0, 1, 2, or 9
	if (!(*warning) && *allele != 9 && *allele != 1 && *allele != 2 && *allele != 0) {
		printf("Warning: some genotypes are not 0, 1, 2 or 9 in %s.\n",input);
		printf("\t First warning at individual %d, column %d.\n\n", j, i);
		*warning = 1;
	}
}

// nb_ind_ancestrymap

int nb_ind_ancestrymap(char *input_file)
{
	FILE* File=NULL;
	int max_char_per_line = 1000;
	int nb = 0, diff = 0;
	char szbuff[max_char_per_line];
	char *token;
	char tmp[512] = "";

	// open input file
	File = fopen_read(input_file);

	// first line
	token = fgets(szbuff, max_char_per_line, File);
	token = strtok(szbuff, SEP);
	strcpy(tmp,token);

	// while still the same SNP, count
	while (!feof(File) && !diff) {
		token = fgets(szbuff, max_char_per_line, File);
		token = strtok(szbuff, SEP);

		// compare the current name with the first name
		diff = strcmp(tmp,token) != 0;
		nb ++;
	}

	// close file
	fclose(File);
	return nb;
}
