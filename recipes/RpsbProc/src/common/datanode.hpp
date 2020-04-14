#if !defined(__DATA_NODE__)
#define __DATA_NODE__

//#include <corelib/ncbiexpt.hpp>
//#include <corelib/ncbidiag.hpp>
//#include <corelib/ncbicntr.hpp>
//#include <corelib/ncbiatomic.hpp>
//#include <exception>

#include "normbase.hpp"
#include "basealgo.hpp"
#include "atomic.hpp"
#if defined(_MT)
#include <mutex>
#endif

//#if defined(_MSC_VER)
//template <typename T>
//bool operator==(const std::atomic<T> &x, const std::atomic<T> &y)
//{
//    return x.load() == y.load();
//}
//#endif


class CRefCounter
{
public:
	
	CRefCounter(TAtomicCounterValueType ini = 0):
		m_count(ini)
	{};
	
	TAtomicCounterValueType operator ++(void);
	TAtomicCounterValueType operator ++(int);
	
	
	TAtomicCounterValueType operator --(void);
	TAtomicCounterValueType operator --(int);
	
private:
	TAtomicCounterType m_count;
};

union USmallDataStorage
{
	long long int m_int_value;
	long double m_real_value;
	unsigned long long int m_bool_fields;
	void *m_ptr_value;
	
};

// -- reference counter, base class for all data nodes
class CDocNodeBase
{
	template <typename NODETYPE>
	friend class CDocNodeRef;
protected:
	CDocNodeBase(void);
	// -- just to make sure derived classes will have a virtual destructor
	virtual ~CDocNodeBase(void) {};
private:
	void x_IncRef(void);
	void x_DecRef(void);
	CRefCounter m_counter;
};


template <typename NODETYPE>
class CDocNodeRef
{
public:
	typedef std::atomic< NODETYPE* > _TNodePtr;
	CDocNodeRef(void);
	CDocNodeRef(NODETYPE *node);
	CDocNodeRef(const CDocNodeRef &src);
	~CDocNodeRef(void);
	CDocNodeRef & operator = (CDocNodeRef src);
	
	inline
	NODETYPE * GetPointer(void) {return m_nodeptr.load(std::memory_order_acquire);}
	inline
	const NODETYPE * GetPointer(void) const {return m_nodeptr.load(std::memory_order_acquire);}
	
	bool operator == (const CDocNodeRef &src) const {return m_nodeptr.load() == src.m_nodeptr.load();}
	bool IsEqual(const NODETYPE * p) const {return p == m_nodeptr.load();}
	
	NODETYPE * operator -> (void) {return GetPointer();}
	const NODETYPE * operator -> (void) const {return GetPointer();}
	
	NODETYPE & operator * (void);
	const NODETYPE & operator * (void) const;
	
	bool IsNull(void) const {return nullptr == m_nodeptr.load();}
	
	
	void Release(void);
	
	
	
protected:
	NODETYPE * AtomicSwap(NODETYPE *pNewNode)
	{
		return m_nodeptr.exchange(pNewNode, std::memory_order_acq_rel);
	}
	_TNodePtr m_nodeptr;
};


template <typename NODETYPE>
CDocNodeRef<NODETYPE> ::CDocNodeRef(void):
	m_nodeptr(nullptr)
{}

template <typename NODETYPE>
CDocNodeRef<NODETYPE> ::CDocNodeRef(NODETYPE *node):
	m_nodeptr(node)
{

	NODETYPE *p = GetPointer();
	if (nullptr != p) p->x_IncRef();
}

template <typename NODETYPE>
CDocNodeRef<NODETYPE> ::CDocNodeRef(const CDocNodeRef<NODETYPE> &src):
	m_nodeptr(src.m_nodeptr.load(std::memory_order_acquire))
{
	NODETYPE *p = GetPointer();
	if (nullptr != p) p->x_IncRef();
}

template <typename NODETYPE>
CDocNodeRef<NODETYPE> ::~CDocNodeRef(void)
{
	NODETYPE *p = GetPointer();
	if (nullptr != p) p->x_DecRef();
}

template <typename NODETYPE>
CDocNodeRef<NODETYPE> & CDocNodeRef<NODETYPE> ::operator = (CDocNodeRef<NODETYPE> src)
{

	NODETYPE * p = src.GetPointer();
	if (nullptr != p)
		p->x_IncRef();
	NODETYPE *old = AtomicSwap(p);

	if (nullptr != old) old->x_DecRef();
	return *this;
}

template <typename NODETYPE>
NODETYPE & CDocNodeRef<NODETYPE> :: operator * (void)
{
	NODETYPE * p = GetPointer();
	if (nullptr == p)
		throw CSimpleException(__FILE__, __LINE__, "Try to dereference nullptr");
	return *p;
}

template <typename NODETYPE>
const NODETYPE & CDocNodeRef<NODETYPE> :: operator * (void) const
{
	const NODETYPE * p = GetPointer();
	if (nullptr == p)
		throw CSimpleException(__FILE__, __LINE__, "Try to dereference nullptr");
	return *p;
}


template <typename NODETYPE>
void CDocNodeRef<NODETYPE> ::Release(void)
{
	NODETYPE *old = AtomicSwap(nullptr);
	if (nullptr != old) old->x_DecRef();
}

/**********************************************************************
*	A template class for high-efficiency dynamic memory allocation
**********************************************************************/
template <size_t BLKSZ>
struct TMemBlock
{
	struct TMemBlock * m_pNext;
	BYTE m_bytes[BLKSZ];
	TMemBlock(void): m_pNext(nullptr)
	{
		memset(m_bytes, 0, BLKSZ);
	}
	~TMemBlock(void)
	{
		delete m_pNext;
	}	//chain delete
};


template<size_t DATASZ, size_t DATAPERBLOCK >	//is min # of data, not block size.
class CMemPool
{
public:
	typedef BYTE *DATA_PTR;
	constexpr static size_t MEMBLKSZ = DATASZ * DATAPERBLOCK;
	typedef TMemBlock<MEMBLKSZ> _MEMBLK;
	
	CMemPool(void):
#if defined(_MT)
	m_idx_locker{},
#endif
	m_pHeader(nullptr), m_availables() {};
	~CMemPool(void) {delete m_pHeader;}
	
	CMemPool(const CMemPool& other) = delete;
	CMemPool& operator=(const CMemPool&) = delete;
	
	void * _Op_New_Data(void);
	void _Op_Delete_Data(void * pd);
	
private:
	// - call after pushing in new element that causes storage expanding and construction
	//void x_AddBlockIndices(void);
	
	bool x_new_block(void);
#if defined(_MT)
	std::mutex  m_idx_locker;
#endif	
	
	
	_MEMBLK *m_pHeader;
	std::vector< BYTE* > m_availables;	//indexes to stm_Storage
};

template<size_t DATASZ, size_t DATAPERBLOCK >
bool CMemPool<DATASZ, DATAPERBLOCK> :: x_new_block(void)
{
	size_t total_data = 0;
	DATA_PTR pd = nullptr;
	if (nullptr == m_pHeader)	//first allocation
	{
		m_pHeader = new _MEMBLK;
		if (nullptr == m_pHeader)
			return false;	//failed to allocate memory
		pd = m_pHeader->m_bytes;
		
	}
	else
	{
		_MEMBLK * pblk = m_pHeader;
		while (nullptr != pblk->m_pNext)
		{
			pblk = pblk->m_pNext;
			total_data += DATAPERBLOCK;
		}
		// assert(nullptr == pblk->m_pNext);
		pblk->m_pNext = new _MEMBLK;
		if (nullptr == pblk->m_pNext)
			return false;	//failed to allocate memory
		pd = pblk->m_pNext->m_bytes;
		
	}
	
	total_data += DATAPERBLOCK;	//add the new block size
	
	m_availables.reserve(total_data);
	for (size_t i = 0; i < DATAPERBLOCK; ++i)
	{
		m_availables.push_back(pd);
		pd += DATASZ;
	}
	return true;
}

template<size_t DATASZ, size_t DATAPERBLOCK >
void * CMemPool<DATASZ, DATAPERBLOCK> ::_Op_New_Data(void)
{
#if defined(_MT)
	std::lock_guard<std::mutex> lk(m_idx_locker);
#endif	
	if (m_availables.empty())
		if (!x_new_block())
			return nullptr;
	DATA_PTR pd = m_availables.back();
	m_availables.pop_back();
	return pd;
}


template<size_t DATASZ, size_t DATAPERBLOCK >
void CMemPool<DATASZ, DATAPERBLOCK> ::_Op_Delete_Data(void * pd)
{
#if defined(_MT)
	std::lock_guard<std::mutex> lk(m_idx_locker);
#endif	
	m_availables.push_back((DATA_PTR)pd);
}

// *******************************************************************/




#endif
