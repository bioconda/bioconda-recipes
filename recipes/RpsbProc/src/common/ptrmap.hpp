#if !defined(__PTR_MAP__)
#define __PTR_MAP__

#include <vector>

/**********************************************************************
*	A template class for sorting and binary search (map) pointers
*	to TVal. Actual storage of data is not handled, so keep the storage valid
*	and address not changed. Usually work with compactstore class is perfect.
*	Comp is a user-defined object that must have the following operator ()
*	defined:
struct TComp
{
	int operator () (const TVal &v1, const TVal &v2) const;	//for relevent sort by TKey
	int operator () (const TKey &k, const TVal &v) const;	//for search by TKey
};
for sorting int operator (), return -1 if v1 goes before v2, 0 if equivalent, and 1 if v2 goes before v1
for searching int operator (), return -1 if the k is associated with TVal before v, 0 if k match v (found), 1 if k is associated with TVal after v
**********************************************************************/
template<typename TKey, typename TVal, typename TComp>
class CPtrMap
{
public:
	typedef TVal *VAL_PTR;
	typedef const TVal *CONST_VAL_PTR;
	typedef std::vector< VAL_PTR > TSORTED_PTRS;
	
	CPtrMap(void): m_ptr_vec(), m_comp(), m_sort_cmp(m_comp) {};
	CPtrMap(const TComp &c) : m_ptr_vec(), m_comp(c), m_sort_cmp(c) {};
	CPtrMap(const TSORTED_PTRS &v, const TComp &c = TComp());
	CPtrMap(TSORTED_PTRS &&v, const TComp &c = TComp());
	
	void Reset(void) {m_ptr_vec.clear();};
	void Reset(const TSORTED_PTRS & ptrs);
	void Reset(TSORTED_PTRS &&ptrs);
	
	
	VAL_PTR Find(const TKey &k);
	CONST_VAL_PTR Find(const TKey &k) const;
	
	CONST_VAL_PTR operator [] (std::size_t i) const;
	VAL_PTR operator [] (std::size_t i);
	
	VAL_PTR Insert(VAL_PTR pv, bool &inserted);
	
	// -- pass over
	inline
	std::size_t size(void) const
	{
		return m_ptr_vec.size();
	};
	
	inline
	void reserve(std::size_t n)
	{
		m_ptr_vec.reserve(n);
	};


private:
	TSORTED_PTRS m_ptr_vec;
	TComp m_comp;
	struct TSortComp
	{
		const TComp &m_comp;
		bool operator() (CONST_VAL_PTR p1, CONST_VAL_PTR p2)
		{
			return m_comp(*p1, *p2) < 0;
		}
		
		TSortComp(const TComp &cmp): m_comp(cmp) {};
	} m_sort_cmp;
	
};


template<typename TKey, typename TVal, typename TComp>
CPtrMap<TKey, TVal, TComp> :: CPtrMap(const TSORTED_PTRS &v, const TComp &c):
	m_ptr_vec(v), m_comp(c), m_sort_cmp(c)
{
	sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
CPtrMap<TKey, TVal, TComp> :: CPtrMap(TSORTED_PTRS &&v, const TComp &c):
	m_ptr_vec(std::forward<TSORTED_PTRS>(v)), m_comp(c), m_sort_cmp(c)
{
	sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
typename CPtrMap<TKey, TVal, TComp> :: VAL_PTR CPtrMap<TKey, TVal, TComp> :: Find(const TKey &k)
{
	std::size_t rbegin = 0, rend = m_ptr_vec.size(), dist = rend - rbegin;

	while (dist > 0)
	{
		std::size_t rmid = rbegin + (dist >> 1);
		int ord = m_comp(k, *m_ptr_vec[rmid]);
		if (0 == ord)
			return m_ptr_vec[rmid];	//found
		else if (ord > 0) rbegin = rmid + 1;
		else rend = rmid;
		dist = rend - rbegin;
	}
	return nullptr;
}

template<typename TKey, typename TVal, typename TComp>
typename CPtrMap<TKey, TVal, TComp> :: CONST_VAL_PTR CPtrMap<TKey, TVal, TComp> :: Find(const TKey &k) const
{
	
	std::size_t rbegin = 0, rend = m_ptr_vec.size(), dist = rend - rbegin;
	
	while (dist > 0)
	{
		std::size_t rmid = rbegin + (dist >> 1);

		int ord = m_comp(k, *m_ptr_vec[rmid]);
		if (0 == ord)
			return m_ptr_vec[rmid];	//found
		else if (ord > 0) rbegin = rmid + 1;
		else rend = rmid;
		dist = rend - rbegin;
	}
	return nullptr;
}

template<typename TKey, typename TVal, typename TComp>
inline
typename CPtrMap<TKey, TVal, TComp> :: CONST_VAL_PTR CPtrMap<TKey, TVal, TComp> :: operator [] (std::size_t i) const
{
	return (i >= m_ptr_vec.size() ? nullptr : m_ptr_vec[i]);
}


template<typename TKey, typename TVal, typename TComp>
inline
typename CPtrMap<TKey, TVal, TComp> :: VAL_PTR CPtrMap<TKey, TVal, TComp> :: operator [] (std::size_t i)
{
	return (i >= m_ptr_vec.size() ? nullptr : m_ptr_vec[i]);
}

template<typename TKey, typename TVal, typename TComp>
typename CPtrMap<TKey, TVal, TComp> :: VAL_PTR CPtrMap<TKey, TVal, TComp> :: Insert(VAL_PTR pv, bool &inserted)
{
	std::size_t rbegin = 0, rend = m_ptr_vec.size(), dist = rend - rbegin;
	
	while (dist > 0)
	{
		std::size_t rmid = rbegin + (dist >> 1);
		int ord = m_comp(*pv, *m_ptr_vec[rmid]);
		if (0 == ord)
		{
			inserted = false;
			return m_ptr_vec[rmid];	//found
		}
		else if (ord < 0) rbegin = rmid + 1;
		else rend = rmid;
		dist = rend - rbegin;
	}
	m_ptr_vec.insert(m_ptr_vec.begin() + rend, pv);
	inserted = true;
	return m_ptr_vec[rend];
}

template<typename TKey, typename TVal, typename TComp>
void CPtrMap<TKey, TVal, TComp> :: Reset(const TSORTED_PTRS & ptrs)
{
	m_ptr_vec = ptrs;
	if (m_ptr_vec.size() > 1) sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
void CPtrMap<TKey, TVal, TComp> :: Reset(TSORTED_PTRS &&ptrs)
{
	m_ptr_vec = std::move(ptrs);
	if (m_ptr_vec.size() > 1) sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);

}


/**********************************************************************
*	const ptr version
**********************************************************************/
template<typename TKey, typename TVal, typename TComp>
class CCPtrMap
{
public:
	typedef TVal *VAL_PTR;
	typedef const TVal *CONST_VAL_PTR;
	typedef std::vector< CONST_VAL_PTR > TSORTED_PTRS;
	typedef std::vector< VAL_PTR > TSORTED_NCPTRS;
	
	CCPtrMap(void): m_ptr_vec(), m_comp(), m_sort_cmp(m_comp) {};
	CCPtrMap(const TComp &c) : m_ptr_vec(), m_comp(c), m_sort_cmp(c) {};
	CCPtrMap(const TSORTED_PTRS &v, const TComp &c = TComp());
	CCPtrMap(TSORTED_PTRS &&v, const TComp &c = TComp());
	
	CCPtrMap(const TSORTED_NCPTRS &v, const TComp &c = TComp());
	
	void Reset(void) {m_ptr_vec.clear();};
	void Reset(const TSORTED_PTRS & ptrs);
	void Reset(const TSORTED_NCPTRS & ptrs);
	void Reset(TSORTED_PTRS &&ptrs);
	
	CONST_VAL_PTR Find(const TKey &k) const;
	CONST_VAL_PTR operator [] (std::size_t i) const;
	
	CONST_VAL_PTR Insert(CONST_VAL_PTR pv, bool &inserted);
	
	// -- pass over
	inline
	std::size_t size(void) const
	{
		return m_ptr_vec.size();
	};
	
	inline
	void reserve(std::size_t n)
	{
		m_ptr_vec.reserve(n);
	};


private:
	TSORTED_PTRS m_ptr_vec;
	TComp m_comp;
	struct TSortComp
	{
		const TComp &m_comp;
		bool operator() (CONST_VAL_PTR p1, CONST_VAL_PTR p2)
		{
			return m_comp(*p1, *p2) < 0;
		}
		
		TSortComp(const TComp &cmp): m_comp(cmp) {};
	} m_sort_cmp;
	
};


template<typename TKey, typename TVal, typename TComp>
CCPtrMap<TKey, TVal, TComp> :: CCPtrMap(const TSORTED_PTRS &v, const TComp &c):
	m_ptr_vec(v), m_comp(c), m_sort_cmp(c)
{
	sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
CCPtrMap<TKey, TVal, TComp> :: CCPtrMap(TSORTED_PTRS &&v, const TComp &c):
	m_ptr_vec(std::forward<TSORTED_PTRS>(v)), m_comp(c), m_sort_cmp(c)
{
	sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
CCPtrMap<TKey, TVal, TComp> :: CCPtrMap(const TSORTED_NCPTRS &v, const TComp &c):
	m_ptr_vec(), m_comp(c), m_sort_cmp(c)
{
	m_ptr_vec.insert(m_ptr_vec.end(), v.begin(), v.end());
	if (!m_ptr_vec.empty())
		sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}


template<typename TKey, typename TVal, typename TComp>
typename CCPtrMap<TKey, TVal, TComp> :: CONST_VAL_PTR CCPtrMap<TKey, TVal, TComp> :: Find(const TKey &k) const
{
	
	std::size_t rbegin = 0, rend = m_ptr_vec.size(), dist = rend - rbegin;
	
	while (dist > 0)
	{
		std::size_t rmid = rbegin + (dist >> 1);

		int ord = m_comp(k, *m_ptr_vec[rmid]);
		if (0 == ord)
			return m_ptr_vec[rmid];	//found
		else if (ord > 0) rbegin = rmid + 1;
		else rend = rmid;
		dist = rend - rbegin;
	}
	return nullptr;
}

template<typename TKey, typename TVal, typename TComp>
inline
typename CCPtrMap<TKey, TVal, TComp> :: CONST_VAL_PTR CCPtrMap<TKey, TVal, TComp> :: operator [] (std::size_t i) const
{
	return (i >= m_ptr_vec.size() ? nullptr : m_ptr_vec[i]);
}




template<typename TKey, typename TVal, typename TComp>
typename CCPtrMap<TKey, TVal, TComp> :: CONST_VAL_PTR CCPtrMap<TKey, TVal, TComp> :: Insert(CONST_VAL_PTR pv, bool &inserted)
{
	std::size_t rbegin = 0, rend = m_ptr_vec.size(), dist = rend - rbegin;
	
	while (dist > 0)
	{
		std::size_t rmid = rbegin + (dist >> 1);
		int ord = m_comp(*pv, *m_ptr_vec[rmid]);
		if (0 == ord)
		{
			inserted = false;
			return m_ptr_vec[rmid];	//found
		}
		else if (ord < 0) rbegin = rmid + 1;
		else rend = rmid;
		dist = rend - rbegin;
	}
	m_ptr_vec.insert(m_ptr_vec.begin() + rend, pv);
	inserted = true;
	return m_ptr_vec[rend];
}

template<typename TKey, typename TVal, typename TComp>
void CCPtrMap<TKey, TVal, TComp> :: Reset(const TSORTED_PTRS & ptrs)
{
	m_ptr_vec = ptrs;
	if (m_ptr_vec.size() > 1) sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}

template<typename TKey, typename TVal, typename TComp>
void CCPtrMap<TKey, TVal, TComp> :: Reset(const TSORTED_NCPTRS & ptrs)
{
	m_ptr_vec.clear();
	m_ptr_vec.insert(m_ptr_vec.end(), ptrs.begin(), ptrs.end());
	if (!m_ptr_vec.empty())
		sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);
}



template<typename TKey, typename TVal, typename TComp>
void CCPtrMap<TKey, TVal, TComp> :: Reset(TSORTED_PTRS &&ptrs)
{
	m_ptr_vec = std::move(ptrs);
	if (m_ptr_vec.size() > 1) sort(m_ptr_vec.begin(), m_ptr_vec.end(), m_sort_cmp);

}






#endif
