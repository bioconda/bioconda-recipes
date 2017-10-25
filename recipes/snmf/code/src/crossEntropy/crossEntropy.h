/**
 * @addtogroup crossEntropy
 * @ingroup crossEntropy
 * @{
 * @file crossEntropy.h
 *
 * @brief function to calculate the crossEntropy criterion.
 * 
 * The cross-entropy criterion is a predictive criterion.
 *
 * Previously, a percentage of masked genotype has been removed from the 
 * initial dataset with the program createDataSet.
 * Then the parameters (Q, G) of the sNMF model have been estimated with 
 * the input file with masked data using the program sNMF.
 * 
 * The cross-entropy criterion compares the value of the masked genotypes
 * and the estimated value QG^T. A detailed explanation is available in
 * the corresponding paper:
 * 
 * E. Frichot, F. Mathieu, T. Trouillon, G. Bouchard, O. François. Fast and efficient estimation of individual ancestry coefficients. Genetics (2014) 196 (4): 973-983. 
 * 
 * \warning The ancestral genotype matrix can be called F or G (with no reason).
 *
 * The cross-entropy criterion is calculated on masked data (missing_ce) and
 * on not masked data (all_ce). all_ce should always be lower than missing_ce.
 */


#ifndef CROSSENTROPY_H
#define CROSSENTROPY_H

/**
 * compute cross Entropy criterion
 *  
 * @param input_file	input file name
 * @param input_file_I	file with masked genotypes used to calculate Q and F
 * @param input_file_Q	file with Q matrix
 * @param input_file_F	file with F matrix
 * @param K		number of ancestral populations
 * @param m		ploidy
 * @param all_ce	output not masked data cross-entropy
 * @param missing_ce	output masked data cross-entropy
 */
void crossEntropy(char* input_file, char* input_file_I, char* input_file_Q, char* input_file_F,
        int K, int m, double *all_ce, double *missing_ce);

#endif // CROSSENTROPY_H

/** @} */
