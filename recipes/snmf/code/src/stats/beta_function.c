////////////////////////////////////////////////////////////////////////////////
// File: beta_function.c                                                      //
// Routine(s):                                                                //
//    Beta_Function                                                           //
//    xBeta_Function                                                          //
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//  Description:                                                              //
//     The beta function is the integral from 0 to 1 of the integrand         //
//     x^(a-1) (1-x)^(b-1), where the parameters a > 0 and b > 0.             //
//     In terms of the gamma function the beta function is:                   //
//               beta(a,b) = gamma(a) * gamma(b) / gamma(a+b).                //
////////////////////////////////////////////////////////////////////////////////
#include <math.h>                   // required for logl() and expl()
#include <float.h>                  // required for DBL_MAX and LDBL_MAX.

//                         Externally Defined Routines                        //

extern long double xGamma_Function(long double x);
extern double Gamma_Function_Max_Arg(void);
extern long double xLn_Gamma_Function(long double x);

//                         Internally Defined Routines                        //

double Beta_Function(double a, double b);
long double xBeta_Function(long double a, long double b);

//                         Internally Defined Constants                       //

static const long double ln_LDBL_MAX =  1.13565234062941435e+4L;

////////////////////////////////////////////////////////////////////////////////
// double Beta_Function( double a, double b)                                  //
//                                                                            //
//  Description:                                                              //
//     This function returns beta(a,b) = gamma(a) * gamma(b) / gamma(a+b),    //
//     where a > 0, b > 0.                                                    //
//                                                                            //
//  Arguments:                                                                //
//     double a   Argument of the Beta function, a must be positive.          //
//     double b   Argument of the Beta function, b must be positive.          //
//                                                                            //
//  Return Values:                                                            //
//     If beta(a,b) exceeds DBL_MAX then DBL_MAX is returned otherwise        //
//     beta(a,b) is returned.                                                 //
//                                                                            //
//  Example:                                                                  //
//     double a, b, beta;                                                     //
//                                                                            //
//     beta = Beta_Function( a, b );                                          //
////////////////////////////////////////////////////////////////////////////////
double Beta_Function(double a, double b)
{
   long double beta = xBeta_Function( (long double) a, (long double) b);
   return (beta < DBL_MAX) ? (double) beta : DBL_MAX;
}


////////////////////////////////////////////////////////////////////////////////
// long double xBeta_Function( long double a, long double b)                  //
//                                                                            //
//  Description:                                                              //
//     This function returns beta(a,b) = gamma(a) * gamma(b) / gamma(a+b),    //
//     where a > 0, b > 0.                                                    //
//                                                                            //
//  Arguments:                                                                //
//     long double a   Argument of the Beta function, a must be positive.     //
//     long double b   Argument of the Beta function, b must be positive.     //
//                                                                            //
//  Return Values:                                                            //
//     If beta(a,b) exceeds LDBL_MAX then LDBL_MAX is returned otherwise      //
//     beta(a,b) is returned.                                                 //
//                                                                            //
//  Example:                                                                  //
//     long double a, b;                                                      //
//     long double beta;                                                      //
//                                                                            //
//     beta = xBeta_Function( a, b );                                         //
////////////////////////////////////////////////////////////////////////////////
long double xBeta_Function(long double a, long double b)
{
   long double lnbeta;

     // If (a + b) <= Gamma_Function_Max_Arg() then simply return //
     //  gamma(a)*gamma(b) / gamma(a+b).                          //

   if ( (a + b) <= Gamma_Function_Max_Arg() )
      return xGamma_Function(a) / (xGamma_Function(a + b) / xGamma_Function(b));

     // If (a + b) > Gamma_Function_Max_Arg() then simply return //
     //  exp(lngamma(a) + lngamma(b) - lngamma(a+b) ).           //

   lnbeta = xLn_Gamma_Function(a) + xLn_Gamma_Function(b)
                                                 - xLn_Gamma_Function(a + b);
   return (lnbeta > ln_LDBL_MAX) ? (long double) LDBL_MAX : expl(lnbeta);
}
