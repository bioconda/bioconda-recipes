#if !defined(__BASE_ALGO__)
#define __BASE_ALGO__

#include "normbase.hpp"

#include <list>
#include <vector>
#include <algorithm>
#include <iostream>
/**********************************************************************
*	Very basic string operations
**********************************************************************/
// -- trim both ends
void TrimString(std::string &ori) noexcept;
std::string TrimString(std::string &&ori) noexcept;
// -- trim start
void LTrimString(std::string &ori) noexcept;
std::string LTrimString(std::string &&ori) noexcept;
// -- trim end
void RTrimString(std::string &ori) noexcept;
std::string RTrimString(std::string &&ori) noexcept;


// -- string to upper or to lower: user std::transform:
// -- std::transform(str.begin(), str.end(), ::toupper)

char * StrCat(const char* lpszFirst...);
// -- caller must guarantee the buf is big enough
void StrCatBuf(char * buf, const char* lpszFirst...);

size_t StrToUpper(std::string &dst);
size_t StrToLower(std::string &dst);

size_t StringReplace(std::string& rText, const std::string& rOld, const std::string& rNew);

// -- nib: value between 0 - 15
inline
char Nib2Char(BYTE nib)
{
	return nib > 9 ? (nib - 10 + 'a') : (nib + '0');
}

void BinHexOut(std::ostream &os, const BYTE * src, size_t n, const char delim = 0);



class CStringTokenizer
{
public:
	
	static void SplitString(const std::string& rSrcStr, const std::string& rToken, std::vector<std::string>& container);
	static void SplitString(const std::string& rSrcStr, char tk, std::vector<std::string>& container);
	
	CStringTokenizer(const std::string &str, const std::string & tk);
	CStringTokenizer(const std::string &str, std::string && tk);
	CStringTokenizer(const std::string &str, char tk);
	
	void Reset(const std::string &str, const std::string & tk);
	void Reset(const std::string &str, std::string && tk);
	void Reset(const std::string &str, char tk);
	
	// -- will throw integer 0 when done
	std::string get(void);
	std::string getidx(unsigned int i) const;
	size_t count(void) const;
	
private:
	const std::string *m_src;
	std::string m_token;
	size_t m_len, m_tklen;
	size_t m_pos;
};


// *******************************************************************/
	
/**********************************************************************
*	Algorithms based on sorted vector. For total data load, use CCompactStore class
**********************************************************************/
// -- target vector assumed to be ascendingly ordered and TDataType must have operator < () and operator == defined
// -- return true if found, pos contains the position. Otherwise return false with pos points to the potential insert place
// -- generic array search, for vector and array
// -- search [start, end)
template <typename TDataType>
bool BinSearchData(const TDataType *src, size_t start, size_t end, const TDataType & data, size_t &pos)
{
	size_t dist = end - start;
	pos = start + (dist >> 1);
	while (dist > 0)
	{
		if (src[pos] == data)
			return true;
		else if (src[pos] < data) start = pos + 1;
		else end = pos;
		dist = end - start;
		pos = start + (dist >> 1);
	}
	return false; 
}

// -- wrap for vector
template <typename TDataType>
bool BinSearchData(const std::vector<TDataType> & src, const TDataType& data, size_t &pos)
{

	size_t sz = src.size();
	if (0 == sz)	//empty, no storage, should not do 
	{
		pos = 0;
		return false;
	}
	return BinSearchData(&(*src.begin()), 0, sz, data, pos);
}


// -- same as above, but use a user-defined object to compare.
// -- the user object must have
// -- int operator () (const TDataType &v1, const TDataType &v2) const
// -- return 0: two values of TDataType are equivalent
// -- return -1: means v1 < v2
// -- return 1: means v1 > v2
// -- defined.
template <typename TDataType, typename TComp>
bool BinSearchData(const TDataType *src, size_t start, size_t end, const TDataType & data, size_t &pos, const TComp &comp)
{
	size_t dist = end - start;
	pos = start + (dist >> 1);
	while (dist > 0)
	{
		int ord = comp(src[pos], data);
		if (0 == ord)
			return true;
		else if (ord < 0) start = pos + 1;
		else end = pos;
		dist = end - start;
		pos = start + (dist >> 1);
	}
	return false;
}

// -- wrap for vector
template <typename TDataType, typename TComp>
bool BinSearchData(const std::vector<TDataType> & src, const TDataType& data, size_t &pos, const TComp &comp)
{
	size_t sz = src.size();
	if (0 == sz)	//empty, no storage, should not do &(*src.begin())
	{
		pos = 0;
		return false;
	}
	return BinSearchData(&(*src.begin()), 0, sz, data, pos, comp);
}


// -- search against a key, usually a member of TDataType if TDataType is a structure
// -- TComp must provide compare operator(const TKeyType &, const TDataType &)
template <typename TKeyType, typename TDataType, typename TComp>
bool BinSearchData(const TDataType *src, size_t start, size_t end, const TKeyType & key, size_t &pos, const TComp &comp)
{

	size_t dist = end - start;
	pos = start + (dist >> 1);
	while (dist > 0)
	{
		int ord = comp(key, src[pos]);

		if (0 == ord)
			return true;
		else if (ord < 0) end = pos;	//key < src[pos].key
		else start = pos + 1;
		dist = end - start;
		pos = start + (dist >> 1);
	}
	return false;
}

// -- wrap for vector
template <typename TKeyType, typename TDataType, typename TComp>
bool BinSearchData(const std::vector<TDataType> & src, const TKeyType &key, size_t &pos, const TComp &comp)
{
	size_t sz = src.size();
	if (0 == sz)	//empty, no storage, should not do 
	{
		pos = 0;
		return false;
	}
	return BinSearchData(&(*src.begin()), 0, sz, key, pos, comp);
}

template<typename TDataType>
size_t SortAndDeDup(std::vector<TDataType> &dst)
{
	std::sort (dst.begin(), dst.end());

	size_t ulTotalNonRedund = 0;
	
	typename std::vector <TDataType> :: iterator iter1 = dst.begin();
	
	if (dst.end() != iter1)
	{
		++ulTotalNonRedund;	//at least one
		typename std::vector<TDataType>::iterator iter2 = iter1;
		++iter2;
		while (dst.end() != iter2)
		{
			if (!(*iter2 == *iter1))
			{
				++iter1;
				*iter1 = *iter2;
				++ulTotalNonRedund;
			}
			++iter2;
		}
		++iter1;
		dst.erase(iter1, dst.end());
	}
	return ulTotalNonRedund;
}

template<typename TDataType, typename TComp>
size_t SortAndDeDup(std::vector<TDataType> &dst, const TComp &comp)
{
	auto ltop = [comp] (const TDataType &a, const TDataType &b)->bool {return (comp(a, b) < 0);};
	
	std::sort(dst.begin(), dst.end(), ltop);
	size_t ulTotalNonRedund = 0;
	
	
	typename std::vector <TDataType> :: iterator iter1 = dst.begin();
	
	if (dst.end() != iter1)
	{
		++ulTotalNonRedund;	//at least one
		typename std::vector<TDataType>::iterator iter2 = iter1;
		++iter2;
		while (dst.end() != iter2)
		{
			if (0 != comp(*iter1, *iter2))
			{
				++iter1;
				*iter1 = *iter2;
				++ulTotalNonRedund;
			}
			++iter2;
		}
		++iter1;
		dst.erase(iter1, dst.end());
	}
	return ulTotalNonRedund;
	
}

// -- usually it's faster to construct the vector and sort, but sometimes it's convenient to insert/remove on the fly
template<typename TDataType, typename TValueType>
bool InsertDataUnique(std::vector<TDataType> &dst, TValueType &&data, size_t &pos)
{

	bool found = BinSearchData(dst, data, pos);

	if (!found)
		dst.emplace(dst.begin() + pos, std::forward<TValueType> (data));

	return !found;
}

template<typename TDataType, typename TValueType, typename TComp>
bool InsertDataUnique(std::vector<TDataType> &dst, TValueType &&data, size_t &pos, const TComp &comp)
{

	bool found = BinSearchData(dst, data, pos, comp);

	if (!found)
		dst.emplace(dst.begin() + pos, std::forward<TValueType> (data));

	return !found;
}


template<typename TDataType, typename TValueType>
bool InsertDataUnique(std::vector<TDataType> &dst, TValueType &&data)
{
	size_t pos = 0;
	return InsertDataUnique(dst, std::forward<TValueType> (data), pos);
}

template<typename TDataType, typename TValueType, typename TComp>
bool InsertDataUnique(std::vector<TDataType> &dst, TValueType &&data, const TComp &comp)
{
	size_t pos = 0;
	return InsertDataUnique(dst, std::forward<TValueType> (data), pos, comp);
}

template <typename TDataType>
bool RemoveDataValue(std::vector<TDataType> &dst, const TDataType &v)
{
	bool retval = false;
	size_t i = 0, ie = dst.size();
	
	while (i < ie)
	{
		if (v == dst[i])
		{
			for (size_t j = i + 1; j < ie; ++j)
			{
				dst[j - 1] = std::move(dst[j]);
			}
			dst.pop_back();
			--ie;
			retval = true;
			continue;	//skip ++i
		}
		++i;
	}
	
	return retval;
}

template <typename TDataType, typename TEqual>
bool RemoveDataValue(std::vector<TDataType> &dst, const TDataType &v, const TEqual &eq)
{
	bool retval = false;
	size_t i = 0, ie = dst.size();
	
	while (i < ie)
	{
		if (eq(v, dst[i]))
		{
			for (size_t j = i + 1; j < ie; ++j)
			{
				dst[j - 1] = std::move(dst[j]);
			}
			dst.pop_back();
			--ie;
			retval = true;
			continue;	//skip ++i
		}
		++i;
	}
	return retval;
}

template <typename TDataType, typename TQualify>
bool RemoveDataValue(std::vector<TDataType> &dst, const TQualify &qualify)
{
	bool retval = false;
	size_t i = 0, ie = dst.size();
	
	while (i < ie)
	{
		if (qualify(dst[i]))
		{
			for (size_t j = i + 1; j < ie; ++j)
			{
				dst[j - 1] = std::move(dst[j]);
			}
			dst.pop_back();
			--ie;
			retval = true;
			continue;	//skip ++i
		}
		++i;
	}
	return retval;
}

template <typename TDataType>
bool RemoveDataIndex(std::vector<TDataType> &dst, size_t i)
{
	bool retval = false;
	size_t len = dst.size();
	if (i < len)
	{
		for (size_t j = i + 1; j < len; ++j)
			dst[j - 1] = std::move(dst[j]);
		
		dst.pop_back();
		retval = true;
	}
	return retval;
}


template <typename TDataType>
bool RemoveDataIndexCount(std::vector<TDataType> &dst, size_t i, size_t n)
{
	bool retval = false;
	size_t len = dst.size();
	if (i < len && n > 0)
	{
		if (i + n > len)
			n = len - i;	//max to delete
		for (size_t j = i + n; j < len; ++j)
			dst[j - n] = std::move(dst[j]);
		
		dst.erase(dst.begin() + (len - n));
		retval = true;
	}
	return retval;
}

//[start, end)
template <typename TDataType>
bool RemoveDataIndexRange(std::vector<TDataType> &dst, size_t start, size_t end)
{
	bool retval = false;
	if (end > start)
		retval = RemoveDataIndexCount(dst, start, end - start);
	return retval;
}


// -- just for convenient number conversion
template <typename TSrcType, typename TDstType>
void VecTypeConvert(const std::vector<TSrcType> &src, std::vector<TDstType> &dst)
{
	dst.clear();
	size_t n = src.size();
	if (n > 0)
	{
		dst.reserve(n);
		for (size_t i = 0; i < n; ++i)
			dst.emplace_back((TDstType)src[i]);
	}
}

// -- basically equivalent to operator <
template <typename TVal>
struct TCompObj
{
	virtual bool operator () (const TVal &v1, const TVal &v2) const = 0;
};

// -- return 1 if v1 > v2
// -- return 0 if v1 == v2
// -- return -1 if v1 < v2

template <typename TVal>
struct TCompObjEx
{
	virtual int operator () (const TVal &v1, const TVal &v2) const = 0;
};


template <typename TVal>
struct TVectorSort
{
	struct TSortData
	{
		const TVal *p;
		size_t i;
		
		TSortData(const TVal *_p, size_t _i = 0):
			p(_p), i(_i)
		{};
		
		bool operator < (const TSortData &other) const {return *p < *other.p;}
		bool operator == (const TSortData &other) const {return *p == *other.p;}
		TSortData(void) = default;
	};
	
	typedef std::vector<TSortData> TSortDevice;
	
	struct TSortL1Obj
	{
		const TCompObj<TVal> &_cmp;
		bool operator () (const TSortData &sd1, const TSortData &sd2) const
		{
			return _cmp(*sd1.p, *sd2.p);
		}
		
		TSortL1Obj(const TCompObj<TVal> & c):
			_cmp(c) {};
	};
	
	struct TSearchL1Obj
	{
		const TCompObjEx<TVal> &_cmp;
		int operator () (const TSortData &sd1, const TSortData &sd2) const
		{
			return _cmp(*sd1.p, *sd2.p);
		}
		
		TSearchL1Obj(const TCompObj<TVal> & c):
			_cmp(c) {};
	};
	
	
	
	// -- sort and copy to dst. caller must guarantee validity and space of dst.
	// -- suitable for primary types
	static void SortVal(const TVal *pv, size_t n, TVal *dst);
	static void SortVal(const TVal *pv, size_t n, TVal *dst, const TCompObj<TVal> &comp);
	
	// -- sort and store index
	static void SortIndex(const TVal *pv, size_t n, size_t *dst);
	static void SortIndex(const TVal *pv, size_t n, size_t *dst, const TCompObj<TVal> &comp);
	
	// -- sort and store index
	static void Sort(const TVal *pv, size_t n, TSortDevice &dst);
	static void Sort(const TVal *pv, size_t n, TSortDevice &dst, const TCompObj<TVal> &comp);
	
	
	template<template<class T, class Alloc = std::allocator<T> > class C>
	static void Sort(const C<TVal> &container, TSortDevice &dst);
	
	template<template<class T, class Alloc = std::allocator<T> > class C>
	static void Sort(const C<TVal> &container, TSortDevice &dst, const TCompObj<TVal> &comp);
	
	template<typename TITER>
	static void Sort(TITER begin, TITER end, TSortDevice &dst);
	
	template<typename TITER>
	static void Sort(TITER begin, TITER end, TSortDevice &dst, const TCompObj<TVal> &comp);
	
	//Binary search after sort
	static bool BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos);
	static bool BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos, const TCompObjEx<TVal> &comp);
};

template <typename TVal>
bool operator < (const typename TVectorSort<TVal> :: TSortData &sd1, const typename TVectorSort<TVal> :: TSortData &sd2)
{
	return *sd1.p < *sd2.p;
}

template <typename TVal>
bool operator == (const typename TVectorSort<TVal> :: TSortData &sd1, const typename TVectorSort<TVal> :: TSortData &sd2)
{
	return *sd1.p == *sd2.p;
}

template <typename TVal>
void TVectorSort<TVal> ::SortVal(const TVal *pv, size_t n, TVal *dst)
{
	TSortDevice sortdev;
	sortdev.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		sortdev.emplace_back(pv + i, i);
	
	std::sort(sortdev.begin(), sortdev.end());
	
	TVal *pd = dst;
	for (size_t i = 0; i < n; ++i)
	 *pd++ = *sortdev[i].p;
}


template <typename TVal>
void TVectorSort<TVal> ::SortVal(const TVal *pv, size_t n, TVal *dst, const TCompObj<TVal> &comp)
{
	TSortDevice sortdev;
	sortdev.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		sortdev.emplace_back(pv + i, i);
	
	std::sort(sortdev.begin(), sortdev.end(), TVectorSort<TVal> :: TSortL1Obj(comp));
	
	TVal *pd = dst;
	for (size_t i = 0; i < n; ++i)
	 *pd++ = *sortdev[i].p;
}

template <typename TVal>
void TVectorSort<TVal> ::SortIndex(const TVal *pv, size_t n, size_t *dst)
{
	TSortDevice sortdev;
	sortdev.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		sortdev.emplace_back(pv + i, i);
	
	std::sort(sortdev.begin(), sortdev.end());
	
	size_t *pd = dst;
	for (size_t i = 0; i < n; ++i)
	 *pd++ = sortdev[i].i;
}

template <typename TVal>
void TVectorSort<TVal> ::SortIndex(const TVal *pv, size_t n, size_t *dst, const TCompObj<TVal> &comp)
{
	TSortDevice sortdev;
	sortdev.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		sortdev.emplace_back(pv + i, i);
	
	std::sort(sortdev.begin(), sortdev.end(), TVectorSort<TVal> :: TSortL1Obj(comp));
	
	size_t *pd = dst;
	for (size_t i = 0; i < n; ++i)
	 *pd++ = sortdev[i].i;
}

template <typename TVal>
void TVectorSort<TVal> ::Sort(const TVal *pv, size_t n, TSortDevice &dst)
{
	dst.clear();
	dst.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		dst.emplace_back(pv + i, i);
	std::sort(dst.begin(), dst.end());
}

template <typename TVal>
void TVectorSort<TVal> ::Sort(const TVal *pv, size_t n, TSortDevice &dst, const TCompObj<TVal> &comp)
{
	dst.clear();
	dst.reserve(n);
	
	for (size_t i = 0; i < n; ++i)
		dst.emplace_back(pv + i, i);
	std::sort(dst.begin(), dst.end(), TVectorSort<TVal> :: TSortL1Obj(comp));
}

template<typename TVal>
template<template<class T, class Alloc = std::allocator<T> > class C>
void TVectorSort<TVal> ::Sort(const C<TVal> &container, TSortDevice &dst)
{
	dst.clear();
	size_t i = 0, n = container.size();
	dst.reserve(n);
	
	for (typename C<TVal> :: const_iterator iter = container.begin(), iterEnd = container.end(); iterEnd != iter; ++iter, ++i)
		dst.emplace_back(&(*iter), i);
	
	std::sort(dst.begin(), dst.end());
}

template<typename TVal>
template<template<class T, class Alloc = std::allocator<T> > class C>
void TVectorSort<TVal> ::Sort(const C<TVal> &container, TSortDevice &dst, const TCompObj<TVal> &comp)
{
	dst.clear();
	size_t i = 0, n = container.size();
	dst.reserve(n);
	
	for (typename C<TVal> :: const_iterator iter = container.begin(), iterEnd = container.end(); iterEnd != iter; ++iter, ++i)
		dst.emplace_back(&(*iter), i);
	
	std::sort(dst.begin(), dst.end(), TVectorSort<TVal> :: TSortL1Obj(comp));
}

template<typename TVal>
template<typename TITER>
void TVectorSort<TVal> ::Sort(TITER begin, TITER end, TSortDevice &dst)
{
	dst.clear();
	size_t i = 0;
	// -- should go through first to get n?
	for (TITER iter = begin; iter != end; ++iter, ++i);
	dst.reserve(i);
	
	i = 0;
	
	for (TITER iter = begin; iter != end; ++iter, ++i)
		dst.emplace_back(&(*iter), i);
	
	std::sort(dst.begin(), dst.end());
	
}

template<typename TVal>
template<typename TITER>
void TVectorSort<TVal> ::Sort(TITER begin, TITER end, TSortDevice &dst, const TCompObj<TVal> &comp)
{
	dst.clear();
	size_t i = 0;
	// -- should go through first to get n?
	for (TITER iter = begin; iter != end; ++iter, ++i);
	dst.reserve(i);
	
	i = 0;
	
	for (TITER iter = begin; iter != end; ++iter, ++i)
		dst.emplace_back(&(*iter), i);
	
	std::sort(dst.begin(), dst.end(), TVectorSort<TVal> :: TSortL1Obj(comp));
	
}



//static bool BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos);
//static bool BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos, const TCompObjEx<TVal> &comp);
template<typename TVal>
bool TVectorSort<TVal> :: BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos)
{
	size_t sorted_pos = std::string::npos;
	if ( ::BinSearchData(src, TSortData(&val), sorted_pos))
	{
		// -- found
		pos = src[sorted_pos].i;
		return true;
	}
	
	pos = std::string::npos;
	return false;
}

template<typename TVal>
bool TVectorSort<TVal> ::BinSearchData(const TSortDevice &src, const TVal &val, size_t &pos, const TCompObjEx<TVal> &comp)
{
	size_t sorted_pos = std::string::npos;
	if ( ::BinSearchData<TSortData>(src, TSortData(&val), sorted_pos, TSearchL1Obj(comp)))
	{
		// -- found
		pos = src[sorted_pos].i;
		return true;
	}
	
	pos = std::string::npos;
	return false;
}



// *******************************************************************/

/**********************************************************************
*	Commonly used routines
**********************************************************************/

char * B64Encode(const void * blob, size_t &bytes);	//bytes will return the size of char*
BYTE * B64Decode(const char * src, size_t &bytes);

std::string MD5Digest(const void* bytes, UINT64 n);
std::string MD5Digest(const std::string &msg);
std::string MD5Digest(std::istream &istr);
// *******************************************************************/

	
/**********************************************************************
*	misc
**********************************************************************/
// -- must use simple modular if msx < RANDMAX
int GetRandInt(int max = RAND_MAX);
// -- this is just to get a random number and compute the MD5 out of it
std::string GetRandomString(void);


bool AlphaBool(const std::string &rEntryValue, bool bDefault);

template<typename FWD_ITER>
std::ostream & StreamOutWithWrap(std::ostream &os, size_t count_per_line, FWD_ITER iter_start, FWD_ITER iter_end)
{
	if (count_per_line > 0 && iter_end != iter_start)
	{
		size_t c = 0;
		FWD_ITER iter = iter_start;
		while (iter_end != iter)
		{

			if (c >= count_per_line)
			{
				os << std::endl;
				c = 0;
			}
			
			os << *iter;
			++c;
			++iter;
		}

	}
	return os;
}

template<typename FWD_ITER, typename DELIM_TYPE>
std::ostream & StreamOutWithWrap(std::ostream &os, size_t count_per_line, FWD_ITER iter_start, FWD_ITER iter_end, DELIM_TYPE delim)
{
	if (count_per_line > 0 && iter_end != iter_start)
	{
		FWD_ITER iter = iter_start;
		os << *iter++;
		size_t c = 1;
		while (iter != iter_end)
		{
			if (c >= count_per_line)
			{
				os << std::endl;
				os << *iter++;
				c = 1;
			}
			else
			{
				os << delim << *iter++;
				++c;
			}
		}
	}
	return os;
}



#endif
