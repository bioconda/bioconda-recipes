/**
 * @addtogroup print_snmf
 * @ingroup sNMF
 * @{
 * @file print_snmf.h
 *
 * @brief set of printing functions for snmf program
 */


#ifndef PRINT_SNMF_H
#define PRINT_SNMF_H

#include "sNMF.h"

/**
 * print the complete licence
 */
void print_licence_snmf();

/**
 * print the header for the licence
 */
void print_head_licence_snmf();

/**
 * print my header
 */
void print_head_snmf();

/**
 * print help
 */
void print_help_snmf();

/**
 * print summary of the parameters
 *
 * @param param	parameter structure
 */
void print_summary_snmf (sNMF_param param);

#endif // PRINT_SNMF_H

/** @} */
