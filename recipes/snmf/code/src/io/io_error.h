/**
 * @addtogroup io_error
 * @ingroup io
 * @{
 * @file io_error.h
 *
 * @brief manage error while reading files
 */

#ifndef IO_ERROR_H
#define IO_ERROR_H

/** 
 * check if the number of columns is ok
 *
 * @param file 		file name	
 * @param m_file	opened file		
 * @param i 		current column	
 * @param j		current line
 * @param N		number of columns
 * @param token		current token
 */
void test_column(char *file, FILE *m_File, int i, int j, int N, char *token);

/** 
 * check if the number of lines is ok
 *
 * @param file 		file name	
 * @param m_file	opened file		
 * @param i 		current line	
 * @param M		number of lines
 */
void test_line(char *file, FILE *m_File, int i, int N);

#endif // IO_ERROR_H

/** @} */
