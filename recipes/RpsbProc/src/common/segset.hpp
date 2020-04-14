#if !defined(__SEG_SET__)
#define __SEG_SET__
#if defined(__DB_OFFLINE__)
#include "envdef.hpp"
#include "normbase.hpp"
#else
#include <NcbiBase/envdef.hpp>
#include <BasicUtils/normbase.hpp>
#endif
#include <list>
#include <vector>
#include <algorithm>
struct TSeg_base
{
	struct TResiduePos
	{
		SeqPos_t curr, ori;
		TResiduePos(SeqPos_t c = 0, SeqPos_t o = 0): curr(c), ori(o) {};
	};
	
	SeqPos_t from;
	SeqPos_t to;
	
	// -- The ori_from should always be pointing to the position on original sequence that corresponding to the "from" of the current mapped position. Pay attention to negative strand proteins, the ori_from should be the coordinate of the C'- residue of thesegment on original. Any mapping should keep this relationship unchanged. 
	SeqPos_t ori_from;
	
	bool operator == (const TSeg_base& other) const;
	
	TSeg_base(SeqPos_t f = 0, SeqPos_t t = 0): from(f), to(t), ori_from(f) {};
	bool IsValid(void) const;
	
	bool LeftTo(const TSeg_base& rSrcSeg) const {return (to < rSrcSeg.from - 1);} 
	bool RightTo(const TSeg_base& rSrcSeg) const {return (from > rSrcSeg.to + 1);}
	bool LeftTouch(const TSeg_base& rSrcSeg) const {return (to == rSrcSeg.from - 1);}
	bool RightTouch(const TSeg_base& rSrcSeg) const {return (from == rSrcSeg.to + 1);}
	bool MoreLeft(const TSeg_base& rSrcSeg) const {return (from < rSrcSeg.from);}
	bool MoreRight(const TSeg_base& rSrcSeg) const {return (to > rSrcSeg.to);}
	bool Overlap(const TSeg_base& rSrcSeg) const {return ((from >= rSrcSeg.from && from <= rSrcSeg.to) || (rSrcSeg.from >= from && rSrcSeg.from <= to));}
	bool Touch(const TSeg_base& rSrcSeg) const {return (LeftTouch(rSrcSeg) || RightTouch(rSrcSeg));}
};

// -- sort from left most to right
struct TSegSortLeft
{
	bool operator () (const TSeg_base* s1, const TSeg_base* s2);
};

// -- sort from long to short segs, so short segs will be drawn later than long segs
struct TSegSortLength
{
	bool operator () (const TSeg_base* s1, const TSeg_base* s2);
};


template <typename SEGTYPE>
class CSegSetTmpl
{
	friend class TSeqAlignment;
	
	friend class CDataCache & operator << (class CDataCache &dc, const CSegSetTmpl<SEGTYPE> & d);
	friend class CDataCache & operator >> (class CDataCache &dc, CSegSetTmpl<SEGTYPE> & d);
public:
	
	typedef SEGTYPE TSeg;
	typedef std::list<SEGTYPE> TSegs;	
	
	
	CSegSetTmpl(void): m_iFactor(1), m_lstContainer(), m_ulGapThreshold(k_SeqLen_Max) {};
	CSegSetTmpl(const std::vector<SeqPos_t>& starts, const std::vector<SeqLen_t>& lens);	//always set ofs to zero! so must use slave coordinates.
	virtual ~CSegSetTmpl(void) {};
	
	//this must be a normal segs: align from left to right
	void SetData(const std::vector<SeqPos_t>& starts, const std::vector<SeqLen_t>& lens);	//always set ofs to zero! so must use slave coordinates.
	void SetData(const std::vector<SeqPos_t> &residues);

	bool operator == (const CSegSetTmpl& other) const;
	
	// -- status
	bool IsEmpty(void) const {return m_lstContainer.empty();}
	int GetTransFactor(void) const {return m_iFactor;}
	
	// -- manipulate. 
	// -- any operation, the ori_from and ori_to are calculated based on target segment. src segs ori information are discarded.
	void AddSeg(SeqPos_t f, SeqPos_t t);	//  
	void AddSeg(const SEGTYPE& seg);
	
	void Clear(void) {m_lstContainer.clear();}
	
	void Merge(const CSegSetTmpl& src);
	void Cross(const CSegSetTmpl& src);
	void Clip(const CSegSetTmpl& src);
	void Inv(SeqPos_t from, SeqPos_t to);	//inverse against a total range

	SeqPos_t GetLeft(void) const;
	SeqPos_t GetRight(void) const;
	//SeqPos_t GetLeftOfs(void) const;
	//SeqPos_t GetRightOfs(void) const;
	SeqPos_t GetTotalResidues(void) const;
	

	void GetOverall(SEGTYPE &target, SeqPos_t &ori_to) const;	//ori-to is calculated from the last segment factor is 1 or 3 -- if Pr2na
	SeqPos_t GetOriTo(typename TSegs::const_iterator citer, SeqPos_t pos = -1) const;
	SeqPos_t GetOriTo(void) const;
	const TSegs& GetSegs(void) const {return m_lstContainer;}
	// -- gapThreshold is AA residue counts. Will automatically convert to NA (if applicable) counts in the result
	void GetGaps(CSegSetTmpl<SEGTYPE> &dst) const;
	//void GetSimplePosMap(std::vector<TResiduePos> &dst) const;
	//void GetOriSimplePosMap(std::vector<TResiduePos> &dst) const;
	void GetTranslatedPosMap(size_t aaSeqLen, std::vector<TSeg_base::TResiduePos> &dst) const;
	virtual int GetCompleteSize(void) const {return -1;}
	
protected:
	// -- the actual container
	//factor: when map protein to na, it is 3, otherwise it is 1. sign denotes the direction, it is mainly
	// -- responsible to calculate ori_to from ori_from of each segment.
	int m_iFactor;
	
	TSegs m_lstContainer;
public:
	SeqLen_t m_ulGapThreshold;

};


template <typename SEGTYPE>
CSegSetTmpl<SEGTYPE>::CSegSetTmpl(const std::vector<SeqPos_t> &starts, const std::vector<SeqLen_t> &lens): m_iFactor(1), m_lstContainer(), m_ulGapThreshold(k_SeqLen_Max)
{
	// -- do not clear segset first. we may need to add segs
	SetData(starts, lens);
}


template <typename SEGTYPE>
bool CSegSetTmpl<SEGTYPE>::operator == (const CSegSetTmpl<SEGTYPE> & other) const
{
	return m_lstContainer == other.m_lstContainer;
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::SetData(const std::vector<SeqPos_t>& starts, const std::vector<SeqLen_t>& lens)
{
	m_lstContainer.clear();
	for (size_t i = 0; i < lens.size(); ++i)
		AddSeg(starts[i], starts[i] + lens[i] - 1);
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::SetData(const std::vector<SeqPos_t> &residues)
{
	m_lstContainer.clear();
	
	if (residues.empty()) return;
	
	std::vector<SeqPos_t> sorted(residues);
	std::sort(sorted.begin(), sorted.end());
	
	SEGTYPE seg;
	
	seg.from = seg.to = seg.ori_from = sorted[0];
	
	size_t i = 0, iEnd = sorted.size();
	
	while (i < iEnd)
	{
		if (sorted[i] > seg.to + 1)
		{
			AddSeg(seg);
			seg.from = seg.to = seg.ori_from = sorted[i];
		}
		else if (sorted[i] > seg.to)
		{
			seg.to = sorted[i];
		}
		
		++i;
	}
	AddSeg(seg);
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::AddSeg(SeqPos_t f, SeqPos_t t)
{
	AddSeg(SEGTYPE(f, t));
}

// -- will discard seg original info
template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::AddSeg(const SEGTYPE& seg)
{
	if (!seg.IsValid()) return;
	typename TSegs::iterator curr = m_lstContainer.begin(), dstEnd = m_lstContainer.end();
	
	while (dstEnd != curr && curr -> to < seg.from - 1) ++curr;
	if (curr == m_lstContainer.end())	//add to end
	{
		m_lstContainer.emplace(dstEnd, seg);
		return;
	}
	else if (curr->from > seg.to + 1)	// gap big enough
	{
		m_lstContainer.emplace(curr, seg);
		return;
	}
	else	//merge the seg in
	{
		if (curr->from > seg.from)
		{
			curr->ori_from -= (curr->from - seg.from) / m_iFactor;
			curr->from = seg.from;	//extended left
			
		}
		if (curr->to < seg.to)
		{
			curr->to = seg.to;	//extended right
		}
		
		typename TSegs::iterator nxt = curr;
		
		++nxt;
		while (nxt != dstEnd && nxt->from <= curr->to + 1)
		{
			if (curr->to < nxt->to)
			{
				curr->to = nxt->to;	//merge next
			}
			m_lstContainer.erase(nxt);
			nxt = curr;
			++nxt;
		}
	}
}


template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::Merge(const CSegSetTmpl<SEGTYPE> &src)
{
	typename TSegs::iterator curr = m_lstContainer.begin();
	typename TSegs::const_iterator scur = src.m_lstContainer.begin();
	
	while (curr!= m_lstContainer.end() && scur != src.m_lstContainer.end())
	{
		if (curr->to < scur->from - 1) ++curr;
		else if (scur->to < curr->from - 1)
		{
			m_lstContainer.emplace(curr, *scur);
			++scur;
		}
		else
		{
			// -- merge this src seg
			if (curr->from > scur->from)
			{
				curr->ori_from -= (curr->from - scur->from) / m_iFactor;
				curr->from = scur->from;
			}
			if (curr->to < scur->to)
			{
				curr->to = scur->to;
			}
			// -- to next src seg
			++scur;
			
			// maintain this set			
			typename TSegs::iterator nxt = curr;
			++nxt;
			while (nxt != m_lstContainer.end() && nxt->from <= curr->to + 1)
			{
				if (curr->to < nxt->to)
				{
					curr->to = nxt->to;	//merge next
				}
				m_lstContainer.erase(nxt);
				nxt = curr;
				++nxt;
			}
		}
	}
	// -- add the rest segs in
	
	while (scur != src.m_lstContainer.end())
		m_lstContainer.emplace_back(*scur++);
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::Cross(const CSegSetTmpl<SEGTYPE> & src)
{
	typename TSegs::iterator curr = m_lstContainer.begin();
	typename TSegs::const_iterator scur = src.m_lstContainer.begin();
	
	while (curr!= m_lstContainer.end() && scur != src.m_lstContainer.end())
	{
		if (curr->to < scur->from)
		{
			typename TSegs::iterator del = curr;
			++curr;
			m_lstContainer.erase(del);
		} 
		else if (scur->to < curr->from)
		{
			++scur;
		}
		else
		{
			if (curr->from < scur->from)
			{
				curr->ori_from += (scur->from - curr->from) / m_iFactor;
				curr->from = scur->from;
			}
			if (curr->to > scur->to + 1)
			{
				SEGTYPE temp(curr->from, scur->to);
				temp.ori_from = curr->ori_from;
				m_lstContainer.emplace(curr, temp);
				
				curr->ori_from += (scur->to + 2 - curr->from) / m_iFactor;
				curr->from = scur->to + 2;
				++scur;
			}
			else
			{
				if (curr->to > scur->to)
				{
					curr->to = scur->to;
					++scur;
				}
				++curr;
			}
		}
	}
	m_lstContainer.erase(curr, m_lstContainer.end());
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::Clip(const CSegSetTmpl<SEGTYPE>& src)
{
	typename TSegs::iterator curr = m_lstContainer.begin();
	typename TSegs::const_iterator scur = src.m_lstContainer.begin();
	
	while (curr!= m_lstContainer.end() && scur != src.m_lstContainer.end())
	{
		if (curr->to < scur->from)
		{
			++curr;
		} 
		else if (scur->to < curr->from)
		{
			++scur;
		}
		else
		{
			if (curr->from < scur->from)
			{
				SEGTYPE temp(curr->from, scur->from - 1);
				temp.ori_from = curr->ori_from;
				m_lstContainer.emplace(curr, temp);
			}
			if (curr->to <= scur->to)
			{
				typename TSegs::iterator del = curr;
				++curr;
				m_lstContainer.erase(del);
			}
			else
			{
				curr->ori_from += (scur->to + 1 - curr->from) / m_iFactor;
				curr->from = scur->to + 1;
				++scur;
			}
		}
	}
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::Inv(SeqPos_t from, SeqPos_t to)	//inverse against a total range, discard original coordinates
{
	typename TSegs::iterator hdr = m_lstContainer.begin(), curr = hdr, dstEnd = m_lstContainer.end();
	
	while (curr != dstEnd && curr->to < from)
		++curr;
	m_lstContainer.erase(hdr, curr);
	
	SeqPos_t start = from;
	while (curr != dstEnd && curr->from < to)
	{
		if (curr->from > start)	//insert new
		{
			SEGTYPE temp(start, curr->from - 1);
			m_lstContainer.emplace(curr, temp);
		}
		start = curr->to + 1;
		typename TSegs::iterator del = curr;
		++curr;
		m_lstContainer.erase(del);
	}
	
	// -- assert()
	if (start <= to)
		m_lstContainer.emplace(curr, SEGTYPE(start, to));
	// -- assert(curr->from > end);
	m_lstContainer.erase(curr, dstEnd);
}

template <typename SEGTYPE>
SeqPos_t CSegSetTmpl<SEGTYPE>::GetLeft(void) const
{
	return IsEmpty() ? -1 : m_lstContainer.begin()->from;
}

template <typename SEGTYPE>
SeqPos_t CSegSetTmpl<SEGTYPE>::GetRight(void) const
{
	return IsEmpty() ? -1 : m_lstContainer.rbegin()->to;
}


template <typename SEGTYPE>
SeqPos_t CSegSetTmpl<SEGTYPE>::GetTotalResidues(void) const
{
	SeqPos_t iResult = 0;
	for (typename TSegs::const_iterator iter = m_lstContainer.begin(); iter != m_lstContainer.end(); ++iter)
	{
		iResult += iter->to - iter->from + 1;
	}
	return iResult/abs(m_iFactor);
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::GetOverall(SEGTYPE &target, SeqPos_t &ori_to) const
{
	if (IsEmpty())
	{
		target.from = target.to = target.ori_from = -1;
	}
	else
	{
		typename TSegs::const_iterator iterFirst = m_lstContainer.begin();
		typename TSegs::const_reverse_iterator iterLast = m_lstContainer.rbegin();
		target.from = iterFirst->from;
		target.ori_from = iterFirst->ori_from;
		target.to = iterLast->to;
		ori_to = iterLast->ori_from + (iterLast->to - iterLast->from) / m_iFactor;
	}
}

template <typename SEGTYPE>
SeqPos_t CSegSetTmpl<SEGTYPE>::GetOriTo(void) const
{
	if (m_lstContainer.empty()) return -1;
	typename TSegs::const_reverse_iterator riter = m_lstContainer.rbegin();
		
	return riter->ori_from + (riter->to - riter->from) / m_iFactor;
}

template <typename SEGTYPE>
SeqPos_t CSegSetTmpl<SEGTYPE>::GetOriTo(typename TSegs::const_iterator citer, SeqPos_t pos) const
{
	//return citer->ori_from + (citer->to - citer->from) / m_iFactor;
	if (pos < 0) pos = citer->to;
	return citer->ori_from + (pos - citer->from) / m_iFactor;
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::GetGaps(CSegSetTmpl &dst) const
{
	dst.Clear();
	
	if (IsEmpty() || (k_SeqLen_Max == m_ulGapThreshold)) return;
	int fac = abs(m_iFactor);
	SeqLen_t gapThreshold = fac * m_ulGapThreshold;
	if (3 == fac && gapThreshold > 2) gapThreshold -= 2;
	
	typename TSegs::const_iterator iter = m_lstContainer.begin(), iter2 = iter, iterEnd = m_lstContainer.end();
	
	++iter2;
	
	while (iterEnd != iter2)
	{
		SeqPos_t f = iter->to + 1, t = iter2->from - 1;
		if (t - f + 1 > (int)gapThreshold)	//consider as gap
			dst.AddSeg(f, t);
			
		++iter;
		++iter2;
	}
}

template <typename SEGTYPE>
void CSegSetTmpl<SEGTYPE>::GetTranslatedPosMap(size_t aaSeqLen, std::vector<TSeg_base::TResiduePos> &dst) const
{
	if (m_iFactor > 0)	//positive, nothing to worry about
	{
		for (typename TSegs::const_iterator iter = m_lstContainer.begin(), iterEnd = m_lstContainer.end(); iter != iterEnd; ++iter)
		{
			for (SeqPos_t c = iter->from, inc = 0; c <= iter->to; c += m_iFactor, ++inc)
			{
				dst.emplace_back(c / m_iFactor, iter->ori_from + inc);
			}
		}
	}
	else
	{
		for (typename TSegs::const_iterator iter = m_lstContainer.begin(), iterEnd = m_lstContainer.end(); iter != iterEnd; ++iter)
		{
			for (SeqPos_t c = iter->to, inc = 0; c > iter->from; c += m_iFactor, ++inc)
			{
				dst.emplace_back(aaSeqLen + c / m_iFactor, iter->ori_from + inc);
			}
		}
	}
}

typedef CSegSetTmpl<TSeg_base> CSegSet;


#endif
