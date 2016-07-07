#ifndef Hashing_h
#define Hashing_h
#include <stdlib.h>
#include <inttypes.h>
#include <stdint.h>

#ifdef _largeint
#include "LargeInt.h"
#else
#ifdef _ttmath
#include "ttmath/ttmath.h"
#endif
#endif

// hash functions: [ any integer type, e.g. 64 bits, 128 bits or ttmath ] -> [ 64 bits hash ]

class Hashing
{
public:
#ifdef _largeint
    static uint64_t hashcode(LargeInt<KMER_PRECISION> elem);
#endif

#ifdef _LP64
    static uint64_t hashcode( __uint128_t elem );
#endif

    static uint64_t hashcode( uint64_t elem );
};

#endif
