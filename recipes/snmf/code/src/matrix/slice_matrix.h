/**
 * @addtogroup slice_matrix
 * @ingroup matrix
 * @{
 * @file slice_matrix.h
 *
 * @brief multithreaded part of the functions to compute 
 *	  matrix calculation.
 *	  (possibly multithreaded) 
 */

#ifndef SLICE_MATRIX_H
#define SLICE_MATRIX_H

/**
 * compute a slice of the lines of A = transpose(B) * B
 *
 * @param G     a specific structure for multi-threading
 */
void slice_tBB(void *G);

#endif // SLICE_MATRIX_H

/** @} */
