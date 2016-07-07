#include "Hashing.h"

#ifdef _largeint
// sadly inlining this provokes a linker error..
uint64_t Hashing::hashcode(LargeInt<KMER_PRECISION> elem)
{
    // hash = XOR_of_series[hash(i-th chunk iof 64 bits)]
    uint64_t result = 0, chunk, mask = ~0;
    LargeInt<KMER_PRECISION> intermediate = elem;
    int i;
    for (i=0;i<KMER_PRECISION;i++)
    {
        chunk = (intermediate & mask).toInt();
        intermediate = intermediate >> 64;
        result ^= hashcode(chunk);
    }
    return result;
}
#endif

#ifdef _LP64
uint64_t Hashing::hashcode( __uint128_t elem )
{
    // hashcode(uint128) = ( hashcode(upper 64 bits) xor hashcode(lower 64 bits))
    return (hashcode((uint64_t)(elem>>64)) ^ hashcode((uint64_t)(elem&((((__uint128_t)1)<<64)-1))));
}
#endif

uint64_t Hashing::hashcode( uint64_t elem )
{
    // RanHash from Numerical Recipes 3rd edition
    uint64_t v = elem * 3935559000370003845ULL + 2691343689449507681ULL;
    v = v ^ (v >> 21);
    v = v ^ (v << 37);
    v = v ^ (v >>  4);
    v = v * 4768777513237032717ULL;
    v = v ^ (v << 20);
    v = v ^ (v >> 41);
    v = v ^ (v <<  5);
    return v;
}

