/**
 * @addtogroup ancestrymap
 * @ingroup convert
 * @{
 * @file ancestrymap.h
 *
 * @brief functions to read files in the ancestrymap format 
 * and convert to the lfmm and geno formats.
 *
 * It is assumed that the lines of a file in the ancestrymap format
 * are ordered such that line number (i * N + j) contains the (i+1)th
 * locus for (j+1)th individual, where N is the number of individuals,
 * M the number of loci, j in [0,M-1] and i in [0,N-1].
 */

#ifndef ANCESTRYMAP_H
#define ANCESTRYMAP_H

#include <stdint.h>

/**
 * @brief count the number of individuals in an ancestrymap file.
 * 
 * In practice, it is the number of individuals for the 
 * first loci. It counts the number of lines from the beginning
 * of the file until the name of the first column (the name
 * of the loci) is different from the name of the first column
 * of the first line.
 *
 * @param input_file	input file in the ancestrymap format 
 *
 * @return the number of individuals
 */
int nb_ind_ancestrymap(char *input_file);

/**
 * read a file of N individuals and M SNPs in ancestrymap format.
 * 
 * It raises an error if in practice the number of individual per
 * locus is different for the number of individuals of the first
 * locus.
 *
 * @param input_file	input file in the ancestrymap format 
 * @param N		number of individuals 
 * @param M		number of SNPs
 * @param data		output data set (of size NxM)
 *
 */
void read_ancestrymap (char* input_file, int N, int M, int* data);

/**
 * read a line from an ancestrymap file (with elements separated by spaces,tabs)
 *
 * It raises an error if the line does not contain 3 elements.
 * It raises a warning if the third column (genotype) is not 0,1,2 or 9.
 *
 * @param szbuff	line to read (previously obtain with fgets)
 * @param allele	variable to read allele
 * @param name		name of the SNP
 * @param i		number of the individual
 * @param j		number of the SNP
 * @param input		input file
 * @param warning       Boolean: true if a warning has already been diplayed.
 *                               false otherwise
 */
void read_line_ancestrymap(char *szbuff, int *allele, char *name, int i, int j, 
	char *input, int *warning);

/**
 * read a file of N individuals and M SNPs in the ancestrymap format
 *
 * @param input_file	input file in the ancestrymap format 
 * @param output_file	output file in the geno format 
 * @param N		output number of individuals 
 * @param M		output number of SNPs
 */
void ancestrymap2geno (char *input_file, char* output_file, int *N, int *M);

/**
 * read a file of N individuals and M SNPs in the ancestrymap format
 *
 * @param input_file	input file in the ancestrymap format 
 * @param output_file	output file in the lfmm format 
 * @param N		output number of individuals 
 * @param M		output number of SNPs
 */
void ancestrymap2lfmm (char *input_file, char* output_file, int *N, int *M);


#endif // ANCESTRYMAP_H

/** @}*/
