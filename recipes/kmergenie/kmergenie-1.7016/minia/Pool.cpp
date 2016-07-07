//
//  Pool.cpp
//  memory pool for hashtable to avoid mallocs
//
//  Created by Guillaume Rizk on 24/11/11.
//

#include <iostream>
#include <stdio.h>

#include "Pool.h"
#include<stdint.h>







/**
 * Constructeur par dÈfaut
 */
template <typename graine_type>
Pool<graine_type>::Pool()
{
    n_pools = 0; n_cells=0;
    //allocation table de pool :
    tab_pool = (cell<graine_type>**)  malloc(N_POOL*sizeof(cell<graine_type> *) );
    
    tab_pool[0]=NULL;n_pools++; // la premiere pool est NULL, pour conversion null_internal -> null
    
    //allocation de la premiere pool : 
    pool_courante =(cell<graine_type>*)  malloc(TAI_POOL*sizeof(cell<graine_type>) );
    tab_pool[n_pools] = pool_courante;
    n_pools++;
}



/**
 * Destructeur
 */
template <typename graine_type>
Pool<graine_type>::~Pool()
{
    
    unsigned  int i;
    
    for(i=1;i<n_pools;i++) // la pool 0 est NULL
    {
        free( tab_pool[i] );
    }
    
    free(tab_pool);
}


template <typename graine_type>
void Pool<graine_type>::empty_all()
{
    
    unsigned  int i;
    
    for(i=2;i<n_pools;i++) // garde la premiere pool pour usage futur 
    {
        free( tab_pool[i] );
    }
    
    //on repasse sur premiere pool 
    pool_courante = tab_pool[1];
    n_cells=0;
    n_pools=2;
    
}


//cell *  Pool::allocate_cell_in_pool()
//{
//    
//    // ncells = nb de cells deja utilisees
//    if (n_cells <TAI_POOL) 
//    {
//        n_cells ++;
//        return (pool_courante + n_cells -1 );
//    }
//    else // la piscine est pleine, on en alloue une nouvelle
//    {
//        pool_courante =(cell*)  malloc(TAI_POOL*sizeof(cell) );
//        tab_pool[n_pools] = pool_courante;
//        n_pools++;
//        n_cells = 1;
//        return (pool_courante);
//        
//    }
//    
//}


//
template <typename graine_type>
 cell<graine_type> *  Pool<graine_type>::internal_ptr_to_cell_pointer(cell_ptr_t internal_ptr)
{
    unsigned int numpool =  internal_ptr & 1023;
    unsigned int numcell =  internal_ptr >> 10;
        
    return (tab_pool[numpool] + numcell);
    
}


template <typename graine_type>
cell_ptr_t  Pool<graine_type>::allocate_cell()
{
    
    cell_ptr_t internal_adress = 0;
    // ncells = nb de cells deja utilisees
    if (n_cells <TAI_POOL) 
    {
        internal_adress = n_pools -1; // low 10 bits  : pool number
        internal_adress |= n_cells  <<10 ; // 22 high bits : cell number in pool
        n_cells ++;

        return internal_adress;
    }
    else // la piscine est pleine, on en alloue une nouvelle
    {
        if(n_pools>= N_POOL)
        {
            fprintf(stderr,"Internal memory allocator is full!\n");
            return 0;
            // will happen when  4G cells are allocated, representing 64 Go 
        }
        pool_courante =(cell<graine_type>*)  malloc(TAI_POOL*sizeof(cell<graine_type>) );
        tab_pool[n_pools] = pool_courante;
        n_pools++;
        n_cells = 1;
        
        internal_adress = n_pools -1; // low 8 bits  : pool number
         // 22 high bits are 0
        
        return internal_adress;
    }
    
}

// trick to avoid linker errors: http://www.parashift.com/c++-faq-lite/templates.html#faq-35.15
template class Pool<uint64_t>;
#ifdef _LP64
template class Pool<__uint128_t>;
#endif
#ifdef _ttmath
template class Pool<ttmath::UInt<KMER_PRECISION> >;
#endif
#ifdef _largeint
template class Pool<LargeInt<KMER_PRECISION> >;
#endif
