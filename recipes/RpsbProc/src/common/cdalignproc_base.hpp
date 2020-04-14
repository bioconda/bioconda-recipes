#if !defined(__CDALIGNPROC_BASE__)
#define __CDALIGNPROC_BASE__

#if defined(__DB_OFFLINE__)
#include "basedata.hpp"
#include "envdef.hpp"
#else
#include <DataUtils/basedata.hpp>
#include <NcbiBase/envdef.hpp>
#endif
#if defined(_MT)
#include <corelib/ncbimtx.hpp>
#endif
#include <map>
#include <array>

constexpr const char ARCH_STRING_DELIM = ' ';
constexpr const char * NODOMPROT = "Protein with no known domain";




struct TDomSrcCount
{
	enum ESrcIdx
	{
		eCDD,
		ePFam,
		eTIGRFam,
		eCOG,
		eKOG,
		eSMART,
		ePRK,
		TOTALSRCS
	};
	//static const size_t TOTALSRCS = ePRK + 1;
	constexpr static const size_t TOTALSIGS = 12;
	
	typedef std::array<const char * , TOTALSIGS > TDOMSIGARRAY;
	typedef std::array<int, TOTALSRCS> TSOURCEMAXCOUNTARRAY;
	
	
	static TDOMSIGARRAY DOMSRCSIGS;
	static TSOURCEMAXCOUNTARRAY MAXCOUNTS;
	static ESrcIdx DomAccType(const std::string &acxn);
	// -- return true: counted. false: src already full, so not counted
	
	bool CountSrc(const std::string &acxn);
	
	TDomSrcCount(const int * mcounts = nullptr, size_t nums = 0);
	
	
private:	
	std::map<ESrcIdx, int> m_SrcCounter;
	TSOURCEMAXCOUNTARRAY m_max_counts;
};
// -- base class
class CCdAlignProcessor
{
public:
	// -- sorting facilities
	struct TDomAlignFacility
	{
		TDomSeqAlignment *pAlign;
		size_t ulIdx;
		
		// -- added 12/03/2013 for sorting modification
		const TDomain *pCdInfo;
		size_t ulGapsIdx;
		
		
		TDomAlignFacility(void): pAlign(nullptr), ulIdx(0), pCdInfo(nullptr), ulGapsIdx(std::string::npos) {};
	};
	
	struct TDomAlignOrderByEValue
	{
		bool operator () (const TDomAlignFacility &p1, const TDomAlignFacility &p2)
		{
			if (p1.pAlign->m_dEValue < p2.pAlign->m_dEValue) return true;
			else if (p1.pAlign->m_dEValue > p2.pAlign->m_dEValue) return false;
			else return (p1.pAlign->m_dBitScore > p2.pAlign->m_dBitScore);
		}
	};
	
	// -- return seuqence length, for convenience
	static SeqLen_t SortReadingFrames(std::vector<size_t> rfIndice[READINGFRAME::TOTAL_RFS], const TDomQuery &rSrc);
	
	CCdAlignProcessor(const TDomClusterIndexIfx *dom_src = nullptr): m_mtxDomClusterIdx(), m_pDomSrc(dom_src) {} ;
	
	
	virtual ~CCdAlignProcessor(void) {};
	
	inline
	const TDomClusterIndexIfx * GetMap(void) const {return m_pDomSrc;}
	
	
	//virtual const TDomain* FindCdInfo(unsigned int pssmid) const = 0;
	//virtual const TShluClusterInfo* FindClusterInfo(int clusterid) const = 0;
	
	
	// -- just a public interface for calculation
	//void Calculate(TShluCdQuery &rTarget, std::map<unsigned int, TDomain> &missed) const;
	
	// -- two set of calculated std::vector<TDomSeqAlignment> merged together, recalculate the four index sets. 
	// -- TDomSeqAlignment fields are assumed to be calculated/filled already so no need to calculate again
	// -- only need to calculate m_bRep and m_iRegionIdx
	//void MergeCalc(std::vector<TDomSeqAlignment> &aligns, TShluAlignIndice &dst, std::map<unsigned int, TDomain> &missed) const;
	//void MergeCalc(std::vector<TDomSeqAlignment> &aligns, const std::vector<size_t> &selIdx, TShluAlignIndice &dst, std::map<unsigned int, TDomain> &missed) const;
	void Calculate(std::vector<TDomSeqAlignment> &aligns, const std::vector<size_t> &selIdx, TDomSeqAlignIndex &dst, std::vector<PssmId_t> &missed, const int * stdmax = nullptr, size_t nmax = 0) const;
	void Calculate(std::vector<TDomSeqAlignment> &aligns, TDomSeqAlignIndex &dst, std::vector<PssmId_t> &missed, const int * stdmax = nullptr, size_t nmax = 0) const;
		
	
	// -- two set of calculated std::vector<TShluCdAlignInfo> merged together, recalculate the four index sets. 
	// -- TDomSeqAlignment fields are assumed to be calculated/filled already so no need to calculate again
	// -- only need to calculate m_bRep and m_iRegionIdx
	// -- and by the time to call MergeCalc, all missed pssmid should be there.
	void MergeCalc(std::vector<TDomSeqAlignment> &aligns, const std::vector<size_t> &selIdx, TDomSeqAlignIndex &dst, const int * stdmax = nullptr, size_t nmax = 0) const;
		
	// -- mode: TDataModes::EIndex, rf: readingframe index , 0-5
	
	void ExtractDomains(const TDomQuery &rProcessed, std::vector< const TDomain* > &doms, std::vector< const TCluster* > &fams, int mode, int rfidx = 0) const;
	void ExtractDomains(const std::list<TDomQuery> &rProcessed, std::vector< const TDomain* > &doms, std::vector< const TCluster* > &fams, int mode, int rfidx = 0) const;
	
	//Please make sure pssmids and clstids are non-dup.
	// -- extract doms and their superfamilies
	void ExtractDomains(const std::vector<PssmId_t> &pssmids, std::vector< const TDomain* > &doms, std::vector< const TCluster* > &fams) const;
	void ExtractClusters(const std::vector<ClusterId_t> &clstids, std::vector< const TCluster* > &fams) const;
	
	
protected:
#if defined(_MT)
	mutable ncbi::CRWLock m_mtxDomClusterIdx;
#endif
	const TDomClusterIndexIfx *m_pDomSrc;
	
	// -- get missed pssms. 
	virtual void x_LoadMissingDomains(const std::vector<PssmId_t> &missed) const {};
	// -- added missed pssmid collector, for those not in dart but in cdtrack
	
	
	
	
	
	
	
	
	
	
	//void x_Calculate(std::vector<TDomSeqAlignment> &aligns, TShluAlignIndice &dst, std::map<unsigned int, TDomain> &missed) const;
	
	
	// -- take seqid, return pssmid (pseudo or not)
	
	//virtual unsigned int x_CollectDomain(const ncbi::objects::CSeq_id &rCdSeqId, int iFlags) = 0;
	
	
	//static void LoadCuratedClusterInfo(void);
	//static void MergeCuratedClusterInfo(std::map<int, TShluClusterInfo> & tgt);
	//static std::map<int, TCuratedClusterInfo> m_mapCuratedClusterInfo;
};

struct _TArchNameCols
{
	std::string name;
	std::string label;
	std::string nameevds;
	std::string labelevds;
	
	_TArchNameCols(void):
		name(k_strEmptyString), label(k_strEmptyString), nameevds(k_strEmptyString), labelevds(k_strEmptyString) {};
	void clear(void);
};

void CreateSpArchName(const TDomClusterIndexIfx &domInfo, const TDomSeqAlignIndex &indice, const std::vector<TDomSeqAlignment> &aligns, _TArchNameCols &cols, std::string &remark);


void CreateArchStrings(const TDomClusterIndexIfx &domInfo, const std::vector<size_t> &conciseIdx, const std::vector<TDomSeqAlignment> &aligns, std::string &archStr, std::string &spArchStr);



#endif
