////////////////////////////////////////////////////////////////////////////////
// File: gamma_function.c                                                     //
// Routine(s):                                                                //
//    Gamma_Function                                                          //
//    xGamma_Function                                                         //
//    Gamma_Function_Max_Arg                                                  //
//    xGamma_Function_Max_Arg                                                 //
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//  Description:                                                              //
//     The Gamma function of x for real x > 0 is defined as:                  //
//               Gamma(x) = Integral[0,inf] t^(x-1) exp(-t) dt                //
//     and analytically continued in the complex plane with simple poles at   //
//     the nonpositive integers, i.e. the Gamma function is a meromorphic     //
//     function with simple poles at the nonpositive integers.                //
//     For real x < 0, the Gamma function satisfies the reflection equation:  //
//                Gamma(x) = pi / ( sin(pi*x) * Gamma(1-x) ).                 //
//                                                                            //
//     The functions Gamma_Function() and xGamma_Function() return the Gamma  //
//     function evaluated at x for x real.                                    //
//                                                                            //
//     The function Gamma_Function_Max_Arg() returns the maximum argument of  //
//     the Gamma function for arguments > 1 and return values of type double. //
//                                                                            //
//     The function xGamma_Function_Max_Arg() returns the maximum argument of //
//     the Gamma function for arguments > 1 and return values of type long    //
//     double.                                                                //
////////////////////////////////////////////////////////////////////////////////
#include <math.h>      // required for powl(), sinl(), fabsl() and ldexpl().
#include <float.h>     // required for DBL_MAX and LDBL_MAX
#include <limits.h>    // required for LONG_MAX

//                         Internally Defined Routines                        //

double Gamma_Function(double x);
long double xGamma_Function(long double x);
double Gamma_Function_Max_Arg( void );
long double xGamma_Function_Max_Arg( void );

static long double xGamma(long double x);
static long double Duplication_Formula( long double two_x );

//                         Internally Defined Constants                       //

static long double const e =  2.71828182845904523536028747L;
static long double const pi = 3.14159265358979323846264338L;
static long double const g =  9.65657815377331589457187L;
static long double const exp_g_o_sqrt_2pi = +6.23316569877722552586386e+3L;
static double max_double_arg = 171.0;
static long double max_long_double_arg = 1755.5L;

static long double const a[] = {
                                 +1.14400529453851095667309e+4L,
                                 -3.23988020152318335053598e+4L,
                                 +3.50514523505571666566083e+4L,
                                 -1.81641309541260702610647e+4L,
                                 +4.63232990536666818409138e+3L,
                                 -5.36976777703356780555748e+2L,
                                 +2.28754473395181007645155e+1L,
                                 -2.17925748738865115560082e-1L,
                                 +1.08314836272589368860689e-4L
                              };

////////////////////////////////////////////////////////////////////////////////
// double Gamma_Function( double x )                                          //
//                                                                            //
//  Description:                                                              //
//     This function uses Lanczos' expression to calculate Gamma(x) for real  //
//     x, where -(max_double_arg - 1) < x < max_double_arg.                   //
//     Note the Gamma function is meromorphic in the complex plane and has    //
//     poles at the nonpositive integers.                                     //
//     Tests for x a positive integer or a half positive integer give a       //
//     maximum absolute relative error of about 1.9e-16.                      //
//                                                                            //
//     If x > max_double_arg, then one should either use xGamma_Function(x)   //
//     or calculate lnGamma(x).                                               //
//     Note that for x < 0, ln (Gamma(x)) may be a complex number.            //
//                                                                            //
//  Arguments:                                                                //
//     double x   Argument of the Gamma function.                             //
//                                                                            //
//  Return Values:                                                            //
//     If x is positive and is less than max_double_arg then Gamma(x) is      //
//     returned and if x > max_double_arg then DBL_MAX is returned.  If x is  //
//     a nonpositive integer i.e. x is a pole, then DBL_MAX is returned       //
//     ( note that Gamma(x) changes sign on each side of the pole).  If x is  //
//     nonpositive nonintegral, then if Gamma(x) > DBL_MAX, then DBL_MAX is   //
//     returned and if Gamma(x) < -DBL_MAX, then -DBL_MAX is returned.        //
//                                                                            //
//  Example:                                                                  //
//     double x, g;                                                           //
//                                                                            //
//     g = Gamma_Function( x );                                               //
////////////////////////////////////////////////////////////////////////////////
double Gamma_Function(double x)
{
   long double g;

   if ( x > max_double_arg ) return DBL_MAX;
   g = xGamma_Function( (long double) x);
   if (fabsl(g) < DBL_MAX) return (double) g;
   return (g < 0.0L) ? -DBL_MAX : DBL_MAX;

}


////////////////////////////////////////////////////////////////////////////////
// long double xGamma_Function( long double x )                               //
//                                                                            //
//  Description:                                                              //
//     This function uses Lanczos' expression to calculate Gamma(x) for real  //
//     x, where -(max_long_double_arg - 1) < x < max_long_double_arg.         //
//     Note the Gamma function is meromorphic in the complex plane and has    //
//     poles at the nonpositive integers.                                     //
//     Tests for x a positive integer or a half positive integer give a       //
//     maximum absolute relative error of about 3.5e-16.                      //
//                                                                            //
//     If x > max_long_double_arg, then one should use lnGamma(x).            //
//     Note that for x < 0, ln (Gamma(x)) may be a complex number.            //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Argument of the Gamma function.                        //
//                                                                            //
//  Return Values:                                                            //
//     If x is positive and is less than max_long_double_arg, then Gamma(x)   //
//     is returned and if x > max_long_double_arg, then LDBL_MAX is returned. //
//     If x is a nonpositive integer i.e. x is a pole, then LDBL_MAX is       //
//     returned ( note that Gamma(x) changes sign on each side of the pole).  //
//     If x is nonpositive nonintegral, then if x > -(max_long_double_arg + 1)//
//     then Gamma(x) is returned otherwise 0.0 is returned.                   //
//                                                                            //
//  Example:                                                                  //
//     long double x, g;                                                      //
//                                                                            //
//     g = xGamma_Function( x );                                              //
////////////////////////////////////////////////////////////////////////////////
long double xGamma_Function(long double x)
{
   long double sin_x;
   long double rg;
   long int ix;

             // For a positive argument (x > 0)                 //
             //    if x <= max_long_double_arg return Gamma(x)  //
             //    otherwise      return LDBL_MAX.              //

   if ( x > 0.0L ) {
      if (x <= max_long_double_arg) return xGamma(x);
      else return LDBL_MAX;
   }

                   // For a nonpositive argument (x <= 0) //
                   //    if x is a pole return LDBL_MAX   //

   if ( x > -(long double)LONG_MAX) {
      ix = (long int) x;
      if ( x == (long double) ix) return LDBL_MAX;
   }
   sin_x = sinl(pi * x);
   if ( sin_x == 0.0L ) return LDBL_MAX;

          // if x is not a pole and x < -(max_long_double_arg - 1) //
          //                                     then return 0.0L  //

   if ( x < -(max_long_double_arg - 1.0L) ) return 0.0L;

            // if x is not a pole and x >= -(max_long_double - 1) //
            //                               then return Gamma(x) //

   rg = xGamma(1.0L - x) * sin_x / pi;
   if ( rg != 0.0L ) return (1.0L / rg);
   return LDBL_MAX;
}


////////////////////////////////////////////////////////////////////////////////
// static long double xGamma( long double x )                                 //
//                                                                            //
//  Description:                                                              //
//     This function uses Lanczos' expression to calculate Gamma(x) for real  //
//     x, where 0 < x <= 900. For 900 < x < 1755.5, the duplication formula   //
//     is used.                                                               //
//     The major source of relative error is in the use of the c library      //
//     function powl().  The results have a relative error of about 10^-16.   //
//     except near x = 0.                                                     //
//                                                                            //
//     If x > 1755.5, then one should calculate lnGamma(x).                   //
//                                                                            //
//  Arguments:                                                                //
//     long double x   Argument of the Gamma function.                        //
//                                                                            //
//  Return Values:                                                            //
//     If x is positive and is less than 1755.5 then Gamma(x) is returned and //
//     if x > 1755.5 then LDBL_MAX is returned.                               //
//                                                                            //
//  Example:                                                                  //
//     long double x;                                                         //
//     long double g;                                                         //
//                                                                            //
//     g = xGamma_Function( x );                                              //
////////////////////////////////////////////////////////////////////////////////
static long double xGamma(long double x)
{

   long double xx = (x < 1.0L) ? x + 1.0L : x;
   long double temp;
   int const n = sizeof(a) / sizeof(long double);
   int i;

   if (x > 1755.5L) return LDBL_MAX;

   if (x > 900.0L) return Duplication_Formula(x);

   temp = 0.0L;
   for (i = n-1; i >= 0; i--) {
      temp += ( a[i] / (xx + (long double) i) );
   }
   temp += 1.0L;
   temp *= ( powl((g + xx - 0.5L) / e, xx - 0.5L) / exp_g_o_sqrt_2pi );
   return (x < 1.0L) ?  temp / x : temp;
}


////////////////////////////////////////////////////////////////////////////////
// static long double Duplication_Formula(long double two_x)                  //
//                                                                            //
//  Description:                                                              //
//     This function returns the Gamma(two_x) using the duplication formula   //
//     Gamma(2x) = (2^(2x-1) / sqrt(pi)) Gamma(x) Gamma(x+1/2).               //
//                                                                            //
//  Arguments:                                                                //
//     none                                                                   //
//                                                                            //
//  Return Values:                                                            //
//     Gamma(two_x)                                                           //
//                                                                            //
//  Example:                                                                  //
//     long double two_x, g;                                                  //
//                                                                            //
//     g = Duplication_Formula(two_x);                                        //
////////////////////////////////////////////////////////////////////////////////
static long double Duplication_Formula( long double two_x )
{
   long double x = 0.5L * two_x;
   long double g;
   // double two_n = 1.0;
   int n = (int) two_x - 1;

   g = powl(2.0L, two_x - 1.0L - (long double) n);
   g = ldexpl(g,n);
   g /= sqrt(pi);
   g *= xGamma_Function(x);
   g *= xGamma_Function(x + 0.5L);

   return g;
}


////////////////////////////////////////////////////////////////////////////////
// double Gamma_Function_Max_Arg( void )                                      //
//                                                                            //
//  Description:                                                              //
//     This function returns the maximum argument of Gamma_Function for which //
//     a number < DBL_MAX is returned, for arguments greater than 1.          //
//                                                                            //
//  Arguments:                                                                //
//     none                                                                   //
//                                                                            //
//  Return Values:                                                            //
//     max_double_arg (171.0).                                                //
//                                                                            //
//  Example:                                                                  //
//     double x;                                                              //
//                                                                            //
//     x = Gamma_Function_Max_Arg();                                          //
////////////////////////////////////////////////////////////////////////////////
double Gamma_Function_Max_Arg( void ) { return max_double_arg; }


////////////////////////////////////////////////////////////////////////////////
// long double xGamma_Function_Max_Arg( void )                                //
//                                                                            //
//  Description:                                                              //
//     This function returns the maximum argument of Gamma_Function for which //
//     a number < LDBL_MAX is returned, for arguments greater than 1.         //
//                                                                            //
//  Arguments:                                                                //
//     none                                                                   //
//                                                                            //
//  Return Values:                                                            //
//     max_long_double_arg (1755.5).                                          //
//                                                                            //
//  Example:                                                                  //
//     long double x;                                                         //
//                                                                            //
//     x = xGamma_Function_Max_Arg();                                         //
////////////////////////////////////////////////////////////////////////////////
long double xGamma_Function_Max_Arg( void ) { return max_long_double_arg; }
