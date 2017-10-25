////////////////////////////////////////////////////////////////////////////////
// File: gamma_dist_tables.c                                                  //
// Routine(s):                                                                //
//    Gamma_Distribution_Tables                                               //
////////////////////////////////////////////////////////////////////////////////

#include <math.h>                     // required for exp(), log(),  pow().

//                         Externally Defined Routines                        //

extern double Entire_Incomplete_Gamma_Function(double x, double nu);
extern double Gamma_Function_Max_Arg( void );
extern double Gamma_Function(double nu);
extern double Ln_Gamma_Function(double nu);
                                    
////////////////////////////////////////////////////////////////////////////////
// void Gamma_Distribution_Tables( double a, double start, double delta,      //
//               int nsteps, double *density, double* distribution_function)  //
//                                                                            //
//  Description:                                                              //
//     The gamma distribution is the integral from -inf to x of the density   //
//                                        0                   if x < 0,       //
//                         f(x) =  x^(a-1) e^(-x) / Gamma(a)  if x >= 0       //
//     i.e.                                                                   //
//                         Pr[X < x] = F(x) = 0                    if x < 0.  //
//             Pr[X < x] = F(x) = Incomplete_Gamma(x,a)/Gamma(a)   if x > 0.  //
//     The parameter, a > 0, is called the shape parameter.                   //
//     This routine returns the probability density in the array density[]    //
//     where                                                                  //
//            density[i] = f(start + i * delta), i = 0,...,nsteps             //
//     and the distribution function in the array distribution_function[]     //
//     where                                                                  //
//     distribution_function[i] = F(start + i * delta), i = 0,...,nsteps.     //
//     Note the size of the arrays density[] and distribution_function[] must //
//     equal or exceed nsteps + 1.                                            //
//                                                                            //
//  Arguments:                                                                //
//     double a                                                               //
//        The shape parameter, a > 0.                                         //
//     double start                                                           //
//        The initial point to start evaluating f(x) and F(x).                //
//     double delta                                                           //
//        The step size between adjacent evaluation points of f(x) and F(x).  //
//     int    nsteps                                                          //
//        The number of steps.                                                //
//     double density[]                                                       //
//        The value of f(start + i * delta), i = 0,...,nsteps.                //
//     double distribution_function[]                                         //
//        The value of F(start + i * delta), i = 0,...,nsteps.                //
//                                                                            //
//  Return Values:                                                            //
//     void                                                                   //
//                                                                            //
//  Example:                                                                  //
//     #define N                                                              //
//     double start, delta;                                                   //
//     double density[N+1];                                                   //
//     double distribution_function[N+1];                                     //
//                                                                            //
//     Gamma_Distribution_Tables(a, start, delta, N, density,                 //
//                                                   distribution_function);  //
////////////////////////////////////////////////////////////////////////////////

void Gamma_Distribution_Tables(double a,  double start, double delta,
                  int nsteps, double *density, double* distribution_function)
{
   double x = start;
   int i;

   for (i = 0; i <= nsteps; i++) {
      if (x <= 0.0) {
         density[i] = 0.0;
         distribution_function[i] = 0.0;
      }
      else {
         if (a <= Gamma_Function_Max_Arg() ) 
            density[i] = pow(x,a-1.0) * exp(-x) / Gamma_Function(a);
         else density[i] = exp( (a - 1.0) * log(x) - x - Ln_Gamma_Function(a) );
         distribution_function[i] = Entire_Incomplete_Gamma_Function(x,a);
      }
      x += delta;
   }
}
