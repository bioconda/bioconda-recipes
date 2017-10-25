/**
 * @addtogroup criteria
 * @ingroup sNMF
 * @{
 * @file criteria.h
 *
 * @brief set of functions to compute least square criterion for sNMF
 */


#ifndef CRITERIA_H
#define CRITERIA_H

#include "../bituint/bituint.h"
#include "sNMF.h"

/** 
 * calculate least square criteria with regularization
 *
 * @param alpha	sNMF parameter structure
 */
double least_square(sNMF_param param);

#endif // CRITERIA_H

/** @} */
