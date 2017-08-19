/**
 * @addtogroup register_ce
 * @ingroup crossEntropy
 * @{
 * @file register_ce.h
 *
 * @brief function to analyze the command-line parameters
 */

#ifndef REGISTER_CE_H
#define REGISTER_CE_H

/**
 * analyse command line set of parameters and set the parameters
 * 
 * @param argc  	the number of arguments
 * @param argv  	the set of arguments
 * @param m     	the number of alleles
 * @param K     	the number of clusters
 * @param input		the input file
 * @param input_file_Q	the input file for Q
 * @param input_file_F	the input file for F
 * @param input_file_I	the input file for the genotype file with masked genotypes
 */
void analyse_param_ce(	int argc, char *argv[], int *m,
			int* K, char *input, char* input_file_Q,
			char* input_file_F, char *input_file_I); 

#endif // REGISTER_CE_H

/** @} */
