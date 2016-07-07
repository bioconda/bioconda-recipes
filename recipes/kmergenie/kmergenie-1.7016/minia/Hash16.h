//
//  Hash16.h
//
//  Created by Guillaume Rizk on 19/02/12.
//

#ifndef Hash16_h
#define Hash16_h
#include <stdlib.h>
#include <inttypes.h>
#include <stdint.h>
#include "Pool.h"
#include "Bloom.h"
#include "Bank.h"


//memory usage : sizeof(cell_ptr_t)*tai     +  sizeof(cell)*Nb_inserted
//  ie                    4B*tai   + 16B*nb_inserted

#ifdef _largeint
#include "LargeInt.h"
typedef LargeInt<KMER_PRECISION> hash_elem;
#else
#ifdef _ttmath
#include "ttmath/ttmath.h"
typedef ttmath::UInt<KMER_PRECISION> hash_elem;
#else
#if (! defined kmer_type) || (! defined _LP64)
typedef uint64_t hash_elem;
#else
typedef kmer_type hash_elem;
#endif
#endif
#endif

class Hash16{
    
protected:
    
    cell_ptr_t * datah;
    
    Pool<hash_elem>* storage;
    uint64_t mask ;

#ifdef _largeint
    inline uint64_t hashcode(LargeInt<KMER_PRECISION> elem);
#endif
#ifdef _ttmath
    inline uint64_t hashcode(ttmath::UInt<KMER_PRECISION> elem);
#endif
#ifdef _LP64
    unsigned int hashcode( __uint128_t elem);
#endif
    unsigned int hashcode( uint64_t elem);
public:
    
    //print stats of elem having their value >=nks
   // void printstat(int nks);
    int printstat(int nks, bool print_collisions=0);

    void empty_all();
    void insert(hash_elem graine, int val);
    int add(hash_elem elem);
    void dump(FILE * count_file);//file should already be opened for writing

    int64_t getsolids( Bloom* bloom_to_insert, BinaryBank* solids, int nks);
    
    int get( hash_elem elem, int * val);
    int has_key( hash_elem elem);
    int remove( hash_elem graine, int * val);

    // iterator functions:
    struct 
    {   
        int64_t cell_index;
        cell<hash_elem> * cell_ptr;
        cell_ptr_t cell_internal_ptr;
    } iterator;
    void start_iterator();
    bool next_iterator();

    uint64_t tai;
    uint64_t nb_elem;
    Hash16(int tai_Hash16);
    Hash16();
    ~Hash16();
    
};





#endif

