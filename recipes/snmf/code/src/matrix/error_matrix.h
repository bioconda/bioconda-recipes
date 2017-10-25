/**
 * @addtogroup error_matrix
 * @ingroup matrix
 * @{
 * @file error_matrix.h
 *
 * @brief function to manage error types
 */

#ifndef ERROR_MATRIX_H
#define ERROR_MATRIX_H

/**
 * print a specific (global) error message
 *
 * @param msg	the string to recognize the error type
 * @param file	the name of a file (depends on the error)
 * @param n	an integer parameter (depends of the error)
 */
void print_error_global(char *msg, char *file, int n);

#endif // ERROR_MATRIX_H

/** @} */
