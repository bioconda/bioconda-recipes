//-----------------------------------------------------------------------------
// MurmurHash3 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.

#ifndef _MURMURHASH3_H_
#define _MURMURHASH3_H_

//-----------------------------------------------------------------------------
// Platform-specific functions and macros

// Microsoft Visual Studio

#if defined(_MSC_VER) && (_MSC_VER < 1600)

typedef unsigned char uint8_t;
typedef unsigned int uint32_t;
typedef unsigned __int64 uint64_t;

// Other compilers

#else    // defined(_MSC_VER)

#include <stdint.h>

#endif // !defined(_MSC_VER)

//-----------------------------------------------------------------------------

void MurmurHash3_x86_32  ( const void * key, int len, uint32_t seed, void * out );

void MurmurHash3_x86_128 ( const void * key, int len, uint32_t seed, void * out );

void MurmurHash3_x64_128 ( const void * key, int len, uint32_t seed, void * out );

//#if defined(__ICC) || defined(__INTEL_COMPILER)
#include <immintrin.h>
#if defined __AVX512F__ && __AVX512CD__ 
void MurmurHash3_x64_128_avx512_8x16 ( __m512i  * vkey1, __m512i * vkey2, int pend_len, int len, uint32_t seed, void * out );

void MurmurHash3_x64_128_avx512_8x32 ( __m512i  * vkey1, __m512i * vkey2, __m512i * vkey3, __m512i * vkey4, int pend_len, int len, uint32_t seed, void * out );

void MurmurHash3_x64_128_avx512_8x8 ( __m512i * vkey, int pend_len, int len, uint32_t seed, void * out );
#else
	#ifdef __AVX2__
	// implement by avx2
void MurmurHash3_x64_128_avx2_8x4 (__m256i * vkey, int pend_len, int len, uint32_t seed, void *out);

	#else
		#ifdef __SSE4_1__
		// implement by sse
		#else
		//implement without optimization
		#endif
	#endif
#endif

//#endif

//-----------------------------------------------------------------------------

#endif // _MURMURHASH3_H_
