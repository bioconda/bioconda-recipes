/**
 * @addtogroup student_t_distribution
 * @ingroup stats
 * @{
 * @file student_t_distribution.h
 *                                                                            
 * @brief 
 *    Description:                                                              
 *    If X and X2 are independent random variables, X being N(0,1) and       
 *    X2 being Chi_Square with n degrees of freedom, then the random         
 *    variable T = X / sqrt(X2/n) has a Student-t distribution with n        
 *    degrees of freedom.                                                    
 *                                                                           
 *    The Student-t distribution is the Pr[T < x] which equals the integral  
 *    from -inf to x of the density                                          
 *           1/ [n^(1/2)* B(1/2,n/2)] * (1 + x^2/n)^(-(n+1)/2)               
 *    where n >= 1 and B(,) is the (complete) beta function.                 
 *                                                                           
 *    By making the change of variables: g = n / (n + x^2),                  
 *                  t(x,n) = 1 - B(n / (n + x^2), n/2, 1/2) / 2              
 *    where B(,,) is the incomplete beta function.                           
 *                                                                           
 */

#ifndef STUDENT_T_DISTRIBUTION
#define STUDENT_T_DISTRIBUTION

/**
 * Calculate the student t distribution 
 * 
 * @param x The upper limit of the integral of the density given above
 * @param n The number of degrees of freedom.
 */
double Student_t_Distribution(double x, int n);

#endif 

/** @} */
