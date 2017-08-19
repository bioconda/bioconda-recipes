/**
 * @addtogroup io_geno_bituint
 * @ingroup bituint
 * @{
 * @file io_geno_bituint.h
 *
 * @brief set of functions to read, write and print data in geno format file 
 * 	with bituint data memory format.
 */

#ifndef IO_GENO_BITUINT_H
#define IO_GENO_BITUINT_H

#include <stdint.h>
#include "bituint.h"

/**
 * read data file with M lines, N columns and nc different elements
 * and input missing data
 *  
 * @param file_data	data file name	
 * @param N	number of lines of the matrix
 * @param M	number of elements per line in the data file
 * @param Mp	number of columns of the matrix
 * @param nc	number of different elements of the matrix
 * @param dat  	output data matrix 
 */
void read_geno_bituint(char *file_data, int N, int M, int Mp, int nc, 
			bituint* dat);

/**
 * read a line of data file with N elements and fill dat
 * 
 * @param dat  	data matrix (of size NxMc)
 * @param Mc	number of columns of dat
 * @param cmax	max number of elements of szbuff
 * @param j	current line
 * @param nc	number of different elements of the matrix
 * @param file_data	data file name	
 * @param szbuff	line to read
 * @param m_file	opened file
 * @param I	missing data temporary vector
 * @param nb	vector to count the number of occurences of each genotype
 */
void fill_line_geno_bituint(bituint* dat, int Mp, 
			int cmax, int j, int nc, char *file_data,  
			char* szbuff, FILE* m_File, int* I, double *nb);

/**
 * print data from bituint format in geno format
 *
 * @param dat  	data matrix (of size NxMc)
 * @param N	number of lines of the matrix
 * @param nc	number of different elements of the matrix
 * @param Mp	number of columns of the matrix
 * @param M	number of elements per line in the data file
 */
void print_geno_bituint(bituint* dat, int N, int nc, int Mp, int M);

/**
 * write data from bituint format in geno format
 *
 * @param file_data	data file name	
 * @param N	number of lines of the matrix
 * @param nc	number of different elements of the matrix
 * @param Mp	number of columns of the matrix
 * @param M	number of elements per line in the data file
 * @param dat  	data matrix (of size NxMc)
 */
void write_geno_bituint(char *file_data, int N, int nc, int Mp, int M, bituint *dat);

/**
 * select from X a subset of Mi columns and copy them into Xi
 *
 * @param X	X matrix we copy from
 * @param Xi	Xi matrix we copy to
 * @prama N	number of lines
 * @param M	number of elements per line in X
 * @param Mi	number of elements per line in Xi
 * @param nc	number of different elements of the matrix
 * @param Mp	number of columns of X
 * @param Mpi	number of columns of Xi
*/
void select_geno_bituint(bituint *X, bituint *Xi, int N, int M, int Mi,
	int nc, int Mpi, int Mp);

#endif // IO_GENO_BITUINT_H

/** @} */
