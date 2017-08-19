/**
 * @addtogroup io_data_float
 * @ingroup io
 * @{
 * @file io_data_float.h
 *
 * @brief functions to read (and write) data matrices and register them with float type
 */

#ifndef IO_DATA_FLOAT_H
#define IO_DATA_FLOAT_H

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
void read_data_float(char *file_data, int N, int M, float *dat);

/**
 * write dat into file_data with %G separated by a space
 *
 * @param file_data     the file where to write
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 * @param dat   the matrix to write
 */
void write_data_float(char *file_data, int N, int M, float *dat);

/**
 * print dat with %G separated by a space
 *
 * @param file_data     the file where to write
 * @param N     the number of lines of dat
 * @param M     the number of columns of dat
 * @param dat   the matrix to write
 */
void print_data_float(float *dat, int N, int M);

#endif // IO_DATA_FLOAT_H

/** @} */
