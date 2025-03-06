//-----------------------------------------------------------------------------
// MurmurHash3 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.

// Note - The x86 and x64 versions do _not_ produce the same results, as the
// algorithms are optimized for their respective platforms. You can still
// compile and run any of them on any platform, but your performance with the
// non-native version will be less than optimal.

#include "MurmurHash3.h"

//#if defined (__ICC) || defined (__INTEL_COMPILER)
#include <immintrin.h>
//#endif

//-----------------------------------------------------------------------------
// Platform-specific functions and macros

// Microsoft Visual Studio

#if defined(_MSC_VER)

#define FORCE_INLINE    __forceinline

#include <stdlib.h>

#define ROTL32(x,y)    _rotl(x,y)
#define ROTL64(x,y)    _rotl64(x,y)

#define BIG_CONSTANT(x) (x)

// Other compilers

#else    // defined(_MSC_VER)

#define    FORCE_INLINE inline __attribute__((always_inline))

inline uint32_t rotl32 ( uint32_t x, int8_t r )
{
  return (x << r) | (x >> (32 - r));
}

inline uint64_t rotl64 ( uint64_t x, int8_t r )
{
  return (x << r) | (x >> (64 - r));
}

#define    ROTL32(x,y)    rotl32(x,y)
#define ROTL64(x,y)    rotl64(x,y)

#define BIG_CONSTANT(x) (x##LLU)

#endif // !defined(_MSC_VER)

//-----------------------------------------------------------------------------
// Block read - if your platform needs to do endian-swapping or can only
// handle aligned reads, do the conversion here

FORCE_INLINE uint32_t getblock32 ( const uint32_t * p, int i )
{
  return p[i];
}

FORCE_INLINE uint64_t getblock64 ( const uint64_t * p, int i )
{
  return p[i];
}

//-----------------------------------------------------------------------------
// Finalization mix - force all bits of a hash block to avalanche

FORCE_INLINE uint32_t fmix32 ( uint32_t h )
{
  h ^= h >> 16;
  h *= 0x85ebca6b;
  h ^= h >> 13;
  h *= 0xc2b2ae35;
  h ^= h >> 16;

  return h;
}

//----------

FORCE_INLINE uint64_t fmix64 ( uint64_t k )
{
  k ^= k >> 33;
  k *= BIG_CONSTANT(0xff51afd7ed558ccd);
  k ^= k >> 33;
  k *= BIG_CONSTANT(0xc4ceb9fe1a85ec53);
  k ^= k >> 33;

  return k;
}

//-----------------------------------------------------------------------------

void MurmurHash3_x86_32 ( const void * key, int len,
                          uint32_t seed, void * out )
{
  const uint8_t * data = (const uint8_t*)key;
  const int nblocks = len / 4;

  uint32_t h1 = seed;

  const uint32_t c1 = 0xcc9e2d51;
  const uint32_t c2 = 0x1b873593;

  //----------
  // body

  const uint32_t * blocks = (const uint32_t *)(data + nblocks*4);

  for(int i = -nblocks; i; i++)
  {
    uint32_t k1 = getblock32(blocks,i);

    k1 *= c1;
    k1 = ROTL32(k1,15);
    k1 *= c2;
    
    h1 ^= k1;
    h1 = ROTL32(h1,13); 
    h1 = h1*5+0xe6546b64;
  }

  //----------
  // tail

  const uint8_t * tail = (const uint8_t*)(data + nblocks*4);

  uint32_t k1 = 0;

  switch(len & 3)
  {
  case 3: k1 ^= tail[2] << 16;
  case 2: k1 ^= tail[1] << 8;
  case 1: k1 ^= tail[0];
          k1 *= c1; k1 = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
  };

  //----------
  // finalization

  h1 ^= len;

  h1 = fmix32(h1);

  *(uint32_t*)out = h1;
} 

//-----------------------------------------------------------------------------

void MurmurHash3_x86_128 ( const void * key, const int len,
                           uint32_t seed, void * out )
{
  const uint8_t * data = (const uint8_t*)key;
  const int nblocks = len / 16;

  uint32_t h1 = seed;
  uint32_t h2 = seed;
  uint32_t h3 = seed;
  uint32_t h4 = seed;

  const uint32_t c1 = 0x239b961b; 
  const uint32_t c2 = 0xab0e9789;
  const uint32_t c3 = 0x38b34ae5; 
  const uint32_t c4 = 0xa1e38b93;

  //----------
  // body

  const uint32_t * blocks = (const uint32_t *)(data + nblocks*16);

  for(int i = -nblocks; i; i++)
  {
    uint32_t k1 = getblock32(blocks,i*4+0);
    uint32_t k2 = getblock32(blocks,i*4+1);
    uint32_t k3 = getblock32(blocks,i*4+2);
    uint32_t k4 = getblock32(blocks,i*4+3);

    k1 *= c1; k1  = ROTL32(k1,15); k1 *= c2; h1 ^= k1;

    h1 = ROTL32(h1,19); h1 += h2; h1 = h1*5+0x561ccd1b;

    k2 *= c2; k2  = ROTL32(k2,16); k2 *= c3; h2 ^= k2;

    h2 = ROTL32(h2,17); h2 += h3; h2 = h2*5+0x0bcaa747;

    k3 *= c3; k3  = ROTL32(k3,17); k3 *= c4; h3 ^= k3;

    h3 = ROTL32(h3,15); h3 += h4; h3 = h3*5+0x96cd1c35;

    k4 *= c4; k4  = ROTL32(k4,18); k4 *= c1; h4 ^= k4;

    h4 = ROTL32(h4,13); h4 += h1; h4 = h4*5+0x32ac3b17;
  }

  //----------
  // tail

  const uint8_t * tail = (const uint8_t*)(data + nblocks*16);

  uint32_t k1 = 0;
  uint32_t k2 = 0;
  uint32_t k3 = 0;
  uint32_t k4 = 0;

  switch(len & 15)
  {
  case 15: k4 ^= tail[14] << 16;
  case 14: k4 ^= tail[13] << 8;
  case 13: k4 ^= tail[12] << 0;
           k4 *= c4; k4  = ROTL32(k4,18); k4 *= c1; h4 ^= k4;

  case 12: k3 ^= tail[11] << 24;
  case 11: k3 ^= tail[10] << 16;
  case 10: k3 ^= tail[ 9] << 8;
  case  9: k3 ^= tail[ 8] << 0;
           k3 *= c3; k3  = ROTL32(k3,17); k3 *= c4; h3 ^= k3;

  case  8: k2 ^= tail[ 7] << 24;
  case  7: k2 ^= tail[ 6] << 16;
  case  6: k2 ^= tail[ 5] << 8;
  case  5: k2 ^= tail[ 4] << 0;
           k2 *= c2; k2  = ROTL32(k2,16); k2 *= c3; h2 ^= k2;

  case  4: k1 ^= tail[ 3] << 24;
  case  3: k1 ^= tail[ 2] << 16;
  case  2: k1 ^= tail[ 1] << 8;
  case  1: k1 ^= tail[ 0] << 0;
           k1 *= c1; k1  = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
  };

  //----------
  // finalization

  h1 ^= len; h2 ^= len; h3 ^= len; h4 ^= len;

  h1 += h2; h1 += h3; h1 += h4;
  h2 += h1; h3 += h1; h4 += h1;

  h1 = fmix32(h1);
  h2 = fmix32(h2);
  h3 = fmix32(h3);
  h4 = fmix32(h4);

  h1 += h2; h1 += h3; h1 += h4;
  h2 += h1; h3 += h1; h4 += h1;

  ((uint32_t*)out)[0] = h1;
  ((uint32_t*)out)[1] = h2;
  ((uint32_t*)out)[2] = h3;
  ((uint32_t*)out)[3] = h4;
}

//-----------------------------------------------------------------------------

void MurmurHash3_x64_128 ( const void * key, const int len,
                           const uint32_t seed, void * out )
{
  const uint8_t * data = (const uint8_t*)key;
  const int nblocks = len / 16;

  uint64_t h1 = seed;
  uint64_t h2 = seed;

  const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);

  //----------
  // body

  const uint64_t * blocks = (const uint64_t *)(data);

  for(int i = 0; i < nblocks; i++)
  {
    uint64_t k1 = getblock64(blocks,i*2+0);
    uint64_t k2 = getblock64(blocks,i*2+1);

    k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;

    h1 = ROTL64(h1,27); h1 += h2; h1 = h1*5+0x52dce729;

    k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;

    h2 = ROTL64(h2,31); h2 += h1; h2 = h2*5+0x38495ab5;
  }

  //----------
  // tail

  const uint8_t * tail = (const uint8_t*)(data + nblocks*16);

  uint64_t k1 = 0;
  uint64_t k2 = 0;

  switch(len & 15)
  {
  case 15: k2 ^= ((uint64_t)tail[14]) << 48;
  case 14: k2 ^= ((uint64_t)tail[13]) << 40;
  case 13: k2 ^= ((uint64_t)tail[12]) << 32;
  case 12: k2 ^= ((uint64_t)tail[11]) << 24;
  case 11: k2 ^= ((uint64_t)tail[10]) << 16;
  case 10: k2 ^= ((uint64_t)tail[ 9]) << 8;
  case  9: k2 ^= ((uint64_t)tail[ 8]) << 0;
           k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;

  case  8: k1 ^= ((uint64_t)tail[ 7]) << 56;
  case  7: k1 ^= ((uint64_t)tail[ 6]) << 48;
  case  6: k1 ^= ((uint64_t)tail[ 5]) << 40;
  case  5: k1 ^= ((uint64_t)tail[ 4]) << 32;
  case  4: k1 ^= ((uint64_t)tail[ 3]) << 24;
  case  3: k1 ^= ((uint64_t)tail[ 2]) << 16;
  case  2: k1 ^= ((uint64_t)tail[ 1]) << 8;
  case  1: k1 ^= ((uint64_t)tail[ 0]) << 0;
           k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;
  };

  //----------
  // finalization

  h1 ^= len; h2 ^= len;

  h1 += h2;
  h2 += h1;

  h1 = fmix64(h1);
  h2 = fmix64(h2);

  h1 += h2;
  h2 += h1;

  ((uint64_t*)out)[0] = h1;
  ((uint64_t*)out)[1] = h2;
}

//#if defined (__ICC) || defined (__INTEL_COMPILER)
#if defined __AVX512F__ && defined __AVX512CD__
void MurmurHash3_x64_128_avx512_8x16 ( __m512i  * vkey1, __m512i * vkey2, int pend_len, int len, uint32_t seed, void * out )
{
	const int nblocks = len / 16; //real blocks
	__m512i v5 = _mm512_set1_epi64(5);
	__m512i vlen = _mm512_set1_epi64(len);
	uint64_t h1[8];
	uint64_t h2[8];

	__m512i vh1_1;	
	__m512i vh2_1;	
	__m512i vh1_2;	
	__m512i vh2_2;	

	__m512i vk1_1;
	__m512i vk2_1;
	__m512i vk1_2;
	__m512i vk2_2;

	vh1_1 = _mm512_set1_epi64(seed);
	vh2_1 = _mm512_set1_epi64(seed);
	vh1_2 = _mm512_set1_epi64(seed);
	vh2_2 = _mm512_set1_epi64(seed);

  	const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  	const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);
	__m512i vc1 = _mm512_set1_epi64(c1);
	__m512i vc2 = _mm512_set1_epi64(c2);

  	const uint64_t c3 = BIG_CONSTANT(0xff51afd7ed558ccd);
  	const uint64_t c4 = BIG_CONSTANT(0xc4ceb9fe1a85ec53);
	__m512i vc3 = _mm512_set1_epi64(c3);
	__m512i vc4 = _mm512_set1_epi64(c4);

	__m512i idx1 = _mm512_set_epi64(0xD,0x5,0xC,0x4,0x9,0x1,0x8,0x0);
	__m512i idx2 = _mm512_set_epi64(0xF,0x7,0xE,0x6,0xB,0x3,0xA,0x2);

  	//----------
	//body

  	for(int i = 0; i < nblocks; i++)
	{

		vk1_1 = vkey1[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk1_2 = vkey1[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);

		vk2_1 = vkey2[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk2_2 = vkey2[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);


		vk1_1 = _mm512_mullo_epi64(vk1_1, vc1);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc1);

		vk1_1 = _mm512_rol_epi64(vk1_1, 31);
		vk2_1 = _mm512_rol_epi64(vk2_1, 31);

		vk1_1 = _mm512_mullo_epi64(vk1_1, vc2);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc2);

		vh1_1 = _mm512_xor_epi64(vh1_1, vk1_1);
		vh2_1 = _mm512_xor_epi64(vh2_1, vk2_1);

	
		vh1_1 = _mm512_rol_epi64(vh1_1, 27);
		vh2_1 = _mm512_rol_epi64(vh2_1, 27);

		vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
		vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);

		vh1_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh1_1, v5), _mm512_set1_epi64( 0x52dce729));
		vh2_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh2_1, v5), _mm512_set1_epi64( 0x52dce729));


		vk1_2 = _mm512_mullo_epi64(vk1_2, vc2);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc2);

		vk1_2 = _mm512_rol_epi64(vk1_2, 33);
		vk2_2 = _mm512_rol_epi64(vk2_2, 33);

		vk1_2 = _mm512_mullo_epi64(vk1_2, vc1);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc1);

		vh1_2 = _mm512_xor_epi64(vh1_2, vk1_2);
		vh2_2 = _mm512_xor_epi64(vh2_2, vk2_2);


		vh1_2 = _mm512_rol_epi64(vh1_2, 31);
		vh2_2 = _mm512_rol_epi64(vh2_2, 31);
		
		vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
		vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);

		vh1_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh1_2, v5), _mm512_set1_epi64(0x38495ab5));
		vh2_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh2_2, v5), _mm512_set1_epi64(0x38495ab5));


	}


	//TODO:deal with tail after pending
	if(pend_len > len){

		vk1_1 = vkey1[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk1_2 = vkey1[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);

		vk2_1 = vkey2[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk2_2 = vkey2[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);


		vk1_2 = _mm512_mullo_epi64(vk1_2, vc2);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc2);

		vk1_2 = _mm512_rol_epi64(vk1_2, 33);
		vk2_2 = _mm512_rol_epi64(vk2_2, 33);

		vk1_2 = _mm512_mullo_epi64(vk1_2, vc1);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc1);

		vh1_2 = _mm512_xor_epi64(vh1_2, vk1_2);
		vh2_2 = _mm512_xor_epi64(vh2_2, vk2_2);


		vk1_1 = _mm512_mullo_epi64(vk1_1, vc1);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc1);

		vk1_1 = _mm512_rol_epi64(vk1_1, 31);
		vk2_1 = _mm512_rol_epi64(vk2_1, 31);

		vk1_1 = _mm512_mullo_epi64(vk1_1, vc2);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc2);

		vh1_1 = _mm512_xor_epi64(vh1_1, vk1_1);
		vh2_1 = _mm512_xor_epi64(vh2_1, vk2_1);

	}
	

	vh1_1 = _mm512_xor_epi64(vh1_1, vlen);
	vh2_1 = _mm512_xor_epi64(vh2_1, vlen);

	vh1_2 = _mm512_xor_epi64(vh1_2, vlen);
	vh2_2 = _mm512_xor_epi64(vh2_2, vlen);


	vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
	vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);

	vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
	vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);


	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));
	vh1_1 = _mm512_mullo_epi64(vh1_1, vc3);
	vh2_1 = _mm512_mullo_epi64(vh2_1, vc3);

	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));
	vh1_1 = _mm512_mullo_epi64(vh1_1, vc4);
	vh2_1 = _mm512_mullo_epi64(vh2_1, vc4);

	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));


	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));
	vh1_2 = _mm512_mullo_epi64(vh1_2, vc3);
	vh2_2 = _mm512_mullo_epi64(vh2_2, vc3);
	
	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));
	vh1_2 = _mm512_mullo_epi64(vh1_2, vc4);
	vh2_2 = _mm512_mullo_epi64(vh2_2, vc4);

	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));

	vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
	vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);
	vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
	vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);

	//reorganize output	
	vk1_1 = _mm512_permutex2var_epi64(vh1_1,idx1,vh1_2);
	vk2_1 = _mm512_permutex2var_epi64(vh2_1,idx1,vh2_2);
	vk1_2 = _mm512_permutex2var_epi64(vh1_1,idx2,vh1_2);
	vk2_2 = _mm512_permutex2var_epi64(vh2_1,idx2,vh2_2);

	vh1_1 = _mm512_shuffle_i64x2(vk1_1,vk1_2,0x44);
	vh1_2 = _mm512_shuffle_i64x2(vk1_1,vk1_2,0xEE);
	vh2_1 = _mm512_shuffle_i64x2(vk2_1,vk2_2,0x44);
	vh2_2 = _mm512_shuffle_i64x2(vk2_1,vk2_2,0xEE);

	_mm512_storeu_si512((uint64_t*)out, vh1_1);
	_mm512_storeu_si512(&((uint64_t*)out)[8], vh1_2);

	_mm512_storeu_si512(&((uint64_t*)out)[16], vh2_1);
	_mm512_storeu_si512(&((uint64_t*)out)[24], vh2_2);

	//_mm512_storeu_epi64(h1, vh1);
	//_mm512_storeu_epi64(h2, vh2);

	//for(int j = 0; j < 8; j++){
  	//	((uint64_t*)out)[0 + j * 2] = h1[j];
  	//	((uint64_t*)out)[1 + j * 2] = h2[j];
	//}

}


void MurmurHash3_x64_128_avx512_8x32 ( __m512i  * vkey1, __m512i * vkey2, __m512i * vkey3, __m512i * vkey4, int pend_len, int len, uint32_t seed, void * out )
{
	const int nblocks = len / 16; //real blocks
	__m512i v5 = _mm512_set1_epi64(5);
	__m512i vlen = _mm512_set1_epi64(len);
	//uint64_t h1[8];
	//uint64_t h2[8];

	__m512i vh1_1;	
	__m512i vh2_1;	
	__m512i vh3_1;	
	__m512i vh4_1;	
	__m512i vh1_2;	
	__m512i vh2_2;	
	__m512i vh3_2;	
	__m512i vh4_2;	

	__m512i vk1_1;
	__m512i vk2_1;
	__m512i vk3_1;
	__m512i vk4_1;
	__m512i vk1_2;
	__m512i vk2_2;
	__m512i vk3_2;
	__m512i vk4_2;

	vh1_1 = _mm512_set1_epi64(seed);
	vh2_1 = _mm512_set1_epi64(seed);
	vh3_1 = _mm512_set1_epi64(seed);
	vh4_1 = _mm512_set1_epi64(seed);
	vh1_2 = _mm512_set1_epi64(seed);
	vh2_2 = _mm512_set1_epi64(seed);
	vh3_2 = _mm512_set1_epi64(seed);
	vh4_2 = _mm512_set1_epi64(seed);

  	const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  	const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);
	__m512i vc1 = _mm512_set1_epi64(c1);
	__m512i vc2 = _mm512_set1_epi64(c2);

  	const uint64_t c3 = BIG_CONSTANT(0xff51afd7ed558ccd);
  	const uint64_t c4 = BIG_CONSTANT(0xc4ceb9fe1a85ec53);
	__m512i vc3 = _mm512_set1_epi64(c3);
	__m512i vc4 = _mm512_set1_epi64(c4);

	__m512i idx1 = _mm512_set_epi64(0xD,0x5,0xC,0x4,0x9,0x1,0x8,0x0);
	__m512i idx2 = _mm512_set_epi64(0xF,0x7,0xE,0x6,0xB,0x3,0xA,0x2);

  	//----------
	//body

  	for(int i = 0; i < nblocks; i++)
	{

		vk1_1 = vkey1[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk1_2 = vkey1[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);

		vk2_1 = vkey2[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk2_2 = vkey2[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);

		vk3_1 = vkey3[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk3_2 = vkey3[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);

		vk4_1 = vkey4[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk4_2 = vkey4[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);



		vk1_1 = _mm512_mullo_epi64(vk1_1, vc1);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc1);
		vk3_1 = _mm512_mullo_epi64(vk3_1, vc1);
		vk4_1 = _mm512_mullo_epi64(vk4_1, vc1);

		vk1_1 = _mm512_rol_epi64(vk1_1, 31);
		vk2_1 = _mm512_rol_epi64(vk2_1, 31);
		vk3_1 = _mm512_rol_epi64(vk3_1, 31);
		vk4_1 = _mm512_rol_epi64(vk4_1, 31);

		vk1_1 = _mm512_mullo_epi64(vk1_1, vc2);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc2);
		vk3_1 = _mm512_mullo_epi64(vk3_1, vc2);
		vk4_1 = _mm512_mullo_epi64(vk4_1, vc2);

		vh1_1 = _mm512_xor_epi64(vh1_1, vk1_1);
		vh2_1 = _mm512_xor_epi64(vh2_1, vk2_1);
		vh3_1 = _mm512_xor_epi64(vh3_1, vk3_1);
		vh4_1 = _mm512_xor_epi64(vh4_1, vk4_1);

	
		vh1_1 = _mm512_rol_epi64(vh1_1, 27);
		vh2_1 = _mm512_rol_epi64(vh2_1, 27);
		vh3_1 = _mm512_rol_epi64(vh3_1, 27);
		vh4_1 = _mm512_rol_epi64(vh4_1, 27);

		vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
		vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);
		vh3_1 = _mm512_add_epi64(vh3_1, vh3_2);
		vh4_1 = _mm512_add_epi64(vh4_1, vh4_2);

		vh1_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh1_1, v5), _mm512_set1_epi64( 0x52dce729));
		vh2_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh2_1, v5), _mm512_set1_epi64( 0x52dce729));
		vh3_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh3_1, v5), _mm512_set1_epi64( 0x52dce729));
		vh4_1 = _mm512_add_epi64(_mm512_mullo_epi64(vh4_1, v5), _mm512_set1_epi64( 0x52dce729));


		vk1_2 = _mm512_mullo_epi64(vk1_2, vc2);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc2);
		vk3_2 = _mm512_mullo_epi64(vk3_2, vc2);
		vk4_2 = _mm512_mullo_epi64(vk4_2, vc2);

		vk1_2 = _mm512_rol_epi64(vk1_2, 33);
		vk2_2 = _mm512_rol_epi64(vk2_2, 33);
		vk3_2 = _mm512_rol_epi64(vk3_2, 33);
		vk4_2 = _mm512_rol_epi64(vk4_2, 33);

		vk1_2 = _mm512_mullo_epi64(vk1_2, vc1);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc1);
		vk3_2 = _mm512_mullo_epi64(vk3_2, vc1);
		vk4_2 = _mm512_mullo_epi64(vk4_2, vc1);

		vh1_2 = _mm512_xor_epi64(vh1_2, vk1_2);
		vh2_2 = _mm512_xor_epi64(vh2_2, vk2_2);
		vh3_2 = _mm512_xor_epi64(vh3_2, vk3_2);
		vh4_2 = _mm512_xor_epi64(vh4_2, vk4_2);


		vh1_2 = _mm512_rol_epi64(vh1_2, 31);
		vh2_2 = _mm512_rol_epi64(vh2_2, 31);
		vh3_2 = _mm512_rol_epi64(vh3_2, 31);
		vh4_2 = _mm512_rol_epi64(vh4_2, 31);
		
		vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
		vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);
		vh3_2 = _mm512_add_epi64(vh3_2, vh3_1);
		vh4_2 = _mm512_add_epi64(vh4_2, vh4_1);

		vh1_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh1_2, v5), _mm512_set1_epi64(0x38495ab5));
		vh2_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh2_2, v5), _mm512_set1_epi64(0x38495ab5));
		vh3_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh3_2, v5), _mm512_set1_epi64(0x38495ab5));
		vh4_2 = _mm512_add_epi64(_mm512_mullo_epi64(vh4_2, v5), _mm512_set1_epi64(0x38495ab5));


	}


	//TODO:deal with tail after pending
	if(pend_len > len){

		vk1_1 = vkey1[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk1_2 = vkey1[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);

		vk2_1 = vkey2[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk2_2 = vkey2[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);

		vk3_1 = vkey3[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk3_2 = vkey3[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);

		vk4_1 = vkey4[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk4_2 = vkey4[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);


		vk1_2 = _mm512_mullo_epi64(vk1_2, vc2);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc2);
		vk3_2 = _mm512_mullo_epi64(vk3_2, vc2);
		vk4_2 = _mm512_mullo_epi64(vk4_2, vc2);

		vk1_2 = _mm512_rol_epi64(vk1_2, 33);
		vk2_2 = _mm512_rol_epi64(vk2_2, 33);
		vk3_2 = _mm512_rol_epi64(vk3_2, 33);
		vk4_2 = _mm512_rol_epi64(vk4_2, 33);

		vk1_2 = _mm512_mullo_epi64(vk1_2, vc1);
		vk2_2 = _mm512_mullo_epi64(vk2_2, vc1);
		vk3_2 = _mm512_mullo_epi64(vk3_2, vc1);
		vk4_2 = _mm512_mullo_epi64(vk4_2, vc1);

		vh1_2 = _mm512_xor_epi64(vh1_2, vk1_2);
		vh2_2 = _mm512_xor_epi64(vh2_2, vk2_2);
		vh3_2 = _mm512_xor_epi64(vh3_2, vk3_2);
		vh4_2 = _mm512_xor_epi64(vh4_2, vk4_2);


		vk1_1 = _mm512_mullo_epi64(vk1_1, vc1);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc1);
		vk3_1 = _mm512_mullo_epi64(vk3_1, vc1);
		vk4_1 = _mm512_mullo_epi64(vk4_1, vc1);

		vk1_1 = _mm512_rol_epi64(vk1_1, 31);
		vk2_1 = _mm512_rol_epi64(vk2_1, 31);
		vk3_1 = _mm512_rol_epi64(vk3_1, 31);
		vk4_1 = _mm512_rol_epi64(vk4_1, 31);

		vk1_1 = _mm512_mullo_epi64(vk1_1, vc2);
		vk2_1 = _mm512_mullo_epi64(vk2_1, vc2);
		vk3_1 = _mm512_mullo_epi64(vk3_1, vc2);
		vk4_1 = _mm512_mullo_epi64(vk4_1, vc2);

		vh1_1 = _mm512_xor_epi64(vh1_1, vk1_1);
		vh2_1 = _mm512_xor_epi64(vh2_1, vk2_1);
		vh3_1 = _mm512_xor_epi64(vh3_1, vk3_1);
		vh4_1 = _mm512_xor_epi64(vh4_1, vk4_1);

	}
	

	vh1_1 = _mm512_xor_epi64(vh1_1, vlen);
	vh2_1 = _mm512_xor_epi64(vh2_1, vlen);
	vh3_1 = _mm512_xor_epi64(vh3_1, vlen);
	vh4_1 = _mm512_xor_epi64(vh4_1, vlen);

	vh1_2 = _mm512_xor_epi64(vh1_2, vlen);
	vh2_2 = _mm512_xor_epi64(vh2_2, vlen);
	vh3_2 = _mm512_xor_epi64(vh3_2, vlen);
	vh4_2 = _mm512_xor_epi64(vh4_2, vlen);


	vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
	vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);
	vh3_1 = _mm512_add_epi64(vh3_1, vh3_2);
	vh4_1 = _mm512_add_epi64(vh4_1, vh4_2);

	vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
	vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);
	vh3_2 = _mm512_add_epi64(vh3_2, vh3_1);
	vh4_2 = _mm512_add_epi64(vh4_2, vh4_1);


	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));
	vh3_1 = _mm512_xor_epi64(vh3_1, _mm512_srli_epi64(vh3_1, 33));
	vh4_1 = _mm512_xor_epi64(vh4_1, _mm512_srli_epi64(vh4_1, 33));
	vh1_1 = _mm512_mullo_epi64(vh1_1, vc3);
	vh2_1 = _mm512_mullo_epi64(vh2_1, vc3);
	vh3_1 = _mm512_mullo_epi64(vh3_1, vc3);
	vh4_1 = _mm512_mullo_epi64(vh4_1, vc3);

	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));
	vh3_1 = _mm512_xor_epi64(vh3_1, _mm512_srli_epi64(vh3_1, 33));
	vh4_1 = _mm512_xor_epi64(vh4_1, _mm512_srli_epi64(vh4_1, 33));
	vh1_1 = _mm512_mullo_epi64(vh1_1, vc4);
	vh2_1 = _mm512_mullo_epi64(vh2_1, vc4);
	vh3_1 = _mm512_mullo_epi64(vh3_1, vc4);
	vh4_1 = _mm512_mullo_epi64(vh4_1, vc4);

	vh1_1 = _mm512_xor_epi64(vh1_1, _mm512_srli_epi64(vh1_1, 33));
	vh2_1 = _mm512_xor_epi64(vh2_1, _mm512_srli_epi64(vh2_1, 33));
	vh3_1 = _mm512_xor_epi64(vh3_1, _mm512_srli_epi64(vh3_1, 33));
	vh4_1 = _mm512_xor_epi64(vh4_1, _mm512_srli_epi64(vh4_1, 33));


	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));
	vh3_2 = _mm512_xor_epi64(vh3_2, _mm512_srli_epi64(vh3_2, 33));
	vh4_2 = _mm512_xor_epi64(vh4_2, _mm512_srli_epi64(vh4_2, 33));
	vh1_2 = _mm512_mullo_epi64(vh1_2, vc3);
	vh2_2 = _mm512_mullo_epi64(vh2_2, vc3);
	vh3_2 = _mm512_mullo_epi64(vh3_2, vc3);
	vh4_2 = _mm512_mullo_epi64(vh4_2, vc3);
	
	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));
	vh3_2 = _mm512_xor_epi64(vh3_2, _mm512_srli_epi64(vh3_2, 33));
	vh4_2 = _mm512_xor_epi64(vh4_2, _mm512_srli_epi64(vh4_2, 33));
	vh1_2 = _mm512_mullo_epi64(vh1_2, vc4);
	vh2_2 = _mm512_mullo_epi64(vh2_2, vc4);
	vh3_2 = _mm512_mullo_epi64(vh3_2, vc4);
	vh4_2 = _mm512_mullo_epi64(vh4_2, vc4);

	vh1_2 = _mm512_xor_epi64(vh1_2, _mm512_srli_epi64(vh1_2, 33));
	vh2_2 = _mm512_xor_epi64(vh2_2, _mm512_srli_epi64(vh2_2, 33));
	vh3_2 = _mm512_xor_epi64(vh3_2, _mm512_srli_epi64(vh3_2, 33));
	vh4_2 = _mm512_xor_epi64(vh4_2, _mm512_srli_epi64(vh4_2, 33));

	vh1_1 = _mm512_add_epi64(vh1_1, vh1_2);
	vh2_1 = _mm512_add_epi64(vh2_1, vh2_2);
	vh3_1 = _mm512_add_epi64(vh3_1, vh3_2);
	vh4_1 = _mm512_add_epi64(vh4_1, vh4_2);
	vh1_2 = _mm512_add_epi64(vh1_2, vh1_1);
	vh2_2 = _mm512_add_epi64(vh2_2, vh2_1);
	vh3_2 = _mm512_add_epi64(vh3_2, vh3_1);
	vh4_2 = _mm512_add_epi64(vh4_2, vh4_1);

	//reorganize output	
	vk1_1 = _mm512_permutex2var_epi64(vh1_1,idx1,vh1_2);
	vk2_1 = _mm512_permutex2var_epi64(vh2_1,idx1,vh2_2);
	vk3_1 = _mm512_permutex2var_epi64(vh3_1,idx1,vh3_2);
	vk4_1 = _mm512_permutex2var_epi64(vh4_1,idx1,vh4_2);
	vk1_2 = _mm512_permutex2var_epi64(vh1_1,idx2,vh1_2);
	vk2_2 = _mm512_permutex2var_epi64(vh2_1,idx2,vh2_2);
	vk3_2 = _mm512_permutex2var_epi64(vh3_1,idx2,vh3_2);
	vk4_2 = _mm512_permutex2var_epi64(vh4_1,idx2,vh4_2);

	vh1_1 = _mm512_shuffle_i64x2(vk1_1,vk1_2,0x44);
	vh1_2 = _mm512_shuffle_i64x2(vk1_1,vk1_2,0xEE);
	vh2_1 = _mm512_shuffle_i64x2(vk2_1,vk2_2,0x44);
	vh2_2 = _mm512_shuffle_i64x2(vk2_1,vk2_2,0xEE);
	vh3_1 = _mm512_shuffle_i64x2(vk3_1,vk3_2,0x44);
	vh3_2 = _mm512_shuffle_i64x2(vk3_1,vk3_2,0xEE);
	vh4_1 = _mm512_shuffle_i64x2(vk4_1,vk4_2,0x44);
	vh4_2 = _mm512_shuffle_i64x2(vk4_1,vk4_2,0xEE);
	
	_mm512_storeu_si512((uint64_t*)out, vh1_1);
	_mm512_storeu_si512(&((uint64_t*)out)[8], vh1_2);

	_mm512_storeu_si512(&((uint64_t*)out)[16], vh2_1);
	_mm512_storeu_si512(&((uint64_t*)out)[24], vh2_2);

	_mm512_storeu_si512(&((uint64_t*)out)[32], vh3_1);
	_mm512_storeu_si512(&((uint64_t*)out)[40], vh3_2);

	_mm512_storeu_si512(&((uint64_t*)out)[48], vh4_1);
	_mm512_storeu_si512(&((uint64_t*)out)[56], vh4_2);

//	_mm512_storeu_epi64((uint64_t*)out, vh1_1);
//	_mm512_storeu_epi64(&((uint64_t*)out)[8], vh1_2);
//
//	_mm512_storeu_epi64(&((uint64_t*)out)[16], vh2_1);
//	_mm512_storeu_epi64(&((uint64_t*)out)[24], vh2_2);
//
//	_mm512_storeu_epi64(&((uint64_t*)out)[32], vh3_1);
//	_mm512_storeu_epi64(&((uint64_t*)out)[40], vh3_2);
//
//	_mm512_storeu_epi64(&((uint64_t*)out)[48], vh4_1);
//	_mm512_storeu_epi64(&((uint64_t*)out)[56], vh4_2);
	//_mm512_storeu_epi64(h1, vh1);
	//_mm512_storeu_epi64(h2, vh2);

	//for(int j = 0; j < 8; j++){
  	//	((uint64_t*)out)[0 + j * 2] = h1[j];
  	//	((uint64_t*)out)[1 + j * 2] = h2[j];
	//}

}

void MurmurHash3_x64_128_avx512_8x8 ( __m512i  * vkey, int pend_len, int len, uint32_t seed, void * out )
{
	const int nblocks = len / 16; //real blocks
	__m512i v5 = _mm512_set1_epi64(5);
	__m512i vlen = _mm512_set1_epi64(len);
	uint64_t h1[8];
	uint64_t h2[8];
	__m512i vh1;	
	__m512i vh2;	

	__m512i vk1;
	__m512i vk2;

	vh1 = _mm512_set1_epi64(seed);
	vh2 = _mm512_set1_epi64(seed);

  	const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  	const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);
	__m512i vc1 = _mm512_set1_epi64(c1);
	__m512i vc2 = _mm512_set1_epi64(c2);

  	const uint64_t c3 = BIG_CONSTANT(0xff51afd7ed558ccd);
  	const uint64_t c4 = BIG_CONSTANT(0xc4ceb9fe1a85ec53);
	__m512i vc3 = _mm512_set1_epi64(c3);
	__m512i vc4 = _mm512_set1_epi64(c4);

	__m512i idx1 = _mm512_set_epi64(0xD,0x5,0xC,0x4,0x9,0x1,0x8,0x0);
	__m512i idx2 = _mm512_set_epi64(0xF,0x7,0xE,0x6,0xB,0x3,0xA,0x2);

  	//----------
	//body

  	for(int i = 0; i < nblocks; i++)
	{

		vk1 = vkey[2 * i];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16]);
		vk2 = vkey[2 * i + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[i * 16 + 8]);

		vk1 = _mm512_mullo_epi64(vk1, vc1);
		vk1 = _mm512_rol_epi64(vk1, 31);
		vk1 = _mm512_mullo_epi64(vk1, vc2);
		vh1 = _mm512_xor_epi64(vh1, vk1);

	
		vh1 = _mm512_rol_epi64(vh1, 27);
		vh1 = _mm512_add_epi64(vh1, vh2);
		vh1 = _mm512_add_epi64(_mm512_mullo_epi64(vh1, v5), _mm512_set1_epi64( 0x52dce729));


		vk2 = _mm512_mullo_epi64(vk2, vc2);
		vk2 = _mm512_rol_epi64(vk2, 33);
		vk2 = _mm512_mullo_epi64(vk2, vc1);
		vh2 = _mm512_xor_epi64(vh2, vk2);


		vh2 = _mm512_rol_epi64(vh2, 31);
		vh2 = _mm512_add_epi64(vh2, vh1);
		vh2 = _mm512_add_epi64(_mm512_mullo_epi64(vh2, v5), _mm512_set1_epi64(0x38495ab5));

	}
	//TODO:deal with tail after pending
	if(pend_len > len){

		vk1 = vkey[2 * nblocks];    //_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16]);
		vk2 = vkey[2 * nblocks + 1];//_mm512_loadu_epi64(&((uint64_t*)key)[nblocks * 16 + 8]);

		vk2 = _mm512_mullo_epi64(vk2, vc2);
		vk2 = _mm512_rol_epi64(vk2, 33);
		vk2 = _mm512_mullo_epi64(vk2, vc1);
		vh2 = _mm512_xor_epi64(vh2, vk2);

		vk1 = _mm512_mullo_epi64(vk1, vc1);
		vk1 = _mm512_rol_epi64(vk1, 31);
		vk1 = _mm512_mullo_epi64(vk1, vc2);
		vh1 = _mm512_xor_epi64(vh1, vk1);
	}
	

	vh1 = _mm512_xor_epi64(vh1, vlen);
	vh2 = _mm512_xor_epi64(vh2, vlen);

	vh1 = _mm512_add_epi64(vh1, vh2);
	vh2 = _mm512_add_epi64(vh2, vh1);

	vh1 = _mm512_xor_epi64(vh1, _mm512_srli_epi64(vh1, 33));
	vh1 = _mm512_mullo_epi64(vh1, vc3);
	vh1 = _mm512_xor_epi64(vh1, _mm512_srli_epi64(vh1, 33));
	vh1 = _mm512_mullo_epi64(vh1, vc4);
	vh1 = _mm512_xor_epi64(vh1, _mm512_srli_epi64(vh1, 33));

	vh2 = _mm512_xor_epi64(vh2, _mm512_srli_epi64(vh2, 33));
	vh2 = _mm512_mullo_epi64(vh2, vc3);
	vh2 = _mm512_xor_epi64(vh2, _mm512_srli_epi64(vh2, 33));
	vh2 = _mm512_mullo_epi64(vh2, vc4);
	vh2 = _mm512_xor_epi64(vh2, _mm512_srli_epi64(vh2, 33));

	vh1 = _mm512_add_epi64(vh1, vh2);
	vh2 = _mm512_add_epi64(vh2, vh1);

	//reorganize output	
	vk1 = _mm512_permutex2var_epi64(vh1,idx1,vh2);
	vk2 = _mm512_permutex2var_epi64(vh1,idx2,vh2);

	vh1 = _mm512_shuffle_i64x2(vk1,vk2,0x44);
	vh2 = _mm512_shuffle_i64x2(vk1,vk2,0xEE);

	_mm512_storeu_si512((uint64_t*)out, vh1);
	_mm512_storeu_si512(&((uint64_t*)out)[8], vh2);

	//_mm512_storeu_epi64(h1, vh1);
	//_mm512_storeu_epi64(h2, vh2);

	//for(int j = 0; j < 8; j++){
  	//	((uint64_t*)out)[0 + j * 2] = h1[j];
  	//	((uint64_t*)out)[1 + j * 2] = h2[j];
	//}

}
#else 
#ifdef __AVX2__
// implement by avx2
inline __m256i avx2_mullo_epi64(__m256i a1, __m256i b1) 
{
	__m256i albl = _mm256_mul_epu32(a1, b1);

	const int shuffle= 0xb1;
	const int blendmask = 0x55;
	__m256i a1shuffle = _mm256_shuffle_epi32(a1, shuffle); 
	__m256i b1shuffle = _mm256_shuffle_epi32(b1, shuffle);

	__m256i ahbl = _mm256_mul_epu32(a1shuffle, b1);
	__m256i albh = _mm256_mul_epu32(a1, b1shuffle);

	ahbl = _mm256_add_epi64(ahbl, albh);//sum of albh ahbl
	ahbl = _mm256_shuffle_epi32(ahbl, shuffle);

	albh = _mm256_blend_epi32(ahbl, albl, blendmask);//res without add hi32 of albl
	__m256i zero = _mm256_set1_epi32(0);
	albl = _mm256_blend_epi32(albl, zero, blendmask);

	albh = _mm256_add_epi32(albh, albl);
	return albh;

}

void MurmurHash3_x64_128_avx2_8x4 (__m256i * vkey, int pend_len, int len, uint32_t seed, void *out)
{
	const int nblocks = len / 16;

	__m256i v5 = _mm256_set1_epi64x(5);
	__m256i vlen = _mm256_set1_epi64x(len);


	uint64_t h1[4];
	uint64_t h2[4];
	uint64_t tarr1[4];
	uint64_t tarr2[4];
	__m256i vh1;
	__m256i vh2;
	
	__m256i vk1;
	__m256i vk2;
	__m256i vtmp1;
	__m256i vtmp2;
	__m256i vmul;

	vh1 = _mm256_set1_epi64x(seed);
	vh2 = _mm256_set1_epi64x(seed);

  	const uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  	const uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);
	__m256i vc1 = _mm256_set1_epi64x(c1);
	__m256i vc2 = _mm256_set1_epi64x(c2);

  	const uint64_t c3 = BIG_CONSTANT(0xff51afd7ed558ccd);
  	const uint64_t c4 = BIG_CONSTANT(0xc4ceb9fe1a85ec53);
	__m256i vc3 = _mm256_set1_epi64x(c3);
	__m256i vc4 = _mm256_set1_epi64x(c4);

	__m256i idx1 = _mm256_set_epi64x(0x6, 0x2, 0x4, 0x0);
	__m256i idx2 = _mm256_set_epi64x(0x7, 0x3, 0x5, 0x1);

//body
	for(int i = 0; i < nblocks; i++)
	{
		vk1 = vkey[2 * i];
		vk2 = vkey[2 * i + 1];
		
		//vk1 = _mm256_mullo_epi64(vk1, vc1);
		vk1 = avx2_mullo_epi64(vk1, vc1);
		//vk1 = _mm256_rol_epi64(vk1, 31);
		vtmp1 = _mm256_srli_epi64(vk1, 64-31);
		vtmp2 = _mm256_slli_epi64(vk1, 31);
		vk1 = _mm256_or_si256(vtmp1, vtmp2);
		//vk1 = _mm256_mullo_epi64(vk1, vc2);
		vk1 = avx2_mullo_epi64(vk1, vc2);

		vh1 = _mm256_xor_si256(vh1, vk1);
		//vh1 = _mm256_rol_epi64(vh1, 27);
		vtmp1 = _mm256_srli_epi64(vh1, 64-27);//37=64-27//with bugs
		vtmp2 = _mm256_slli_epi64(vh1, 27);

		//inspect64_256(vtmp1);//no why?????
		//inspect64_256(vtmp2);//yes why????
		vh1 = _mm256_or_si256(vtmp1, vtmp2);
		//inspect64_256(vh1);//no

		vh1 = _mm256_add_epi64(vh1, vh2);
		//vh1 = _mm256_add_epi64(_mm256_mullo_epi64(vh1, v5), _mm256_set1_epi64x(0x52dce729));
		vh1 = _mm256_add_epi64(avx2_mullo_epi64(vh1, v5), _mm256_set1_epi64x(0x52dce729));
		//inspect64_256(vh1);

		//vk2 = _mm256_mullo_epi64(vk2, vc2);
		vk2 = avx2_mullo_epi64(vk2, vc2);
		//vk2 = _mm256_rol_epi64(vk2, 33);
		vtmp1 = _mm256_srli_epi64(vk2, 64-33);
		vtmp2 = _mm256_slli_epi64(vk2, 33);
		vk2 = _mm256_or_si256(vtmp1, vtmp2);
		//vk2 = _mm256_mullo_epi64(vk2, vc1);
		vk2 = avx2_mullo_epi64(vk2, vc1);
		vh2 = _mm256_xor_si256(vh2, vk2);

		//vh2 = _mm256_rol_epi64(vh2, 31);
		vtmp1 = _mm256_srli_epi64(vh2, 64-31);
		vtmp2 = _mm256_slli_epi64(vh2, 31);
		vh2 = _mm256_or_si256(vtmp1, vtmp2);
		vh2 = _mm256_add_epi64(vh2, vh1);
		//vh2 = _mm256_add_epi64(_mm256_mullo_epi64(vh2, v5), _mm256_set1_epi64x(0x38495ab5));
		vh2 = _mm256_add_epi64(avx2_mullo_epi64(vh2, v5), _mm256_set1_epi64x(0x38495ab5));
	
	}
	
	if(pend_len >len){
		
		vk1 = vkey[2 * nblocks];
		vk2 = vkey[2 * nblocks + 1];

		//vk2 = _mm256_mullo_epi64(vk2, vc2);
		vk2 = avx2_mullo_epi64(vk2, vc2);
		//vk2 = _mm256_rol_epi64(vk2, 33);
		vtmp1 = _mm256_srli_epi64(vk2, 64-33);
		vtmp2 = _mm256_slli_epi64(vk2, 33);
		vk2 = _mm256_or_si256(vtmp1, vtmp2);
		//vk2 = _mm256_mullo_epi64(vk2, vc1);
		vk2 = avx2_mullo_epi64(vk2, vc1);
		vh2 = _mm256_xor_si256(vh2, vk2);

		//vk1 = _mm256_mullo_epi64(vk1, vc1);
		vk1 = avx2_mullo_epi64(vk1, vc1);
		//vk1 = _mm256_rol_epi64(vk1, 31);
		vtmp1 = _mm256_srli_epi64(vk1, 64-31);
		vtmp2 = _mm256_slli_epi64(vk1, 31);
		vk1 = _mm256_or_si256(vtmp1, vtmp2);
		//vk1 = _mm256_mullo_epi64(vk1, vc2);
		vk1 = avx2_mullo_epi64(vk1, vc2);
		vh1 = _mm256_xor_si256(vh1, vk1);
	}

	vh1 = _mm256_xor_si256(vh1, vlen);
	vh2 = _mm256_xor_si256(vh2, vlen);
	
	vh1 = _mm256_add_epi64(vh1, vh2);
	vh2 = _mm256_add_epi64(vh2, vh1);

	vh1 = _mm256_xor_si256(vh1, _mm256_srli_epi64(vh1, 33));
	//vh1 = _mm256_mullo_epi64(vh1, vc3);
	vh1 = avx2_mullo_epi64(vh1, vc3);
	vh1 = _mm256_xor_si256(vh1, _mm256_srli_epi64(vh1, 33));
	//vh1 = _mm256_mullo_epi64(vh1, vc4);
	vh1 = avx2_mullo_epi64(vh1, vc4);
	vh1 = _mm256_xor_si256(vh1, _mm256_srli_epi64(vh1, 33));

	vh2 = _mm256_xor_si256(vh2, _mm256_srli_epi64(vh2, 33));
	//vh2 = _mm256_mullo_epi64(vh2, vc3);
	vh2 = avx2_mullo_epi64(vh2, vc3);
	vh2 = _mm256_xor_si256(vh2, _mm256_srli_epi64(vh2, 33));
	//vh2 = _mm256_mullo_epi64(vh2, vc4);
	vh2 = avx2_mullo_epi64(vh2, vc4);
	vh2 = _mm256_xor_si256(vh2, _mm256_srli_epi64(vh2, 33));

	vh1 = _mm256_add_epi64(vh1, vh2);
	vh2 = _mm256_add_epi64(vh2, vh1);

	//reorganize output
	//vk1 = _mm256_permutex2var_epi64(vh1, idx1, vh2);//idx1 TODO
	//vk2 = _mm256_permutex2var_epi64(vh1, idx2, vh2);//idx2 TODO
	vk1 = _mm256_unpacklo_epi64(vh1, vh2);
	vk2 = _mm256_unpackhi_epi64(vh1, vh2);

	//vh1 = _mm256_shuffle_i64x2(vk1, vk2, 0x0);//0x44 TODO
	//vh2 = _mm256_shuffle_i64x2(vk1, vk2, 0x3);//0xEE TODO
	vh1 = _mm256_permute2x128_si256(vk1, vk2, 0x20);
	vh2 = _mm256_permute2x128_si256(vk1, vk2, 0x31);
	//inspect64_256(vh1);
	//inspect64_256(vh2);

	_mm256_storeu_si256((__m256i *)out, vh1);
	_mm256_storeu_si256(&((__m256i *)out)[1], vh2);

	//_mm256_storeu_epi64((uint64_t*)out, vh1);
	//_mm256_storeu_epi64(&((uint64_t*)out)[4], vh2);

	//_mm512_storeu_epi64((uint64_t*)out, vh1);
	//_mm512_storeu_epi64(&((uint64_t*)out)[8], vh2);

}

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

