/*
  Most of the functions defined in this file are included from Mash v2.2.
  Modified by Zekun Yin
 */

#ifndef __MINHASH_H__
#define __MINHASH_H__

#include <vector>
#include <queue>

#include "hash.h"
#include <cmath>
#include<unordered_map>
#include "robin_hood.h"


class HashPriorityQueue
{
public:
	
	HashPriorityQueue(bool use64New) : use64(use64New) {}
	void clear();
	void pop() {use64 ? queue64.pop() : queue32.pop();}
	void push(hash_u hash) {use64 ? queue64.push(hash.hash64) : queue32.push(hash.hash32);}
	int size() const {return use64 ? queue64.size() : queue32.size();}
	hash_u top() const;
	
private:
    
	bool use64;
	std::priority_queue<hash32_t> queue32;
	std::priority_queue<hash64_t> queue64;
};

class HashList
{
public:
    
    HashList() {use64 = true;}
    HashList(bool use64new) {use64 = use64new;}
    
    hash_u at(int index) const;
    void clear();
    void resize(int size);
    void set32(int index, uint32_t value);
    void set64(int index, uint64_t value);
    void setUse64(bool use64New) {use64 = use64New;}
    int size() const {return use64 ? hashes64.size() : hashes32.size();}
    void sort();
    void push_back32(hash32_t hash) {hashes32.push_back(hash);}
    void push_back64(hash64_t hash) {hashes64.push_back(hash);}
    bool get64() const {return use64;}

    std::vector<hash32_t> hashes32;
    std::vector<hash64_t> hashes64;
    
private:
    
    bool use64;
};


class HashSet
{
public:

    HashSet(bool use64New) : use64(use64New) {}
    
    int size() const {return use64 ? hashes64.size() : hashes32.size();}
    //void clear() {use64 ? hashes64.clear() : hashes32.clear();}
    void clear() {
			use64 ? hashes64.clear() : hashes32.clear();
			use64 ? hashes64.reserve(0) : hashes32.reserve(0);
    }
    uint32_t count(hash_u hash) const;
    void erase(hash_u hash);
    void insert(hash_u hash, uint32_t count = 1);
    void toHashList(HashList & hashList) const;
    void toCounts(std::vector<uint32_t> & counts) const;
    
private:
    
    bool use64;
    robin_hood::unordered_map<hash32_t, uint32_t> hashes32;
    robin_hood::unordered_map<hash64_t, uint32_t> hashes64;
};

class MinHashHeap
{
public:

	MinHashHeap(bool use64New, uint64_t cardinalityMaximumNew, uint64_t multiplicityMinimumNew = 1, uint64_t memoryBoundBytes = 0);
	~MinHashHeap();
	void computeStats();
	void clear();
	double estimateMultiplicity() const;
	double estimateSetSize() const;
	void toCounts(std::vector<uint32_t> & counts) const;
    void toHashList(HashList & hashList) const;
	void tryInsert(hash_u hash);

private:

	bool use64;
	
	HashSet hashes;
	HashPriorityQueue hashesQueue;
	
	HashSet hashesPending;
	HashPriorityQueue hashesQueuePending;
	
	uint64_t cardinalityMaximum;
	uint64_t multiplicityMinimum;
	
	uint64_t multiplicitySum;
	
    uint64_t kmersTotal;
    uint64_t kmersUsed;
};

inline double MinHashHeap::estimateMultiplicity() const {return hashes.size() ? (double)multiplicitySum / hashes.size() : 0;}
inline double MinHashHeap::estimateSetSize() const {return hashes.size() ? pow(2.0, use64 ? 64.0 : 32.0) * (double)hashes.size() / (use64 ? (double)hashesQueue.top().hash64 : (double)hashesQueue.top().hash32) : 0;}
inline void MinHashHeap::toHashList(HashList & hashList) const {hashes.toHashList(hashList);}
inline void MinHashHeap::toCounts(std::vector<uint32_t> & counts) const {hashes.toCounts(counts);}


namespace Sketch{

void reverseComplement(const char * src, char * dest, int length);

} //namespace Sketch
#endif //__MINHASH_H__
