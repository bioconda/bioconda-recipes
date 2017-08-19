/**
 * @addtogroup als
 * @ingroup sNMF
 * @{
 * @file als.h
 *
 * @brief set of functions to compute SNMF with als algorithm
 */


#ifndef ALS_H
#define ALS_H

#include "../bituint/bituint.h"
#include "../nnlsm/blockpivot.h"
#include "sNMF.h"

/** 
 * @brief Algorithm Alternative Least Square
 *
 * @param param	parameter structure
 */
void ALS(sNMF_param param); 

#endif // ALS_H

/** @} */
