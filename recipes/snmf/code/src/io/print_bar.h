/**
 * @addtogroup print_bar
 * @ingroup io
 * @{
 * @file print_bar.h
 *
 * @brief functions to display a command line advancement bar
 */

#ifndef PRINT_BAR_H
#define PRINT_BAR_H

/**
 * initialize progress bar
 *
 * @param i	progress integer	
 * @param j	progress integer
 */
void init_bar(int *i, int *j);

/**
 * print progress bar
 *
 * @param i	progress integer	
 * @param j	progress integer
 * @param Niter	total number of iterations of the algorithm 
 */
void print_bar(int *i, int *j, int Niter);

/* 
 * finalize print
 */
void final_bar();

#endif // PRINT_BAR_H

/** @} */
