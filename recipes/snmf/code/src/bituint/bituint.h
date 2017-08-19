/**
 * @addtogroup bituint
 * @ingroup bituint
 * @{
 * @file bituint.h
 *
 * @brief set of functions to manage data store and operations in bituint format.
 *
 * The bituint format has been designed to store matrices containing only 0/1 information
 * (ie binary matrices). The goal is to store each line of a binary matrix by setting
 * the bits of bituint elements.
 * 
 * In practice, 
 * - N is the number of lines of a binary matrix
 * - Mc is the number of binary elements stored in a line
 * - Mp is the number of bituint elements per line 
 * - SIZUINT is a constant containing the number of binary
 *   elements that can be stored in a bituint element.
 */

#ifndef BITUINT_H
#define BITUINT_H

#include <stdint.h>
#include "../io/read.h"

/**
 * @brief mask (not used) 
 */
#if defined(__i386__)
// IA-32
	typedef uint_fast32_t bituint;
	#define SIZEUINT 32

	static const bituint mask[SIZEUINT] = 
	{
		0x1,
		0x2,
		0x4,
		0x8,
		0x10,
		0x20,
		0x40,
		0x80,
		0x100,
		0x200,
		0x400,
		0x800,
		0x1000,
		0x2000,
		0x4000,
		0x8000,
		0x10000,
		0x20000,
		0x40000,
		0x80000,
		0x100000,
		0x200000,
		0x400000,
		0x800000,
		0x1000000,
		0x2000000,
		0x4000000,
		0x8000000,
		0x10000000,
		0x20000000,
		0x40000000,
		0x80000000
	};
#elif defined(__x86_64__)
// AMD64
	typedef uint_fast64_t bituint;
	#define SIZEUINT 64

	static const bituint mask[SIZEUINT] = 
	{
		0x1,
		0x2,
		0x4,
		0x8,
		0x10,
		0x20,
		0x40,
		0x80,
		0x100,
		0x200,
		0x400,
		0x800,
		0x1000,
		0x2000,
		0x4000,
		0x8000,
		0x10000,
		0x20000,
		0x40000,
		0x80000,
		0x100000,
		0x200000,
		0x400000,
		0x800000,
		0x1000000,
		0x2000000,
		0x4000000,
		0x8000000,
		0x10000000,
		0x20000000,
		0x40000000,
		0x80000000,
		0x100000000,
		0x200000000,
		0x400000000,
		0x800000000,
		0x1000000000,
		0x2000000000,
		0x4000000000,
		0x8000000000,
		0x10000000000,
		0x20000000000,
		0x40000000000,
		0x80000000000,
		0x100000000000,
		0x200000000000,
		0x400000000000,
		0x800000000000,
		0x1000000000000,
		0x2000000000000,
		0x4000000000000,
		0x8000000000000,
		0x10000000000000,
		0x20000000000000,
		0x40000000000000,
		0x80000000000000,
		0x100000000000000,
		0x200000000000000,
		0x400000000000000,
		0x800000000000000,
		0x1000000000000000,
		0x2000000000000000,
		0x4000000000000000,
		0x8000000000000000
	};
#else
	#error Unsupported architecture
#endif

/**
 * allocate the memory to store data of size nxMc
 * 
 * @param[in, out] dat  bituint data matrix.
 * @param[in]  N	number of lines of the matrix.
 * @param[in] Mc	number of elements to store per lines.
 * @param[out] Mp	(output) number of columns of the matrix.
 */
void init_mat_bituint(bituint** dat, int N, int Mc, int *Mp);

#endif // BITUINT_H

/** @} */
