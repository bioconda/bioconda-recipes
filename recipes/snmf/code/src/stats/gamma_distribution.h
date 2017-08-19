/**
 * @addtogroup gamma_distribution
 * @ingroup stats
 * @{
 * @file gamma_distribution.h
 * @brief Description:                                                              
 *    The gamma distribution is defined to be the integral of the gamma      
 *    density which is 0 for x < 0 and x^(nu-1) exp(-nu) for x > 0 where the 
 *    parameter nu > 0. The parameter nu is referred to as the shape         
 *    parameter.                                                             
 */

#ifndef GAMMA_DISTRIBUTION
#define GAMMA_DISTRIBUTION

/**
 * compute gamma distribution
 * 
 * @param x   	Upper limit of the integral of the density given above
 * @param nu 	The shape parameter of the gamma distribution
 */
double Gamma_Distribution(double x, double nu);

double quantile_Gamma_Distribution(double p, double nu);

#endif 

/** @} */
