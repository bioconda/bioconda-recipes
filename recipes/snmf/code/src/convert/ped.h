/**
 * @addtogroup ped
 * @ingroup convert
 * @{
 * @file ped.h
 *
 * @brief functions to read/write files in the ped format.
 */

#ifndef PED_H
#define PED_H

#include <stdint.h>
#include <stdio.h>

/**
 * read token (column) and test if token is not null and print error if null
 *
 * @param input_file	input file
 * @param i		line/individual
 * @param j		column/SNP
 *
 * @return token
 */
char* next_token(char* input_file, int i, int j);

/**
 * test if a token is correct (ie equal 0,1,2,3,4, A, C, T, G)
 *
 * @param token1	character to test
 * @param j		number of the SNP
 * @param i		number of the individual
 * @param input_file	file name
 */
void test_token_ped(char token, int j, int i, char* input_file);

/**
 * read a file of N individuals and M SNPs in ped format and fill data (of size NxM)
 *
 * It raises an error if the number lines is different from N.
 * 
 * @param input_file	input file in ped format 
 * @param N		number of individuals 
 * @param M		number of SNPs
 * @param data		output data set (of size NxM)
 *
 */
void read_ped (char* input_file, int N, int M, int* data);

/**
 * read a line (stored in szbuff) in the ped format and fill data
 *
 * It raises an error if the columns are not 0,1,2,3,4, A, C, T, G.
 * It raises an error if the number of columns is incorrect.
 *
 * @param data		data matrix (of size NxM)
 * @param szbuff	registered line
 * @param M		number of SNPs
 * @param i		number of the individual
 * @param input_file	input file
 * @param File		opened file
 * @param ref		reference allele
 */
void fill_line_ped (int *data, char* szbuff, int M, int i, char* input_file, FILE *File,
        char *ref);


/**
 * read a file of N individuals and M SNPs in ped format and write it in the geno format.
 *
 * @param input_file	input file in the ped format 
 * @param output_file	output file in the geno format 
 * @param N		output number of individuals 
 * @param M		output number of SNPs
 */
void ped2geno (char *input_file, char* output_file, int *N, int *M);

/**
 * read a file of N individuals and M SNPs in ped format and write it in the lfmm format.
 *
 * @param input_file	input file in the ped format 
 * @param output_file	output file in the lfmm format 
 * @param N		output number of individuals 
 * @param M		output number of SNPs
 */
void ped2lfmm (char *input_file, char* output_file, int *N, int *M);

#endif // PED_H

/** @} */
