/**
 * @addtogroup error_ce
 * @ingroup crossEntropy
 * @{
 * @file error_ce.h
 *
 * @brief function to manage error types
 */


#ifndef ERROR_CE_H
#define ERROR_CE_H

#include "../matrix/error_matrix.h"

/**
 * print a specific lfmm error message
 *
 * @param msg   the string to recognize the error type
 * @param file  the name of a file (depends on the error)
 */
void print_error_ce(char* msg, char* file);

#endif // ERROR_CE_H

/** @} */
