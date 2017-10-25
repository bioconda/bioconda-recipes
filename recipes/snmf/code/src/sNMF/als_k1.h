/**
 * @addtogroup als_k1
 * @ingroup sNMF
 * @{
 * @file als_k1.h
 *
 * @brief set of functions to compute SNMF for k=1
 */


#ifndef ALS_K1_H
#define ALS_K1_H

#include "../bituint/bituint.h"
#include "sNMF.h"

/** 
 * @brief compute NMF for K=1
 *
 * @param param parameter structure
 */
void ALS_k1(sNMF_param param);

#endif // ALS_K1_H

/** @} */
