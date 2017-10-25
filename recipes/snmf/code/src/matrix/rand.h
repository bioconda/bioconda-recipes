/**
 * @addtogroup rand
 * @ingroup matrix
 * @{
 * @file rand.h
 *
 * @brief set of probability functions
 */

#ifndef RAND_H
#define RAND_H

#define LFMM_PI (3.141592653589793)

/**
 * rand for sparse random projection
 *
 * @return	{-1, 0, 1} with proba {1/6, 2/3, 1/6}
 */
double rand_srp();

/** 
 * calculate the median of a table
 *
 * @param p 	the table 
 * @param n	the size of p
 *
 * @return the median value
 */
double median(double *p, int n);

/**
 * initialise random 
 * 
 * @param seed	if seed < 0, random seed, else seed
 */
void init_random(long long *seed);

/** 
 * sample 1/0 with probability freq
 *
 * @param freq	frequence
 *
 * @return sample
 */
int rand_binary(double freq);

/**
 * compute a uniform random double, (0,1]
 *
 * @return	the random double
 */
double drand();

/**
 * compute a uniform random float, (0,1]
 *
 * @return	the random float
 */
float frand();

/**
 * compute a uniform random integer in [0,size-1]
 *
 * @param size	the number of possible values
 *  
 * @return	the random integer
 */
int rand_int(int size);

/**
 * sample k int among [0,n-1] with replacement
 * (not optimal)
 *
 * @param col	vector of sampled values
 * @param k	number of integer to sample
 * @param n	size of the interval
 */
void rand_k_among_n(int* vect, int k, int n);

/**
 * compute a uniform random float, (min,max]
 *
 * @param min	left-bound of possible values
 * @param max	right-bound of possible values
 *  
 * @return	the random float
 */
float rand_float(float min, float max);

/**
 * compute a uniform random double, (min,max]
 *
 * @param min	left-bound of possible values
 * @param max	right-bound of possible values
 *  
 * @return	the random double
 */
double rand_double(double min, double max);

/**
 * compute a uniform ((0,1]) random float matrix of size MxN
 *
 * @param A	the matrix (of size MxN)
 * @param M	number of lines
 * @param N	number of columns
 *  
 * @return	the random float matrix
 */
void rand_matrix_float(float *A, int M, int N);

/**
 * compute a uniform ((0,1]) random double matrix of size MxN
 *
 * @param A	the matrix (of size MxN)
 * @param M	number of lines
 * @param N	number of columns
 *  
 * @return	the random double matrix
 */
void rand_matrix_double(double *A, int M, int N);

/**
 * compute a random double from a normal distribution of mean, mean and variance, var
 *
 * @param mean	mean parameter of the normal distribution
 * @param var	variance parameter of the normal distribution (>=0) 
 *  
 * @return	the random double
 */
double rand_normal(double mean, double var);

/**
 * compute a random double from a normal distribution of mean, 0 and variance, 1
 *
 * @return	the random double
 */
double rand_normal_r();

/**
 * compute a random double vector from a multivariate normal distribution 
 *
 * @param mu	mean vector parameter of the normal distribution (of size D)
 * @param L	upper cholesky decomposition of the covariance matrix parameter 
		of the normal distribution (of size DxD)
 * @param D	size of the vector
 * @param y	output vector
 *  
 */
void mvn_rand(double *mu, double *L, int D, double *y);

/**
 * compute a random float from an exponential distribution
 * 
 * @param alpha	exponential distribution parameter
 * @param r	output float 
 */
void rand_exp(float alpha, float *r);

/**
 * compute a random integer from an (upper bound) exponential distribution
 * 
 * @param mean	exponential distribution parameter
 *
 * @return	the random int 
 */
int rand_exp_int(float mean);

/**
 * compute a random integer in [0,size-1] with frequencies from Pi
 * 
 * @param Pi	vector (of size, size) of probability
 * @param size	size of vector Pi
 * 
 * @return	the random integer (-1, if error)
 */
int rand_vector(double *Pi, int size);

/**
 * compute a random double from a gamma distribution
 * (Warning: there are 2 possible parametes sets for a gamma distribution)
 * 
 * @param alpha	1st parameter of the gamma distribution	
 * @param beta	2nd parameter of the gamma distribution	
 * @param size	size of vector Pi
 * 
 * @return	the random double
 */
double rand_gamma(int alpha, double beta);

/**
 * compute the (approximated) pvalue associated a positive zscore (normal)
 * 
 * @param z	zscore 
 * 
 * @return	the associated pvalue
 */
long double zscore2pvalue(long double z);

/**
 * compute the (approximated) pvalue associated a positive zscore (student)
 * 
 * @param z	zscore 
 * @param df	degree of freedom
 * 
 * @return	the associated pvalue
 */
double zscore2pvalue_student(double z, int df);

#endif // RAND_H

/** @} */
