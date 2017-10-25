/**
 * @addtogroup io_data_double
 * @ingroup io
 * @{
 * @file io_data_double.h
 *
 * @brief functions to read (and write) data matrices and register them with double type
 */

#ifndef IO_DATA_DOUBLE_H
#define IO_DATA_DOUBLE_H

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
void read_data_double(char *file_data, int N, int M, double *dat);

/**
 * write dat into file_data with %G separated by a space
 *
 * @param file_data     the file where to write
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 * @param dat   the matrix to write
 */
void write_data_double(char *file_data, int N, int M, double *dat);

/**
 * print dat with %G separated by a space
 *
 * @param dat   the matrix to write
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 */
void print_data_double(double *dat, int N, int M);

#endif // IO_DATA_DOUBLE_H

/** @} */
