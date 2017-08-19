/**
 * @addtogroup geno
 * @ingroup convert
 * @{
 * @file geno.h
 *
 * @brief functions to read/write files in the geno format.
 * 
 * The functions to count the number of line (nb_lines) and
 * the number of columns (nb_cols_geno) of a file in the 
 * geno format are in io/io_tools.h
 */

#ifndef GENO_H
#define GENO_H

/**
 * read the file in the geno format of size (NxM) and fill data
 *
 * It raises an error if the number of lines is different from M.
 *
 * @param file_data     data file name
 * @param data  	the data set (of size NxM)
 * @param N     	the number of columns
 * @param M     	the number of lines
 */
void read_geno(char *input_file, int *data, int N, int M);

/**
 * Process a line (stored in szbuff) in the geno format and fill data
 * 
 * It raises an error if the number of columns is different from N.
 * It raises a warning if the genotype is different from 0,1,2, or 9.
 *
 * @param data  	the data set (of size NxM)
 * @param M     	the number of lines
 * @param N     	the number of columns
 * @param j    		the number of the current line (from 0)
 * @param file_data     data file name
 * @param m_file	data file
 * @param szbuff     	line to read (previously read by fgets)
 * @param warning	Boolean: true if a warning has already been diplayed.
 *				 false otherwise
 */
void fill_line_geno (int* data, int M, int N, int j, char *file_data, FILE* m_File, 
	char *szbuff, int *warning);

/**
 * write the file in the geno format from data (of size NxM)
 *
 * @param output_file   output file name
 * @param N     	the number of columns
 * @param M     	the number of lines
 * @param data  	the data set (of size NxM)
 */
void write_geno(char* output_file, int N, int M, int *data);

/**
 * write a line of a geno data into geno file (not used by write_geno)
 *
 * @param File		geno file opened
 * @param line		geno line data
 * @param N		size of line
 */
void write_geno_line(FILE* File, int* line, int N);

#endif /** @} GENO_H */
