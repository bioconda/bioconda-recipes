/**
 * @addtogroup error_cds
 * @ingroup createDataSet
 * @{
 * @file error_cds.h
 *
 * @brief function to manage error types for createDataSet
 */


#ifndef ERROR_CDS_H
#define ERROR_CDS_H

#include "../matrix/error_matrix.h"

/**
 * print a specific createDataSet error message
 *
 * @param[in] msg   the string to recognize the error type
 * @param[in] file  the name of a file (depends on the error)
 */
void print_error_cds(char* msg, char* file);

#endif // ERROR_CDS_H

/** @} */
