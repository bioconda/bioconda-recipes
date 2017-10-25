/**
 * @addtogroup createDataSet
 * @ingroup createDataSet
 * @{
 * @file createDataSet.h
 *
 * @brief function to create a data set with masked genotypes.
 * A masked genotype is just a genotype replaced with a missing
 * value. The input and ouput formats are the geno format.
 */


#ifndef CREATEDATASET_H
#define CREATEDATASET_H

/**
 * create a data set with e percents of masked genotypes 
 *
 * In practice, it reads the input file, and replace each genotype
 * with a 9 with probability e.
 *
 * @param[in] input_file	input file name
 * @param[in] seed		seed for randomization
 * @param[in] e 		percentage of masked data in [0,1]
 * @param[in] output_file	output file name
 */
void createDataSet(char* input_file, long long seed, double e,
	char* output_file); 

#endif // CREATEDATASET_H

/** @} */
