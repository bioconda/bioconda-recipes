//
//  Pool.h
//  memory pool for hashtable to avoid mallocs
//
//  Created by Guillaume Rizk on 24/11/11.
//

#ifndef compress_Pool_h
#define compress_Pool_h
#include <stdlib.h>
#include <algorithm> // for max/min

#ifdef _ttmath
#include "ttmath/ttmath.h"
#endif
#ifdef _largeint
#include "LargeInt.h"
#endif


typedef unsigned int  cell_ptr_t;

template <typename graine_type>
struct cell
{
    graine_type graine;
    cell_ptr_t  suiv; 
    int val; 
};

#define  TAI_POOL 4194304 //16777216//4194304 // 2^22  16 M cells *16 o    blocs de 256 Mo
#define  N_POOL   1024 //256//1024 //  2^10     soit 4 G cells max 
/**
 * \class Pool, 
 * \brief Cette class dÈfinit une pool memoire pour allocation rapide de la table de hachage utilisee quand seed >14
 */

template <typename graine_type>
class Pool{
public:
	
	/**
	 * table de cell, pour usage courant, 
	 */
	cell<graine_type> * pool_courante;
	/**
	 * stockage de tous les pointeurs  pool
	 */
	cell<graine_type> ** tab_pool;
	/**
	 *  nombre de piscines remplies
	 */
	unsigned int n_pools;

	/**
	 *  niveau de remplissage de la piscine courante 
	 */
	unsigned int n_cells;
    
    
    
	/**
	 * Constructeur par dÈfaut
	 */
	Pool();
	
	/**
	 * alloue une cellule dans la piscine
	 */
	cell<graine_type> *  allocate_cell_in_pool();

    //  allocate cell, return internal pointer type ( 32bits)
    cell_ptr_t  allocate_cell();

      cell<graine_type> *  internal_ptr_to_cell_pointer(cell_ptr_t internal_ptr);

    
	/**
	 * vide toutes piscines
	 * (garde juste une pool vide)
	 */
	void  empty_all();
    
	/**
	 * Destructeur
	 */
	~Pool();
    
};


#endif
