// Copyright © 2015, Battelle National Biodefense Institute (BNBI);
// all rights reserved. Authored by: Brian Ondov, Todd Treangen,
// Sergey Koren, and Adam Phillippy
//
// See the LICENSE.txt file included with this software for license information.

#ifndef hash_h
#define hash_h

#include <inttypes.h>

typedef uint32_t hash32_t;
typedef uint64_t hash64_t;

union hash_u
{
    hash32_t hash32;
    hash64_t hash64;
};

hash_u getHash(const char * seq, int length, uint32_t seed, bool use64);
bool hashLessThan(hash_u hash1, hash_u hash2, bool use64);

#endif
