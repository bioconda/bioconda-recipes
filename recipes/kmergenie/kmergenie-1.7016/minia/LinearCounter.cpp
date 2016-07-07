#include <algorithm> // for max
#include "LinearCounter.h"

using namespace std; // for max

// counter the number of distinct kmers
// implements a linear counter following [1] K. Whang, B. T. Vander-Zaden, H.M. Taylor. A Liner-Time Probabilistic Counting Algorithm for Database Applications
// an easier presentation is there: http://highlyscalable.wordpress.com/2012/05/01/probabilistic-structures-web-analytics-data-mining/
// here, it's implements as a wrapper around a special Bloom

LinearCounter::LinearCounter(long size) : desired_size(size)
{
    int bloom_nbits = max( (int)ceilf(log2f(size)), 1);
    bloom = new Bloom(bloom_nbits);
    bloom->set_number_of_hash_func(1);
    bloom_size = 1L << bloom_nbits;
}

void LinearCounter::add(bloom_elem kmer)
{
    bloom->add(kmer);
}

int LinearCounter::contains(bloom_elem kmer)
{
    // dummy, because bloom_pass_reads wants this method to be exposed
  return 0;
}

long LinearCounter::count()
{
    long weight = bloom->weight();
    //printf("linear counter load factor: %0.2f\n",(1.0*weight/bloom_size));
    return (long) ( (-1.0*bloom_size) * logf( (1.0*bloom_size - weight) / bloom_size ) );  // linear counter cardinality estimation
}

bool LinearCounter::is_accurate()
{
    long weight = bloom->weight();
    float load_factor = (1.0*weight/bloom_size);
    return load_factor < 0.99;
}

LinearCounter::~LinearCounter()
{
    delete bloom;
}
