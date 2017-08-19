/**
 * @addtogroup io_tools
 * @ingroup io
 * @{
 * @file io_tools.h
 *
 * @brief tools to read and write data files
 */

#ifndef IO_TOOLS_H
#define IO_TOOLS_H

#include <string.h>
#include <stdio.h>

/**
 * change the extension of input into output with ext extension
 *
 * @param input		input file
 * @param output	output file with ext extension
 * @param ext		the extension
 */
void change_ext(char *input, char *output, char *ext);

/** 
 * removes the "extension" from a file spec.
 *
 * @param mystr 	is the string to process.
 * @param dot 		is the extension separator.
 * @param sep 		is the path separator (0 means to ignore).
 *
 * @return an allocated string identical to the original but
 *   with the extension removed. It must be freed when you're
 *   finished with it.
 *   If you pass in NULL or the new string can't be allocated,
 *   it returns NULL.
 */
char* remove_ext(char* mystr, char dot, char sep);

/**
 * count the number of lines of a file
 *
 * @param file 	file name
 * @param M	number of columns of each line
 *
 * @return number of lines
 */
int nb_lines (char *file, int M);

/**
 * count the number of elements of the first line of a file (in geno format)
 *
 * @param file 
 *
 * @return number of columns of the first line
 */
int nb_cols_geno(char *file);

/**
 * count the number of elements of the first line of a file (in lfmm format)
 *
 * @param file 
 *
 * @return number of columns of the first line
 */
int nb_cols_lfmm(char *file);

/**
 * open a file to read it and raise an error if necessary 
 * 
 * @param file_data	file to open
 *
 * return opened file
 */
FILE* fopen_read (char *file_data);

/**
 * open a file to write and raise an error in necessary
 * 
 * @param file_data	file to open
 *
 * return opened file
 */
FILE* fopen_write (char *file_data);

/**
 * print command line options
 *
 * @param argc	number of arguments
 * @param argv	table of arguments
 */
void print_options(int argc, char *argv[]);

#endif // IO_TOOLS_H

/** @} */
