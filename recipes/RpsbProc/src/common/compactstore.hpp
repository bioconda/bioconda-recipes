#if !defined(__COMPACT_STORE__)
#define __COMPACT_STORE__

#include "data_construct.hpp"
#include "normbase.hpp"
#include "basealgo.hpp"
#include <cstring>
#include <cstdint>
#include <type_traits>
#include <vector>
// -- helper class
// -- memory block contains n * _Td type data
template<typename _Td, size_t _n>
struct TDATABLOCK
{
	typedef _Td TDATA;
	struct TDATABLOCK *m_pNext;
	BYTE m_bytes[_n];
	
	TDATA * GetTypePtr (void) {return static_cast<TDATA* >(static_cast<void* > (m_bytes));}
	const TDATA * GetTypePtr (void) const {return static_cast< const TDATA* >(static_cast< const void* > (m_bytes));}
	
	TDATABLOCK(void): m_pNext(nullptr) {memset(m_bytes, 0, _n);}
	~TDATABLOCK(void) {delete m_pNext;}	//delete is delete the whole chain
};



/**********************************************************************
*	A template class for high-efficiency storage of data. It does not support
* ramdom delete of elements, just keep adding in or Reset to clear everything.
*	It allocates memories in big chunks, by default is exactly 16MB, but will
*	adjust according to sizeof(TDATATYPE)
**********************************************************************/

template<typename TDATATYPE, size_t BLOCKSIZE = 16777216 >	//16 MB exactly.
class CCompactStore
{
public:
	typedef TDATATYPE TDATA;	//just for reference
	static constexpr const size_t SIZEOFDATA = sizeof(TDATATYPE);
	static constexpr const size_t OBJS_PER_BLK = (BLOCKSIZE / SIZEOFDATA + (BLOCKSIZE % SIZEOFDATA > (SIZEOFDATA >> 1) ? 1 : 0));
	static constexpr const size_t EFF_BLK_SIZE = OBJS_PER_BLK * SIZEOFDATA;
	typedef TDATABLOCK<TDATATYPE, EFF_BLK_SIZE> TDATASTORE;
	typedef TDATATYPE *DATA_PTR;
	typedef const TDATATYPE *CONST_DATA_PTR;
	

	CCompactStore(void);
	~CCompactStore(void);
	
	CCompactStore(const CCompactStore& other) = delete;
	CCompactStore& operator=(const CCompactStore&) = delete;
	// -- move only
	CCompactStore(CCompactStore&& other);
	CCompactStore& operator=(CCompactStore&& other);
	
	// -- get pointers to all elements added, in that order
	// -- should be called after all elements are added
	// -- this will clear the dst vector before fill.
	void CreatePtrVector(std::vector<DATA_PTR> &dst);
	void CreatePtrVector(std::vector<CONST_DATA_PTR> &dst) const;
	
	// -- add one element
	template<typename... Args>
	DATA_PTR Append(Args&&...  args);
	
	// -- add n identical elements
	// -- this does not clear ptr_vec, just append onto it. Caller's responsibility to clean it
	template<typename SUBTYPE, typename... Args>
	void Append(size_t n, std::vector< SUBTYPE* > &ptr_vec, Args&&...  args);
		
	// -- add a range of elements
	// -- this does not clear ptr_vec, just append onto it. Caller's responsibility to clean it
	template<typename SUBTYPE, typename FWD_ITER>
	void Append(std::vector< SUBTYPE* > &ptr_vec, FWD_ITER it_from, FWD_ITER it_end);	//insert [*it_from, *it_to)

	
	// -- clear out objects, but does not release extra memories
	void Clear(void);
	// -- clear out objects and release extra memory blocks, only leave one sentinel block.
	void Reset(void);
	
	size_t Size(void) const {return m_total_objects;}
	size_t Capacity(void) const;
	bool IsEmpty(void) const {return 0 == m_total_objects;}
	
	// -- access
	DATA_PTR GetElem(size_t idx);
	CONST_DATA_PTR GetElem(size_t idx) const;
	
	TDATATYPE & operator [] (size_t idx);
	const TDATATYPE & operator [] (size_t idx) const;
	
	std::vector< DATA_PTR > GetPointers(void); 	//to create new index, if needed
	
private:
	TDATASTORE * x_find_tail(size_t &ofs) const;
	TDATASTORE * x_find_data(size_t idx, size_t &ofs) const;
	
	
	// -- memory block: first sizeof(MEM_PTR) bytes are the pointer to next block. the rest are TDATATYPE array
	TDATASTORE *m_pHeader;
	size_t m_total_objects;
	
};

template<typename TDATATYPE, size_t BLOCKSIZE >
CCompactStore<TDATATYPE, BLOCKSIZE> :: CCompactStore(CCompactStore<TDATATYPE, BLOCKSIZE> && other)
{
	m_pHeader = other.m_pHeader;
	m_total_objects = other.m_total_objects;
	
	other.m_pHeader = nullptr;
	other.m_total_objects = 0;
}


template<typename TDATATYPE, size_t BLOCKSIZE >
CCompactStore<TDATATYPE, BLOCKSIZE> & CCompactStore<TDATATYPE, BLOCKSIZE> :: operator= (CCompactStore<TDATATYPE, BLOCKSIZE> && other)
{
	m_pHeader = other.m_pHeader;
	m_total_objects = other.m_total_objects;
	
	other.m_pHeader = nullptr;
	other.m_total_objects = 0;
	return *this;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
void CCompactStore<TDATATYPE, BLOCKSIZE> :: CreatePtrVector(std::vector<typename CCompactStore<TDATATYPE, BLOCKSIZE> :: DATA_PTR> &dst)
{
	dst.clear();
	TDATASTORE *pstore = m_pHeader;
	
	size_t leftover = m_total_objects;
	dst.reserve(m_total_objects);
	
	while (leftover > 0)
	{
		size_t batch = OBJS_PER_BLK;
		if (batch > leftover)
			batch = leftover;
		
		DATA_PTR pd = pstore->GetTypePtr();
		
		for (size_t i = 0; i < batch; ++i)
			dst.emplace_back(pd + i);
			
		leftover -= batch;
		pstore = pstore->m_pNext;
	}
}

template<typename TDATATYPE, size_t BLOCKSIZE >
void CCompactStore<TDATATYPE, BLOCKSIZE> :: CreatePtrVector(std::vector<typename CCompactStore<TDATATYPE, BLOCKSIZE> :: CONST_DATA_PTR> &dst) const
{
	dst.clear();
	const TDATASTORE *pstore = m_pHeader;
	
	size_t leftover = m_total_objects;
	dst.reserve(m_total_objects);
	
	while (leftover > 0)
	{
		size_t batch = OBJS_PER_BLK;
		if (batch > leftover)
			batch = leftover;
		
		CONST_DATA_PTR pd = pstore->GetTypePtr();
		
		for (size_t i = 0; i < batch; ++i)
			dst.emplace_back(pd + i);
			
		leftover -= batch;
		pstore = pstore->m_pNext;
	}
}

template<typename TDATATYPE, size_t BLOCKSIZE >
TDATATYPE & CCompactStore<TDATATYPE, BLOCKSIZE> :: operator [] (size_t idx)
{
	size_t ofs = 0;
	TDATASTORE *pstore = x_find_data(idx, ofs);
	if (nullptr == pstore)
		throw CSimpleException(__FILE__, __LINE__, "Index out of boundary");
	
	return *(pstore->GetTypePtr() + ofs);
}

template<typename TDATATYPE, size_t BLOCKSIZE >
const TDATATYPE & CCompactStore<TDATATYPE, BLOCKSIZE> :: operator [] (size_t idx) const
{
	size_t ofs = 0;
	const TDATASTORE *pstore = x_find_data(idx, ofs);
	if (nullptr == pstore)
		throw CSimpleException(__FILE__, __LINE__, "Index out of boundary");
	
	return *(pstore->GetTypePtr() + ofs);
}

template<typename TDATATYPE, size_t BLOCKSIZE >
template<typename... Args>
typename CCompactStore<TDATATYPE, BLOCKSIZE> :: DATA_PTR CCompactStore<TDATATYPE, BLOCKSIZE> :: Append(Args&&... args)
{
	size_t ofs = 0;
	TDATASTORE *pstore = x_find_tail(ofs);
	if (OBJS_PER_BLK == ofs)
	{
		if (nullptr == pstore->m_pNext)
			pstore->m_pNext = new TDATASTORE;

		pstore = pstore->m_pNext;
		ofs = 0;
	}
	TDATATYPE *pd = pstore->GetTypePtr() + ofs;
	_construct_(pd, std::forward<Args>(args)...);
	++m_total_objects;
	return pd;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
template<typename SUBTYPE, typename... Args>
void CCompactStore<TDATATYPE, BLOCKSIZE> :: Append(size_t n, std::vector< SUBTYPE* > &ptr_vec, Args&&... args)
{
	if (n > 0)
	{
		size_t ofs = 0;
		TDATASTORE *pstore = x_find_tail(ofs);
		size_t leftover = n;
		while (leftover > 0)
		{
			size_t batch = OBJS_PER_BLK - ofs;
			if (0 == batch)	//this block happened to be full.
			{

				if (nullptr == pstore->m_pNext)
					pstore->m_pNext = new TDATASTORE;

				pstore = pstore->m_pNext;
				ofs = 0;
				batch = OBJS_PER_BLK;
			}

			if (batch > leftover) batch = leftover;
			// -- order, order!
			leftover -= batch;
			TDATATYPE *pd = pstore->GetTypePtr() + ofs;
			ofs += batch;
			

			while (batch > 0)
			{
				_construct_(pd, std::forward<Args>(args)...);
				
				++m_total_objects;
				ptr_vec.emplace_back(dynamic_cast< SUBTYPE* > (pd));
				++pd;
				--batch;
			}
		}
	}
}

template<typename TDATATYPE, size_t BLOCKSIZE >
template<typename SUBTYPE, typename FWD_ITER>
void CCompactStore<TDATATYPE, BLOCKSIZE> :: Append(std::vector< SUBTYPE* > &ptr_vec, FWD_ITER it_from, FWD_ITER it_end)	//insert [*it_from, *it_to)
{
	if (it_from != it_end)
	{
		size_t ofs = 0;
		TDATASTORE *pstore = x_find_tail(ofs);
		
		TDATATYPE *pd = pstore->GetTypePtr() + ofs;
		while (it_from != it_end)
		{
			if (ofs == OBJS_PER_BLK)	//this block happened to be full.
			{
				if (nullptr == pstore->m_pNext)
					pstore->m_pNext = new TDATASTORE;

				pstore = pstore->m_pNext;
				ofs = 0;
				pd = pstore->GetTypePtr();
			}
			
			_construct_(pd, std::forward<TDATATYPE>(*it_from));
			ptr_vec.emplace_back(dynamic_cast< SUBTYPE* > (pd));
			++pd;
			++ofs;	//just for count
			
			++it_from;
		}
	}
}




template<typename TDATATYPE, size_t BLOCKSIZE >
CCompactStore<TDATATYPE, BLOCKSIZE> :: CCompactStore(void):
	m_pHeader(new TDATASTORE), m_total_objects(0)
{}



template<typename TDATATYPE, size_t BLOCKSIZE >
CCompactStore<TDATATYPE, BLOCKSIZE> :: ~CCompactStore(void)
{
	Clear();
	delete m_pHeader;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
void CCompactStore<TDATATYPE, BLOCKSIZE> :: Clear(void)
{
	TDATASTORE *p = m_pHeader;
	size_t leftover = m_total_objects;
	
	while (leftover > 0 && nullptr != p)
	{
		size_t batch = leftover;
		if (batch > OBJS_PER_BLK)
			batch = OBJS_PER_BLK;
		
		DATA_PTR pd = p->GetTypePtr();
		for (size_t i = 0; i < batch; ++i)
		{

			_destroy_call_ < std::is_trivial<TDATATYPE>::value > :: __call_destructor__ (pd);
			++pd;
		}
		memset(p->m_bytes, 0, EFF_BLK_SIZE);
		
		leftover -= batch;
		p = p->m_pNext;
	}
	
	m_total_objects = 0;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
void CCompactStore<TDATATYPE, BLOCKSIZE> :: Reset(void)
{
	Clear();
	if (nullptr != m_pHeader)
	{
		delete m_pHeader->m_pNext;
		m_pHeader->m_pNext = nullptr;
	}
}

// -- could return nullptr if data ends at the end of last block.
template<typename TDATATYPE, size_t BLOCKSIZE >
typename CCompactStore<TDATATYPE, BLOCKSIZE> :: TDATASTORE * CCompactStore<TDATATYPE, BLOCKSIZE> :: x_find_tail(size_t &ofs) const
{
	TDATASTORE *p = m_pHeader;
	ofs = m_total_objects;
	while (ofs > OBJS_PER_BLK)
	{
		p = p->m_pNext;
		ofs -=	OBJS_PER_BLK;
	}
	
	return p;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
typename CCompactStore<TDATATYPE, BLOCKSIZE> :: TDATASTORE * CCompactStore<TDATATYPE, BLOCKSIZE> :: x_find_data(size_t idx, size_t &ofs) const
{
	if (idx >= m_total_objects)
	{
		ofs = 0;
		return nullptr;
	}
	
	TDATASTORE *p = m_pHeader;
	ofs = idx;
	while (ofs >= OBJS_PER_BLK)
	{
		p = p->m_pNext;
		ofs -=	OBJS_PER_BLK;
	}
	
	return p;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
size_t CCompactStore<TDATATYPE, BLOCKSIZE> :: Capacity(void) const
{
	size_t cpty = 0;
	TDATASTORE *p = m_pHeader;
	while (nullptr != p)
	{
		cpty += CCompactStore<TDATATYPE, BLOCKSIZE> :: OBJS_PER_BLK;
		p = p->m_pNext;
	}
	return cpty;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
typename CCompactStore<TDATATYPE, BLOCKSIZE> :: DATA_PTR CCompactStore<TDATATYPE, BLOCKSIZE> :: GetElem(size_t idx)
{
	size_t ofs = 0;
	TDATASTORE *pstore = x_find_data(idx, ofs);

	if (nullptr == pstore)
		return nullptr;
	
	return pstore->GetTypePtr() + ofs;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
typename CCompactStore<TDATATYPE, BLOCKSIZE> :: CONST_DATA_PTR CCompactStore<TDATATYPE, BLOCKSIZE> :: GetElem(size_t idx) const
{

	size_t ofs = 0;
	const TDATASTORE *pstore = x_find_data(idx, ofs);

	if (nullptr == pstore)
		return nullptr;
	
	return pstore->GetTypePtr() + ofs;
}

template<typename TDATATYPE, size_t BLOCKSIZE >
std::vector<typename CCompactStore<TDATATYPE, BLOCKSIZE> :: DATA_PTR> CCompactStore<TDATATYPE, BLOCKSIZE> :: GetPointers(void)
{
	std::vector<DATA_PTR> ptrvec;
	ptrvec.reserve(m_total_objects);
	
	TDATASTORE *p = m_pHeader;
	size_t leftover = m_total_objects;
	
	DATA_PTR pIdx = p->GetTypePtr();
	while (leftover > OBJS_PER_BLK)
	{
		for (size_t i = 0; i < OBJS_PER_BLK; ++i)
			ptrvec.emplace_back(pIdx + i);
		p = p->m_pNext;
		pIdx = p->GetTypePtr();
		leftover -=	OBJS_PER_BLK;
	}
	
	for (size_t i = 0; i < leftover; ++i)
		ptrvec.emplace_back(pIdx + i);
	
	
	return ptrvec;
}



// *******************************************************************/





#endif
