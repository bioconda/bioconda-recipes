/**
 * @addtogroup error_snmf
 * @ingroup sNMF
 * @{
 * @file error_snmf.h
 *
 * @brief function to manage error types in sNMF
 */


#ifndef ERROR_NMF_H
#define ERROR_NMF_H

#include "../matrix/error_matrix.h"

/**
 * print a specific lfmm error message
 *
 * @param msg   the string to recognize the error type
 * @param file  the name of a file (depends on the error)
 * @param n     an integer parameter (depends of the error)
 */
void print_error_nmf(char* msg, char* file, int n);

#endif // ERROR_NMF_H

/** @} */
