////////////////////////////////////////////////////////////////////////////////
// File: gamma_distribution.c                                                 //
// Routine(s):                                                                //
//    Gamma_Distribution                                                      //
////////////////////////////////////////////////////////////////////////////////

//                         Externally Defined Routines                        //
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "gamma_distribution.h"

extern double Entire_Incomplete_Gamma_Function(double x, double nu);


////////////////////////////////////////////////////////////////////////////////
// double Gamma_Distribution(double x, double nu)                             //
//                                                                            //
//  Description:                                                              //
//     The gamma distribution is defined to be the integral of the gamma      //
//     density which is 0 for x < 0 and x^(nu-1) exp(-nu) for x > 0 where the //
//     parameter nu > 0. The parameter nu is referred to as the shape         //
//     parameter.                                                             //
//                                                                            //
//  Arguments:                                                                //
//     double x   Upper limit of the integral of the density given above.     //
//     double nu  The shape parameter of the gamma distribution.              //
//                                                                            //
//  Return Values:                                                            //
//                                                                            //
//  Example:                                                                  //
//     double x, g, nu;                                                       //
//                                                                            //
//     g = Gamma_Distribution( x, nu );                                       //
////////////////////////////////////////////////////////////////////////////////


double Gamma_Distribution(double x, double nu) {
   return  ( x <= 0.0 ) ? 0.0 : Entire_Incomplete_Gamma_Function(x,nu);
}

double quantile_Gamma_Distribution(double p, double nu)
{
	double x, size, res;

	x = 10;
	size = 10;
	res = Gamma_Distribution(x, nu);
	// looking for the quantile value by dichotomie 
	while (fabs(res-p)/fabs(p) > 1e-10) {
		size /= 2;
		// look up
		if (res < p) { 
			x += size;
			res = Gamma_Distribution(x, nu);
		// look down
		} else {
			x -= size;
			res = Gamma_Distribution(x, nu);
		}
	}	

	return x * 2.0; // but I do not know why.
}
