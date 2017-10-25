/**
 * @addtogroup slice_bituint
 * @ingroup bituint
 * @{
 * @file slice_bituint.h
 *
 * @brief multithreaded part of the functions to compute 
 *	  matrix calculation with a bituint matrix 
 */

#ifndef SLICE_BITUINT_H
#define SLICE_BITUINT_H

/**
 * compute a slice of the lines of A = transpose(B) * transpose(X) 
 *
 * @param G     a specific structure for multi-threading
 */
void slice_tBtX(void *G);

/**
 * compute a slice of the lines of t(A) = B * X 
 *
 * @param G     a specific structure for multi-threading
 */
void slice_BX(void *G);

#endif // SLICE_BITUINT_H

/** @} */
