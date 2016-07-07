//
//  Hash16.cpp
//
//  Created by Guillaume Rizk on 19/02/12.
//

#include <iostream>
#include <stdio.h>
#include <string.h>
#include <algorithm> // for max

#include "Hash16.h"

using namespace::std;




Hash16::Hash16()
{
    //empty default constructor
    nb_elem = 0;
    
}

//tai is 2^tai_Hash16
//max is 32
Hash16::Hash16(int tai_Hash16)
{
    if(tai_Hash16>32){
        fprintf(stderr,"max size for this hash is 2^32, resuming with max value \n");
        tai_Hash16=32;
    }
    nb_elem = 0;
    tai = (1LL << tai_Hash16);   
    mask = tai-1 ;
    datah = (cell_ptr_t *) malloc( tai * sizeof(cell_ptr_t));  //create hashtable
    memset(datah,0, tai * sizeof(cell_ptr_t));

   // fprintf(stderr,"sizeof hashtable  %lli MB\n",tai * sizeof(cell_ptr_t)/1024/1024);
    
    storage = new Pool<hash_elem>;
    
}






Hash16::~Hash16()
{
    
    free(datah);
    delete storage;
}


//if graine already here, overwrite old value
void Hash16::insert(hash_elem graine, int value)
{
    
    unsigned int clef ;
    cell<hash_elem> * cell_ptr, *newcell_ptr;
    cell_ptr_t  newcell_internal_ptr;
    
    clef = (unsigned int) (hashcode(graine) & mask);
    
    cell_ptr = storage->internal_ptr_to_cell_pointer(datah[clef]);
    
    while(cell_ptr != NULL &&  cell_ptr->graine != graine)
    {
        cell_ptr = storage->internal_ptr_to_cell_pointer(cell_ptr->suiv);
    }
    if (cell_ptr==NULL) //graine non trouvee , insertion au debut
    {
        newcell_internal_ptr = storage->allocate_cell();
        newcell_ptr = storage->internal_ptr_to_cell_pointer(newcell_internal_ptr);
        newcell_ptr->val=value; 
        newcell_ptr->graine=graine;
        newcell_ptr->suiv=datah[clef];
        datah[clef] = newcell_internal_ptr;
        nb_elem++;
    }
    else  cell_ptr->val=value;  // graine trouvee
    
}


//add graine, and count how  many times it was added
//return 1 if graine first time seen
int Hash16::add(hash_elem graine)
{
    
    

    unsigned int clef ;
    cell<hash_elem> * cell_ptr, *newcell_ptr;
    cell_ptr_t  newcell_internal_ptr;
    
    clef = (unsigned int) hashcode(graine) & mask;


    cell_ptr = storage->internal_ptr_to_cell_pointer(datah[clef]);

    while(cell_ptr != NULL &&  cell_ptr->graine != graine)
    {

        cell_ptr = storage->internal_ptr_to_cell_pointer(cell_ptr->suiv);
    }
    if (cell_ptr==NULL) //graine non trouvee , insertion au debut
    {

        newcell_internal_ptr = storage->allocate_cell();
        newcell_ptr = storage->internal_ptr_to_cell_pointer(newcell_internal_ptr);
        newcell_ptr->val=1; 
        newcell_ptr->graine=graine;
        newcell_ptr->suiv=datah[clef];
        datah[clef] = newcell_internal_ptr;
        nb_elem++;
        return 1;
    }
    else  {
        (cell_ptr->val)++;  // graine trouvee
        return 0;
    }
    
}

int Hash16::has_key( hash_elem graine)
{
    return get(graine,NULL);
}

int Hash16::get( hash_elem graine, int * val)
{
    unsigned int clef ;
    cell<hash_elem> * cell_ptr;
    
    clef = (unsigned int) hashcode(graine) & mask;
    
    cell_ptr = storage->internal_ptr_to_cell_pointer(datah[clef]);
    while(cell_ptr != NULL &&  cell_ptr->graine != graine)
    {
        cell_ptr = storage->internal_ptr_to_cell_pointer(cell_ptr->suiv);
    }
    
    
    if (cell_ptr==NULL)
    {
        return 0;
        
    }
    else
    {
        if (val != NULL)
            *val = cell_ptr->val;
        return 1;
    }
    
    
}



int Hash16::remove( hash_elem graine, int * val)
{
    unsigned int clef ;
    cell<hash_elem>* cell_ptr;
    cell_ptr_t * cellprec_ptr;
    
    clef = (unsigned int) hashcode(graine) & mask;
    
    cell_ptr = storage->internal_ptr_to_cell_pointer(datah[clef]);
    cellprec_ptr = & (datah[clef]);
    
    while(cell_ptr != NULL &&  cell_ptr->graine != graine)
    {
        cellprec_ptr = & (cell_ptr->suiv);
        cell_ptr = storage->internal_ptr_to_cell_pointer(cell_ptr->suiv);
    }
    
    
    if (cell_ptr==NULL)
    {
        if (val != NULL)
            *val = 0;
        return 0;
        
    }
    else
    {
        if (val != NULL)
            *val = cell_ptr->val;
        //delete the cell :
        *cellprec_ptr = cell_ptr->suiv ; 
        
        return 1;
    }
    
    
}

// (note: Hash16 uses 32 bits hashes)

#ifdef _largeint
inline uint64_t Hash16::hashcode(LargeInt<KMER_PRECISION> elem)
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

#ifdef _ttmath
inline uint64_t Hash16::hashcode(ttmath::UInt<KMER_PRECISION> elem)
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

        result ^= hashcode(to_hash);
    }
    return result;
}
#endif

#ifdef _LP64
inline unsigned int Hash16::hashcode( __uint128_t elem )
{
    // hashcode(uint128) = ( hashcode(upper 64 bits) xor hashcode(lower 64 bits)) & mask
    return (hashcode((uint64_t)(elem>>64)) ^ hashcode((uint64_t)(elem&((((__uint128_t)1)<<64)-1))));
}
#endif

inline unsigned int Hash16::hashcode( uint64_t elem )
{
    uint64_t code = elem;
    
    code = code ^ (code >> 14); //supp
    code = (~code) + (code << 18); 
    code = code ^ (code >> 31);
    code = code * 21; 
    code = code ^ (code >> 11);
    code = code + (code << 6);
    code = code ^ (code >> 22);

    return ((unsigned int) code  );
    
}


void Hash16::empty_all()
{
    storage->empty_all();
    nb_elem=0;
    memset(datah,0, tai * sizeof(cell_ptr_t));

}

// call start_iterator to reinit the iterator, then do a while(next_iterator()) {..} to traverse every cell
void Hash16::start_iterator()
{
    iterator.cell_index = -1;
    iterator.cell_ptr = NULL;
    iterator.cell_internal_ptr = 0;
}

// returns true as long as the iterator contains a valid cell
bool Hash16::next_iterator()
{
    while (1)
    {
        // if the current cell is empty, search datah for the next non-empty one
        if (iterator.cell_internal_ptr == 0)
        {
            while (iterator.cell_internal_ptr == 0)
            {
                iterator.cell_index++;
                if ((unsigned int )iterator.cell_index==tai)
                    return false;

                iterator.cell_internal_ptr = datah[iterator.cell_index];
            }
        }
        else // if the current cell is non-empty, go to the next cell
        {
            iterator.cell_internal_ptr = iterator.cell_ptr->suiv;
            if (iterator.cell_internal_ptr == 0)
                continue; // if the next cell is empty, proceed to the "current cell is empty" case
        }
        // at this point we either gave up (return false) or have a non-empty cell
        iterator.cell_ptr = storage->internal_ptr_to_cell_pointer(iterator.cell_internal_ptr);
        break;
    }
    return true;
}

//file should already be opened for writing
void Hash16::dump(FILE * count_file)
{
    cell<hash_elem> * cell_ptr;
    start_iterator();
    while (next_iterator())
    {
        cell_ptr = iterator.cell_ptr;

        fwrite(&cell_ptr->graine, sizeof(cell_ptr->graine), 1, count_file);
        fwrite(&cell_ptr->val, sizeof(cell_ptr->val), 1, count_file);
   }
}

int64_t Hash16::getsolids(Bloom* bloom_to_insert, BinaryBank* solids, int nks)
{
    cell<hash_elem> * cell_ptr;
    start_iterator();
    int64_t nso=0;
    while (next_iterator())
    {
        cell_ptr = iterator.cell_ptr;

        if(cell_ptr->val>=nks)
        {
            nso++;
            solids->write_element(&cell_ptr->graine);
            if (bloom_to_insert != NULL)
                bloom_to_insert->add(cell_ptr->graine);  
        }
    }
    return nso;
}

//print stats of elem having their value >=nks
int Hash16::printstat(int nks, bool print_collisions)
{
    fprintf(stderr,"\n----------------------Stat Hash Table ---------------------\n");
    
    
    long long NbKmersolid = 0;
    int ma=0,mi=99999,cpt=0;
    uint64_t i;
    int maxclef=0;
    
    cell<hash_elem> * cell_ptr;
    cell_ptr_t cell_internal_ptr;
    
    int distrib_colli[512];
    long long  nb_cell=0;
    for (i=0;i<512;i++){distrib_colli[i]=0;}
    
    for (i=0; i<tai; ++i) 
    {
        
        cell_internal_ptr = datah[i]; 
        cell_ptr = storage->internal_ptr_to_cell_pointer(cell_internal_ptr);
        
        cpt=0;
        while(cell_internal_ptr!=0 )
        {
            nb_cell++;
            cpt++;
            if(cell_ptr->val >= nks) NbKmersolid++;
            cell_internal_ptr = cell_ptr->suiv;
            cell_ptr = storage->internal_ptr_to_cell_pointer(cell_internal_ptr);
            
        }
        if(cpt>ma) {ma=cpt;maxclef=i;}
        ma = max(ma,cpt); mi = min(mi,cpt);
        distrib_colli[cpt]++;
    }
    fprintf(stderr,"taille hashtable %llu\n",(unsigned long long)tai);
    fprintf(stderr,"kmer solid/total :  %lli / %lli  %g %%    (%lli elem < %i) \n",(long long)NbKmersolid, (long long)nb_cell, 100*(float)NbKmersolid /nb_cell,(long long)(nb_cell-NbKmersolid),nks);
    
    fprintf(stderr,"max collisions = %i pour clef %i   nb_elem total %lli   reparties sur %llu clefs    %g elem/clef \n",ma,maxclef,nb_cell,(unsigned long long)(tai-distrib_colli[0]), (float)nb_cell/(float)(tai-distrib_colli[0]));
    
    if(print_collisions)
    for (i=0; i<10; i++) 
    {
        fprintf(stderr,"  %9llucollisions :  %9i  \n",(unsigned long long)i,(distrib_colli[i]));
	}
    
    return NbKmersolid;
}


