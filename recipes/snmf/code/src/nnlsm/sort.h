/**
 * @addtogroup sort
 * @ingroup nnlsm
 * @{
 * @file sort.h
 *
 * @brief functions to sort binary matrices
 */

#ifndef SORT_H
#define SORT_H

#include "blockpivot.h"
/**
 * @brief sort boolean matrix X by column order.
 *
 * @param sortIx	output column indices such as X is ordered (the ordered 
 *			matrix is X(i,sortIx)) (of size N).
 * @param breaks	output boolean vector such as if the columns are ordered 
 *			(ie for X(i,sortIx)), it equals 1 if the current column 
 *			is different from the previous column, and 0 otherwise. 
 *			Use as breaks(sortIx) (of size N).
 * @param X		input boolean matrix to order (of size KxN)
 * @param K		number of lines of X
 * @param N		number of columns of X
 * @param param		parameter structure
 */
void sortCols(int* breaks, int* sortIx, int* X, int K, int N, Nnlsm_param param);

/**
 * @brief 	recursive function to sort boolean matrix X by column order from 
 *	    	index startN to index endN-1, starting to order from line k.
 *
 * @param sortIx	input column indices such as X(0:k-1) is ordered.
 * 			output column indices such as X is ordered.
 * @param breaks	if the columns are ordered (ie for X(i,sortIx)), equals
 *		 	1 if the current column is different from the previous 
 *			column, and 0 otherwise. Use as breaks(sortIx)
 *			(of size N)
 * @param X		input boolean matrix to order (of size KxN)
 * @param K		number of lines of X
 * @param N		number of columns of X
 * @param startN	first column to order
 * @param endN		last column to order, endN>startN
 * @param k		first line to look at to order
 */
void sortColsRec(int* breaks, int* sortIx, int* X, int K, int N, int startN, 
			int endN,int k, int* tempSortIx);

#endif // SORT_H


/** @} */
