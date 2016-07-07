//
//  Bloom.cpp
//
//  Created by Guillaume Rizk on 9/02/12.
//

#include <iostream>
#include <stdio.h>
#include <string.h>

#include "Bloom.h"



Bloom::Bloom()
{
    //empty default constructor
    nb_elem = 0;
    blooma = NULL;
}

BloomCpt::BloomCpt()
{
    //empty default constructor
    nb_elem = 0;
    blooma = NULL;

}
void Bloom::setSeed(uint64_t seed)
{
    if(user_seed==0)
    {
        user_seed = seed;
        this->generate_hash_seed(); //regenerate the hash with the new seed
    }
    else{
        fprintf(stderr,"Warning! you should not change the seed a second time!, resuming with previous seed %llu \n",(unsigned long long)user_seed);
    }
}

void Bloom::set_number_of_hash_func(int i)
{
    if(i>NSEEDSBLOOM || i<1){
        fprintf(stderr,"%i is not a valid value for number of hash funcs, should be in [1-%i], resuming wild old value %i\n",i,NSEEDSBLOOM,n_hash_func );
        return;
    }  
    n_hash_func = i;
}

void Bloom::generate_hash_seed()
{
    unsigned int i;
    for ( i = 0; i < NSEEDSBLOOM; ++i)
    {
        seed_tab[i]= rbase[i];
    }
    for ( i = 0; i < NSEEDSBLOOM; ++i)
    {
        seed_tab[i]= seed_tab[i] * seed_tab[(i+3) % NSEEDSBLOOM] + user_seed ;
    }
    
}

#ifdef _largeint
inline uint64_t Bloom::hash_func(LargeInt<KMER_PRECISION> elem, int num_hash)
{
    // hash = XOR_of_series[hash(i-th chunk iof 64 bits)]
    uint64_t result = 0, chunk, mask = ~0;
    LargeInt<KMER_PRECISION> intermediate = elem;
    int i;
    for (i=0;i<KMER_PRECISION;i++)
    {
        chunk = (intermediate & mask).toInt();
        intermediate = intermediate >> 64;
   
        result ^= hash_func(chunk,num_hash);
    }
    return result;
}
#endif

#ifdef _ttmath
inline uint64_t Bloom::hash_func(ttmath::UInt<KMER_PRECISION> elem, int num_hash)
{
    // hash = XOR_of_series[hash(i-th chunk iof 64 bits)]
    uint64_t result = 0, to_hash;
    ttmath::UInt<KMER_PRECISION> intermediate = elem;
    uint32_t mask=~0, chunk;
    int i;
    for (i=0;i<KMER_PRECISION/2;i++)
    {
        // retrieve a 64 bits part to hash 
        (intermediate & mask).ToInt(chunk);
        to_hash = chunk;
        intermediate >>= 32;
        (intermediate & mask).ToInt(chunk);
        to_hash |= ((uint64_t)chunk) << 32 ;
        intermediate >>= 32;

        result ^= hash_func(to_hash,num_hash);
    }
    return result;
}
#endif

#ifdef _LP64
inline uint64_t Bloom::hash_func( __uint128_t elem, int num_hash)
{
    // hash(uint128) = ( hash(upper 64 bits) xor hash(lower 64 bits))
    return hash_func((uint64_t)(elem>>64),num_hash) ^ hash_func((uint64_t)(elem&((((__uint128_t)1)<<64)-1)),num_hash);
}
#endif


inline uint64_t Bloom::hash_func( uint64_t key, int num_hash)
{
    uint64_t hash = seed_tab[num_hash];
    hash ^= (hash <<  7) ^  key * (hash >> 3) ^ (~((hash << 11) + (key ^ (hash >> 5))));
    hash = (~hash) + (hash << 21); // hash = (hash << 21) - hash - 1;
    hash = hash ^ (hash >> 24);
    hash = (hash + (hash << 3)) + (hash << 8); // hash * 265
    hash = hash ^ (hash >> 14);
    hash = (hash + (hash << 2)) + (hash << 4); // hash * 21
    hash = hash ^ (hash >> 28);
    hash = hash + (hash << 31);
    return hash;
}


//tai is 2^tai_bloom
Bloom::Bloom(int tai_bloom)
{
    n_hash_func = 4 ;//def
    user_seed =0;
    nb_elem = 0;
    tai = (1LL << tai_bloom);
    nchar = tai/8LL;
    blooma =(unsigned char *)  malloc( nchar *sizeof(unsigned char)); // 1 bit per elem
    memset(blooma,0,nchar *sizeof(unsigned char));
    //fprintf(stderr,"malloc Power-of-two bloom %lli MB nchar %llu %llu\n",(long long)((tai/8LL)/1024LL/1024LL),(unsigned long long)nchar,(unsigned long long)(tai/8));
    this->generate_hash_seed();
}




 Bloom::Bloom(uint64_t tai_bloom)
 {
     //printf("custom construc \n");
     n_hash_func = 4 ;//def
     user_seed =0;
     nb_elem = 0;
     tai = tai_bloom;
     nchar = (1+tai/8LL);
     blooma =(unsigned char *)  malloc( nchar *sizeof(unsigned char)); // 1 bit per elem
     memset(blooma,0,nchar *sizeof(unsigned char));
     //fprintf(stderr,"malloc bloom %lli MB \n",(tai/8LL)/1024LL/1024LL);
     this->generate_hash_seed();
 }





// //tai is 2^tai_bloom
BloomCpt::BloomCpt(int tai_bloom)
{

    n_hash_func = 2;
    user_seed = 0;
    nb_elem = 0;
    tai = (1LL << tai_bloom);
    blooma =(unsigned char *)  malloc( (tai/2) *sizeof(unsigned char)); //4bits per elem
    memset(blooma,0,(tai/2) *sizeof(unsigned char));
    
    fprintf(stderr,"malloc bloom cpt  %lli MB \n",(tai/2LL)/1024LL/1024LL);
    this->generate_hash_seed();
}


// //tai is 2^tai_bloom
BloomCpt3::BloomCpt3(int tai_bloom)
{

    n_hash_func = 2;
    user_seed = 0;
    nb_elem = 0;
    tai = (1LL << tai_bloom);
    //blooma =(unsigned char *)  malloc( (tai/2) *sizeof(unsigned char)); //4bits per elem
    blooma3 = (uint64_t*)  malloc( ((tai/21)+1) *sizeof(uint64_t)); //3bits per elem, 21 elem per uint64

    memset(blooma3,0, ((tai/21)+1) *sizeof(uint64_t));
    
    fprintf(stderr,"malloc bloom cpt64 3 bits    %lli MB \n",8*(tai/21LL)/1024LL/1024LL);
    this->generate_hash_seed();
}


// //tai is 2^tai_bloom
BloomCpt2::BloomCpt2(int tai_bloom)
{

    n_hash_func = 2;
    user_seed = 0;
    nb_elem = 0;
    tai = (1LL << tai_bloom);
    //blooma =(unsigned char *)  malloc( (tai/2) *sizeof(unsigned char)); //4bits per elem
    blooma2 = (uint64_t*)  malloc( (tai/32) *sizeof(uint64_t)); //2bits per elem, 32 elem per uint64

    memset(blooma2,0, (tai/32) *sizeof(uint64_t));
    
    fprintf(stderr,"malloc bloom cpt64 2 bits    %lli MB \n",8*(tai/32LL)/1024LL/1024LL);
    this->generate_hash_seed();
}





Bloom::~Bloom()
{
  if(blooma!=NULL) 
    free(blooma);
}

BloomCpt3::~BloomCpt3()
{
  if(blooma3!=NULL) 
    free(blooma3);
}


BloomCpt2::~BloomCpt2()
{
  if(blooma2!=NULL) 
    free(blooma2);
}




void Bloom::dump(char * filename)
{
 FILE *file_data;
 file_data = fopen(filename,"wb");
 fwrite(blooma, sizeof(unsigned char), nchar, file_data); //1+
 printf("bloom dumped \n");

}


void Bloom::load(char * filename)
{
 FILE *file_data;
 file_data = fopen(filename,"rb");
 printf("loading bloom filter from file, nelem %lli \n",nchar);
 fread(blooma, sizeof(unsigned char), nchar, file_data);
 printf("bloom loaded\n");


}

long Bloom::weight()
{
    // return the number of 1's in the Bloom, nibble by nibble
    const unsigned char oneBits[] = {0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4};
    long weight = 0;
    for(uint64_t index = 0; index < nchar; index++)
    {
        unsigned char current_char = blooma[index];
        weight += oneBits[current_char&0x0f];
        weight += oneBits[current_char>>4];
    }
    return weight;
}


void Bloom::add(bloom_elem elem)
{
    uint64_t h1;
    int i;
    for(i=0; i<n_hash_func; i++)
    {
#if CUSTOMSIZE
      h1 = hash_func(elem,i) % tai; 
#else
      h1 = hash_func(elem,i) & (tai-1);
#endif
        blooma [h1 >> 3] |= bit_mask[h1 & 7];
    }
    
    //nb_elem++;
    
}



int Bloom::contains(bloom_elem elem)
{
  uint64_t h1;
    int i;
    for(i=0; i<n_hash_func; i++)
    {
#if CUSTOMSIZE
      h1 = hash_func(elem,i) % tai;
#else
      h1 = hash_func(elem,i) & (tai-1);
#endif

        if ((blooma[h1 >> 3 ] & bit_mask[h1 & 7]) != bit_mask[h1 & 7])
            return 0;
    }
    
    
    return 1;
}



void BloomCpt::add(bloom_elem elem)
{
  uint64_t h1;
    unsigned char val,cpt_per_key;
    
    int i;
    for(i=0; i<n_hash_func; i++)
    {
        
        h1 = hash_func(elem,i) & (tai-1);
        val = blooma [h1 / cpt_per_char];
        cpt_per_key = (val & cpt_mask[h1 & 1]) >> (4* (h1 & 1)) ;
        cpt_per_key++;
        if(cpt_per_key==16) cpt_per_key = 15; //satur at 15
        val  &= ~ cpt_mask[h1 & 1];
        val  |= cpt_per_key << (4* (h1 & 1)) ; 
        blooma [h1 / cpt_per_char] = val;
    }
    
    
}


//9698232370296160
int  BloomCpt::contains_n_occ(bloom_elem elem, int nks)
{
  uint64_t h1;
    unsigned char cpt_per_key;
    int i;

    for(i=0; i<n_hash_func; i++)
    {
        h1 = hash_func(elem,i) & (tai-1);
        
        cpt_per_key = (blooma [h1 / cpt_per_char] & cpt_mask[h1 & 1]) >> (4* (h1 & 1));

	if(cpt_per_key<nks) return 0;
    }
    
    return 1;
    
}






void BloomCpt3::add(bloom_elem elem)
{
  uint64_t h1,val;
  uint64_t cpt_per_key;
    
    int i;
    //	printf("Add elem \n");
    // printf ("\nadd3 elem %lli \n",elem);

    for(i=0; i<n_hash_func; i++)
    {
        
        h1 = hash_func(elem,i) & (tai-1);
	// printf("--h1 %lli %lli  m%016llX\n",h1, h1%21,cpt_mask21[h1 % 21]);
        val = blooma3 [h1 / 21]; //21 elem per uint64
	//if(elem==9698232370296160) 	printf("--%016llX\n", val);

        cpt_per_key = (val & cpt_mask21[h1 % 21]) >> (3* (h1 %21)) ;
        cpt_per_key++;
        if(cpt_per_key==8) cpt_per_key = 7; //satur at 7
        val  &= ~ cpt_mask21[h1 % 21];
        val  |= cpt_per_key << (3* (h1 % 21)) ; 
        blooma3 [h1 / 21] = val;
	//	if(elem==9698232370296160)	printf("--%016llX  %i\n", val,cpt_per_key);

    }
    
    
}


int  BloomCpt3::contains_n_occ(bloom_elem elem, int nks)
{
    uint64_t h1;
    unsigned char cpt_per_key;
    int i;
    //	printf("--contains-- \n");
    // if(elem==9698232370296160) printf ("\nquery3 elem %lli \n",elem);

    for(i=0; i<n_hash_func; i++)
    {
        h1 = hash_func(elem,i) & (tai-1);
	//  	printf("h1 %lli \n",h1);

        cpt_per_key = (blooma3 [h1 / 21] & cpt_mask21[h1 % 21]) >> (3* (h1 % 21));

	//printf("%016llX\n", blooma3 [h1 / 21]);
	//printf("cpt %i \n", cpt_per_key);
        //if(elem==9698232370296160) printf("bloocpt3 %i \n", cpt_per_key);

        if(cpt_per_key<nks) return 0;
    }
    
    return 1;
    
}




void BloomCpt2::add(bloom_elem elem)
{
  uint64_t h1,val;
  uint64_t cpt_per_key;
    
    int i;
    //	printf("Add elem \n");
    // printf ("\nadd3 elem %lli \n",elem);

    for(i=0; i<n_hash_func; i++)
    {
        
        h1 = hash_func(elem,i) & (tai-1);
        val = blooma2 [h1 / 32]; //32 elem per uint64

        cpt_per_key = (val & cpt_mask32[h1 & 31]) >> (2* (h1 & 31)) ;
        cpt_per_key++;
        if(cpt_per_key==4) cpt_per_key = 3; //satur at 3
        val  &= ~ cpt_mask32[h1 & 31];
        val  |= cpt_per_key << (2* (h1 & 31)) ; 
        blooma2 [h1 / 32] = val;
	//	if(elem==9698232370296160)	printf("--%016llX  %i\n", val,cpt_per_key);

    }
    
    
}

int  BloomCpt2::contains_n_occ(bloom_elem elem, int nks)
{
    uint64_t h1;
    unsigned char cpt_per_key;
    int i;

    for(i=0; i<n_hash_func; i++)
    {
        h1 = hash_func(elem,i) & (tai-1);

        cpt_per_key = (blooma2 [h1 / 32] & cpt_mask32[h1 & 31]) >> (2* (h1 & 31));


        if(cpt_per_key<nks) return 0;
    }
    
    return 1;
    
}
