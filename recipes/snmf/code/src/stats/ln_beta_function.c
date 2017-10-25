////////////////////////////////////////////////////////////////////////////////
// File: ln_beta_function.c                                                   //
// Routine(s):                                                                //
//    Ln_Beta_Function                                                        //
//    xLn_Beta_Function                                                       //
////////////////////////////////////////////////////////////////////////////////
//  Description:                                                              //
//     The beta function is the integral from 0 to 1 of the integrand         //
//     x^(a-1) (1-x)^(b-1), where the parameters a > 0 and b > 0.             //
//     In terms of the gamma function the beta function is:                   //
//               Beta(a,b) = Gamma(a) * Gamma(b) / Gamma(a+b).                //
//                                                                            //
//     These functions return                                                 //
//       ln(Beta(a,b) = ln(Gamma(a)) + ln(Gamma(b)) - ln(Gamma(a + b)).       //
////////////////////////////////////////////////////////////////////////////////
#include <math.h>                        // required for logl()

//                         Internally Defined Routines                        //

double Ln_Beta_Function(double a, double b);
long double xLn_Beta_Function(long double a, long double b);

//                         Externally Defined Routines                        //

extern double Gamma_Function_Max_Arg(void);
extern long double xGamma_Function(long double x);
extern long double xLn_Gamma_Function(long double x);

////////////////////////////////////////////////////////////////////////////////
// double Ln_Beta_Function( double a, double b)                               //
//                                                                            //
//  Description:                                                              //
//     This function returns ln(Beta(a,b)) where a > 0 and b > 0.             //
//                                                                            //
//  Arguments:                                                                //
//     double a   Argument of the Beta function, a must be positive.          //
//     double b   Argument of the Beta function, b must be positive.          //
//                                                                            //
//  Return Values:                                                            //
//     log( beta(a,b) )                                                       //
//                                                                            //
//  Example:                                                                  //
//     double a, b, beta;                                                     //
//                                                                            //
//     beta = Ln_Beta_Function( a, b );                                       //
////////////////////////////////////////////////////////////////////////////////
double Ln_Beta_Function(double a, double b)
{
   return (double) xLn_Beta_Function( (long double) a, (long double) b );
}


////////////////////////////////////////////////////////////////////////////////
// long double xLn_Beta_Function( long double a, long double b)               //
//                                                                            //
//  Description:                                                              //
//     This function returns ln(Beta(a,b)) where a > 0 and b > 0.             //
//                                                                            //
//  Arguments:                                                                //
//     long double a   Argument of the Beta function, a must be positive.     //
//     long double b   Argument of the Beta function, b must be positive.     //
//                                                                            //
//  Return Values:                                                            //
//     log( beta(a,b) )                                                       //
//                                                                            //
//  Example:                                                                  //
//     long double a, b;                                                      //
//     long double beta;                                                      //
//                                                                            //
//     beta = xLn_Beta_Function( a, b );                                      //
////////////////////////////////////////////////////////////////////////////////

long double xLn_Beta_Function(long double a, long double b)
{

     // If (a + b) <= Gamma_Function_Max_Arg() then simply return //
     //  log(gamma(a)*gamma(b) / gamma(a+b)).                     //

   if ( (a + b) <= (long double) Gamma_Function_Max_Arg() ) {
      if ( a == 1.0L && b == 1.0L ) return 0.0L;
      else return logl( xGamma_Function(a) /
                             ( xGamma_Function(a + b) / xGamma_Function(b) ));
   }

     // If (a + b) > Gamma_Function_Max_Arg() then simply return //
     //  lngamma(a) + lngamma(b) - lngamma(a+b).                 //

   return xLn_Gamma_Function(a) + xLn_Gamma_Function(b)
                                                  - xLn_Gamma_Function(a+b);
}
