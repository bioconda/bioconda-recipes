/**
 * @addtogroup register_snmf
 * @ingroup sNMF
 * @{
 * @file register_snmf.h
 *
 * @brief functions to read command line
 */

#include "sNMF.h" 

#ifndef REGISTER_SNMF_H
#define REGISTER_SNMF_H

/**
 * initialize the parameter with the default values for sNMF 
 *
 * @param param parameter structure
 */
void init_param_snmf(sNMF_param param);

/**
 * analyse command line set of parameters and set the parameters
 * 
 * @param argc  the number of arguments
 * @param argv  the set of arguments
 * @param param parameter structure
 */
void analyse_param_snmf(int argc, char *argv[], sNMF_param param); 

/** 
 * free snmf_param struct allocated memory
 *
 * @param param parameter structure
 */
void free_param_snmf(sNMF_param param);


#endif // REGISTER_SNMF_H

/** @} */
