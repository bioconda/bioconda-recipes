////////////////////////////////////////////////////////////////////////////////
// File: student_t_distribution.c                                             //
// Routine(s):                                                                //
//    Student_t__Distribution                                                 //
////////////////////////////////////////////////////////////////////////////////

#include "student_t_distribution.h"

//                         Externally Defined Routines                        //
extern double Beta_Distribution(double x, double a, double b);

////////////////////////////////////////////////////////////////////////////////
// double Student_t_Distribution( double x, int n )                           //
//                                                                            //
//  Description:                                                              //
//     If X and X2 are independent random variables, X being N(0,1) and       //
//     X2 being Chi_Square with n degrees of freedom, then the random         //
//     variable T = X / sqrt(X2/n) has a Student-t distribution with n        //
//     degrees of freedom.                                                    //
//                                                                            //
//     The Student-t distribution is the Pr[T < x] which equals the integral  //
//     from -inf to x of the density                                          //
//            1/ [n^(1/2)* B(1/2,n/2)] * (1 + x^2/n)^(-(n+1)/2)               //
//     where n >= 1 and B(,) is the (complete) beta function.                 //
//                                                                            //
//     By making the change of variables: g = n / (n + x^2),                  //
//                   t(x,n) = 1 - B(n / (n + x^2), n/2, 1/2) / 2              //
//     where B(,,) is the incomplete beta function.                           //
//                                                                            //
//  Arguments:                                                                //
//     double x   The upper limit of the integral of the density given above. //
//     int    n   The number of degrees of freedom.                           //
//                                                                            //
//  Return Values:                                                            //
//     A real number between 0 and 1.                                         //
//                                                                            //
//  Example:                                                                  //
//     double p, x;                                                           //
//     int    n;                                                              //
//                                                                            //
//     p = Student_t_Distribution(x, n);                                      //
////////////////////////////////////////////////////////////////////////////////

double Student_t_Distribution(double x, int n)
{
   double a = (double) n / 2.0;
   double beta = Beta_Distribution( 1.0 / (1.0 + x * x / n), a, 0.5);

   if ( x > 0.0 ) return 1.0 - 0.5 * beta;
   else if ( x < 0.0) return 0.5 * beta;
   return 0.5;
}
