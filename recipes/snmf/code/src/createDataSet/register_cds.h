/**
 * @addtogroup register_cds
 * @ingroup createDataSet
 * @{
 * @file register_cds.h
 *
 * @brief functions to analyse command line parameters 
 */

#ifndef REGISTER_CDS_H
#define REGISTER_CDS_H

/**
 * analyse command line set of parameters and set the parameters
 * 
 * @param[in] argc  the number of arguments
 * @param[in] argv  the set of arguments
 * @param[out] s     seed
 * @param[out] e	percentage of genotypes to remove
 * @param[out] input	the input file
 * @param[out] output_file	the output file
 */
void analyse_param_cds(	int argc, char *argv[], long long *s,
			double *e, char *input, char* output_file);

#endif // REGISTER_CDS_H

/** @} */
