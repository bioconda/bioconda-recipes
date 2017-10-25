/**
 * @addtogroup geno2lfmm
 * @ingroup convert
 * @{
 * @file geno2lfmm.h
 *
 * @brief function to convert a file from geno to lfmm format.
 */

#ifndef GENO2LFMM_H
#define GENO2LFMM_H

#include <stdint.h>
#include "register_convert.h"

/**
 * convert a file from geno to lfmm format and count the number of lines (M)
 * and the number of columns (N) (in geno format)
 *
 * @param[in] 	input_file   	input file name
 * @param[in] 	output_file   	output file name
 * @param[out]	N     		the number of columns (in geno format)
 * @param[out] 	M     		the number of lines (in geno format)
 */
void geno2lfmm (char *input_file, char* output_file, int *N, int *M);

#endif // GENO2LFMM_H
/** @}*/
