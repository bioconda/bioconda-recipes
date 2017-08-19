/**
 * @addtogroup register_convert
 * @ingroup convert
 * @{
 * @file register_convert.h
 *
 * @brief functions to the analyse command line and print informations
 */

#ifndef REGISTER_LFMM_H
#define REGISTER_LFMM_H

/**
 * analyse command line set of parameters and set the parameters
 * 
 * @param argc	the number of arguments
 * @param argv	the set of arguments
 * @param input	the input file
 * @param output	the output file
 * @param type	type format of the output file
 */
void analyse_param_convert (int argc, char *argv[], char *input, char *output, char* type);

/**
 * output print of the number of individuals and the number of loci
 *
 * @param N	number of individuals
 * @param M	number of loci
 */
void print_convert(int N, int M);

#endif // REGISTER_CONVERT_H

/** @} */
