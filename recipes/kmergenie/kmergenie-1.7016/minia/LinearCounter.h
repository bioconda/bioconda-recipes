//
//  LinearCounter.h

#ifndef LinearCounter_h
#define LinearCounter_h
#include <stdlib.h>
#include <inttypes.h>
#include <stdint.h>
#include <cmath> // for log2f
#include "Bank.h"
#include "Bloom.h"

class LinearCounter{

protected:

    Bloom *bloom;
    unsigned long desired_size, bloom_size; 
public:
    void add(bloom_elem kmer);
    long count();
    int contains(bloom_elem kmer); // dummy, because bloom_pass_reads wants this method to be exposed
    bool is_accurate();

    LinearCounter(long size);
    ~LinearCounter();
};

#endif
