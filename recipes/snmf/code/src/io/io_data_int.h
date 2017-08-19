/**
 * @addtogroup io_data_int
 * @ingroup io
 * @{
 * @file io_data_int.h
 *
 * @brief functions to read data matrices and register them with int type
 */

#ifndef READ_DATA_INT_H
#define READ_DATA_INT_H

#include "read.h"

/**
 * read file_data and write it in dat and print errors
 * if file_dat does not contain the correct number of lines/columns
 *
 * @param file_data	name of the data_file
 * @param N	the number of lines
 * @param M	the number of columns
 * @param dat	the output matrix (of size NxM)
 */
void read_data_int(char *file_data, int N, int M, int *dat);

/**
 * write dat into file_data with %d separated by a space
 *
 * @param file_data     the file where to write
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 * @param dat   the matrix to write
 */
void write_data_int(char *file_data, int N, int M, int *dat);

/**
 * print dat %d separated by a space
 *
 * @param dat   the matrix to print
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 */
void print_data_int(int *dat, int N, int M);

#endif // READ_DATA_INT_H

/** @} */
