////////////////////////////////////////////////////////////////////////////////
// File: entire_incomplete_gamma_function.c                                   //
// Routine(s):                                                                //
//    Entire_Incomplete_Gamma_Function                                        //
//    xEntire_Incomplete_Gamma_Function                                       //
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//  Description:                                                              //
//     The entire incomplete gamma function, also called the regularized      //
//     incomplete gamma function, is defined as the integral from 0 to x of   //
//     the integrand t^(nu-1) exp(-t) / gamma(nu) dt.  The parameter nu is    //
//     sometimes referred to as the shape parameter.                          //
////////////////////////////////////////////////////////////////////////////////
#include <math.h>           // required for fabsl(), powl(), expl() and logl().
#include <float.h>          // required for DBL_EPSILON

//                         Externally Defined Routines                        //

extern long double xGamma_Function( long double x );
extern double Gamma_Function_Max_Arg( void );
extern long double xLn_Gamma_Function( long double x );
extern long double xFactorial( int n );

//                         Internally Defined Routines                        //

double Entire_Incomplete_Gamma_Function(double x, double nu); 
long double xEntire_Incomplete_Gamma_Function(long double x, long double nu);
 
static long double xSmall_x(long double x, long double nu);
static long double xMedium_x(long double x, long double nu);
static long double xLarge_x(long double x, long double nu);

////////////////////////////////////////////////////////////////////////////////
// double Entire_Incomplete_Gamma_Function(double x, double nu)               //
//                                                                            //
//  Description:                                                              //
//     The entire incomplete gamma function, also called the regularized      //
//     incomplete gamma function, is defined as the integral from 0 to x of   //
//     the integrand t^(nu-1) exp(-t) / gamma(nu) dt.  The parameter nu is    //
//     sometimes referred to as the shape parameter.                          //
//                                                                            //
//  Arguments:                                                                //
//     double x   Upper limit of the integral with integrand given above.     //
//     double nu  The shape parameter of the entire incomplete gamma function.//
//                                                                            //
//  Return Values:                                                            //
//                                                                            //
//  Example:                                                                  //
//     double x, g, nu;                                                       //
//                                                                            //
//     g = Entire_Incomplete_Gamma_Function( x, nu );                         //
////////////////////////////////////////////////////////////////////////////////
double Entire_Incomplete_Gamma_Function(double x, double nu)
{
   return (double) xEntire_Incomplete_Gamma_Function((long double)x,
                                                              (long double)nu);
}


////////////////////////////////////////////////////////////////////////////////
// long double xEntire_Incomplete_Gamma_Function(long double x,               //
//                                                            long double nu) //
//                                                                            //
//  Description:                                                              //
//     The entire incomplete gamma function, also called the regularized      //
//     incomplete gamma function, is defined as the integral from 0 to x of   //
//     the integrand t^(nu-1) exp(-t) / gamma(nu) dt.  The parameter nu is    //
//     sometimes referred to as the shape parameter.                          //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Upper limit of the integral with integrand given above.//
//     long double nu  The shape parameter of the entire incomplete gamma     //
//                     function.                                              //
//                                                                            //
//  Return Values:                                                            //
//                                                                            //
//  Example:                                                                  //
//     long double x, g, nu;                                                  //
//                                                                            //
//     g = xEntire_Incomplete_Gamma_Function( x, nu );                        //
////////////////////////////////////////////////////////////////////////////////
long double xEntire_Incomplete_Gamma_Function(long double x, long double nu)
{
   
   if (x == 0.0L) return 0.0L;
   if (fabsl(x) <= 1.0L) return xSmall_x(x, nu);
   if (fabsl(x) < (nu + 1.0L) ) return xMedium_x(x, nu);
   return xLarge_x(x, nu);
}


////////////////////////////////////////////////////////////////////////////////
// static long double xSmall_x(long double x, long double nu)                 //
//                                                                            //
//  Description:                                                              //
//     This function approximates the entire incomplete gamma function for    //
//     x, where -1 <= x <= 1.                                                 //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Upper limit of the integral with integrand described   //
//                     in the section under Entire_Incomplete_Gamma_Function. //
//     long double nu  The shape parameter of the entire incomplete gamma     //
//                     function.                                              //
//                                                                            //
//  Return Values:                                                            //
//     The entire incomplete gamma function:                                  //
//                  I(0,x) t^(nu-1) Exp(-t) dt / Gamma(nu).                   //
//                                                                            //
//  Example:                                                                  //
//     long double x, g, nu;                                                  //
//                                                                            //
//     g = xSmall_x( x, nu);                                                  //
////////////////////////////////////////////////////////////////////////////////
#define Nterms 20
static long double xSmall_x(long double x, long double nu)
{
   long double terms[Nterms];
   long double x_term = -x;
   long double x_power = 1.0L;
   long double sum;
   int i;

   for (i = 0; i < Nterms; i++) {
      terms[i] = (x_power / xFactorial(i)) / (i + nu);
      x_power *= x_term;
   }
   sum = terms[Nterms-1];
   for (i = Nterms-2; i >= 0; i--) sum += terms[i];
   if ( nu <= Gamma_Function_Max_Arg() )
      return powl(x,nu) * sum / xGamma_Function(nu);
   else return expl(nu * logl(x) + logl(sum) - xLn_Gamma_Function(nu));
}


////////////////////////////////////////////////////////////////////////////////
// static long double xMedium_x(long double x, long double nu)                //
//                                                                            //
//  Description:                                                              //
//     This function approximates the entire incomplete gamma function for    //
//     x, where 1 < x < nu + 1.                                               //
//                                                                            //
//     If nu + 1 < x, then one should use xLarge_x(x,nu).                     //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Upper limit of the integral with integrand described   //
//                     in the section under Entire_Incomplete_Gamma_Function. //
//     long double nu  The shape parameter of the entire incomplete gamma     //
//                     function.                                              //
//                                                                            //
//  Return Values:                                                            //
//     The entire incomplete gamma function:                                  //
//                  I(0,x) t^(nu-1) exp(-t) dt / gamma(nu).                   //
//                                                                            //
//  Example:                                                                  //
//     long double x, g, nu;                                                  //
//                                                                            //
//     g = xMedium_x( x, nu);                                                 //
////////////////////////////////////////////////////////////////////////////////
static long double xMedium_x(long double x, long double nu)
{
   long double coef;
   long double term = 1.0L / nu;
   long double corrected_term = term;
   long double temp_sum = term;
   long double correction = -temp_sum + corrected_term;
   long double sum1 = temp_sum;
   long double sum2;
   long double epsilon = 0.0L;
   int i;

   if (nu > Gamma_Function_Max_Arg()) {
      coef = expl( nu * logl(x) - x - xLn_Gamma_Function(nu) );
      if (coef > 0.0L) epsilon = DBL_EPSILON/coef;
   } else {
      coef = powl(x, nu) * expl(-x) / xGamma_Function(nu);
      epsilon = DBL_EPSILON/coef;
   }
   if (epsilon <= 0.0L) epsilon = (long double) DBL_EPSILON;

   for (i = 1; term > epsilon * sum1; i++) {
      term *= x / (nu + i);
      corrected_term = term + correction;
      temp_sum = sum1 + corrected_term;
      correction = (sum1 - temp_sum) + corrected_term;
      sum1 = temp_sum;
   }
   sum2 = sum1;
   sum1 *= coef;
   correction += sum2 - sum1 / coef;
   term *= x / (nu + i);
   sum2 = term + correction;
   for (i++; (term + correction) > epsilon * sum2; i++) {
      term *= x / (nu + i);
      corrected_term = term + correction;
      temp_sum = sum2 + corrected_term;
      correction = (sum2 - temp_sum) + corrected_term;
      sum2 = temp_sum;
   }
   
   sum2 += correction;
   sum2 *= coef;
   return sum1 + sum2;
}


////////////////////////////////////////////////////////////////////////////////
// static long double xLarge_x(long double x, long double nu)                 //
//                                                                            //
//  Description:                                                              //
//     This function approximates the entire incomplete gamma function for    //
//     x, where nu + 1 <= x.                                                  //
//                                                                            //
//     If 0 <= x < nu + 1, then one should use xSmall_x(x,nu).                //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Upper limit of the integral with integrand described   //
//                     in the section under Entire_Incomplete_Gamma_Function. //
//     long double nu  The shape parameter of the entire incomplete gamma     //
//                     function.                                              //
//                                                                            //
//  Return Values:                                                            //
//     If x is positive and is less than 171 then Gamma(x) is returned and    //
//     if x > 171 then DBL_MAX is returned.                                   //
//                                                                            //
//  Example:                                                                  //
//     long double x, g, nu;                                                  //
//                                                                            //
//     g = xLarge_x( x, nu);                                                  //
////////////////////////////////////////////////////////////////////////////////
static long double xLarge_x(long double x, long double nu)
{
   long double temp = 1.0L / nu;
   long double sum = temp;
   long double coef;
   int i = 0;
   int n;

   n = (int)(x - nu - 1.0L) + 1;
   for (i = 1; i < n; i++) {
      temp *= x / (nu + i);
      sum += temp;
   }
   if ( nu <= Gamma_Function_Max_Arg() ) {
      coef = powl(x, nu) * expl(-x) / xGamma_Function(nu);
      return xMedium_x(x, nu + n) + coef * sum;
   } else {
      return expl(logl(sum) + nu * logl(x) - x - xLn_Gamma_Function(nu)) +
                                                        xMedium_x(x, nu + n); 
   }   
}

