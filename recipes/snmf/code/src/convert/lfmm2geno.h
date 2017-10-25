/**
 * @addtogroup lfmm2geno
 * @ingroup convert
 * @{
 * @file lfmm2geno.h
 *
 * @brief functions to convert a file from lfmm to geno format.
 */

#ifndef LFMM2GENO_H
#define LFMM2GENO_H

#include <stdint.h>

/**
 * convert a file from lfmm to geno format 
 *
 * @param input_file	input file in the lfmm format
 * @param output_file	output file in the geno format
 * @param N		number of lines of the input file
 * @param M		number of columns of the input file
 */
void lfmm2geno (char *input_file, char* output_file, int *N, int *M);

#endif // LFMM2GENO_H

/** @} */
