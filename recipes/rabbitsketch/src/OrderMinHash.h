#ifndef __ORDERMINHASH_H__
#define __ORDERMINHASH_H__

#include <string>
#include <stdint.h>

namespace Sketch{

//template<typename BT>
static void omh_pos(const std::string& seq, unsigned k, unsigned l, unsigned m, uint64_t mtSeed, char * ptr);

struct mer_info {
	size_t pos;
	uint64_t hash;
	uint64_t int_hash;
	unsigned occ;
	mer_info(){}
	mer_info(size_t p, unsigned o, uint64_t h, uint64_t oh)
		: pos(p)
		  , hash(h)
		  , occ(o)
		  , int_hash(oh)
	{ }
};

inline uint64_t hash_to_uint(const char * kmer, int k);

}
#endif //__ORDERMINHASH_H__
