#if !defined(__OFFL_CD_ALIGN_PROC__)
#define __OFFL_CD_ALIGN_PROC__

#include "cdalignproc_biodata.hpp"
#if defined(__DB_OFFLINE__)
//#include "objutils.hpp"
#include "compactstore.hpp"
#include "ptrmap.hpp"
#include "biodata_core.hpp"
#else
//#include <NcbiBase/objutils.hpp>
#include <BasicUtils/compactstore.hpp>
#include <BasicUtils/ptrmap.hpp>
#include <DataUtils/biodata_core.hpp>
#endif
#include <objects/blastxml/blastxml__.hpp>

#include <list>

/*****************************************************
*	Blastoutput can have the following information
******************************************************
*	typedef string TProgram;
*	typedef string TVersion;
*	typedef string TReference;
*	typedef string TDb;
*	typedef string TQuery_ID;
*	typedef string TQuery_def;
*	typedef int TQuery_len;
*	typedef string TQuery_seq;
*	typedef CParameters TParam;
*		typedef string TMatrix;
*		typedef double TExpect;
*		typedef double TInclude;
*		typedef int TSc_match;
*		typedef int TSc_mismatch;
*		typedef int TGap_open;
*		typedef int TGap_extend;
*		typedef string TFilter;
*		typedef string TPattern;
*		typedef string TEntrez_query;
*	typedef list< CRef< CIteration > > TIterations;
*	typedef CStatistics TMbstat;
// **************************************************/

struct _TOfflDomQuery: public TDomQuery
{
	_TOfflDomQuery(void):
		TDomQuery(),
		m_strMessage(), m_dimTranslated() {};
	void ParseAlignStrings(const std::string &qseq, const std::string &hseq, SeqPos_t qf, SeqPos_t hf, SeqPos_t start, SeqLen_t n, SeqLen_t qofs, TDomSeqAlignment &dst, READINGFRAME::TFRAMEINDEX rfidx = 0);
	
	std::string m_strMessage;
	std::string m_dimTranslated[READINGFRAME::TOTAL_RFS];
	// -- internals
	void NACommit(void);
	void PRCommit(void);
};





class COfflCdAlignProcessor: public CNcbiCdAlignProcessor
{
public:
	static constexpr const SeqPos_t COORDSBASE = 1;
	COfflCdAlignProcessor(const TDomClusterIndexIfx *dom_src) : CNcbiCdAlignProcessor(dom_src) {};
	void ParseBlastOutput(_TOfflDomQuery &dst, const ncbi::objects::CIteration &blastout, std::vector<PssmId_t> &missed, double evcut = 0.01) const;
	
	
	// -- for offline utilize, bioseq are assumed to be raw sequence that contains actual seqdata
	void ParseBlastArchive(std::list<_TOfflDomQuery> &dst, const ncbi::objects::CBioseq_set &qseqs, const ncbi::objects::CSeq_align_set &align, double evcut = 0.01) const;
};




#endif
