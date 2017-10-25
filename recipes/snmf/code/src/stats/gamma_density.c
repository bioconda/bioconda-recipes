////////////////////////////////////////////////////////////////////////////////
// File: gamma_density.c                                                      //
// Routine(s):                                                                //
//    Gamma_Density                                                           //
////////////////////////////////////////////////////////////////////////////////
#include <math.h>                     // required for exp(), log(),  pow().

//                         Externally Defined Routines                        //

extern double Gamma_Function_Max_Arg( void );
extern double Gamma_Function(double nu);
extern double Ln_Gamma_Function(double nu);

////////////////////////////////////////////////////////////////////////////////
// double Gamma_Density(double x, double nu)                                  //
//                                                                            //
//  Description:                                                              //
//     The gamma density is defined to be 0 for x < 0 and                     //
//     x^(nu-1) exp(-nu) / Gamma(nu) for x > 0 where the parameter nu > 0.    //
//     The parameter nu is referred to as the shape parameter.                //
//                                                                            //
//  Arguments:                                                                //
//     double x   Argument of the gamma density with shape parameter nu.      //
//     double nu  The shape parameter of the gamma distribution.              //
//                                                                            //
//  Return Values:                                                            //
//                                                                            //
//  Example:                                                                  //
//     double x, g, nu;                                                       //
//                                                                            //
//     g = Gamma_Density( x, nu );                                            //
////////////////////////////////////////////////////////////////////////////////


double Gamma_Density(double x, double nu) {
   if (x <= 0.0) return 0.0;
   if (nu <= Gamma_Function_Max_Arg() ) 
      return pow(x,nu-1.0) * exp(-x) / Gamma_Function(nu);
   else return exp( (nu - 1.0) * log(x) - x - Ln_Gamma_Function(nu) );
}
