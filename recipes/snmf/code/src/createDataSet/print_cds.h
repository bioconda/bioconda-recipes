/**
 * @addtogroup print_cds
 * @ingroup createDataSet
 * @{
 * @file print_cds.h
 *
 * @brief functions to print help and a summary of the parameters
 */


#ifndef PRINT_CDS_H
#define PRINT_CDS_H

/**
 * print help
 */
void print_help_cds();

/**
 * print summary of the parameters
 *
 * @param[in] N     the number of individuals
 * @param[in] M     the number of loci
 * @param[in] seed	seed value
 * @param[in] e     percentage of missing data
 * @param[in] input         genotype file
 */
void print_summary_cds (int N, int M, long long seed,
                        double e, char *input, char *output);

#endif // PRINT_CDS_H

/** @} */
