#if !defined(__CDALIGNPROC_BIODATA__)
#define __CDALIGNPROC_BIODATA__

#include "cdalignproc_base.hpp"
#include <objects/seqalign/seqalign__.hpp>
#include <objects/seq/seqlocinfo.hpp>
#include <objects/seq/seq__.hpp>

namespace Dart_GetDomainInfo_FieldIdx
{
	enum _idx: size_t
	{
		acxn = 0,
		sname,
		defl,
		len,
		clid,
		multi,
		title
	};
};


namespace Dart_GetAllDomainInfo_FieldIdx
{
	enum _idx: size_t
	{
		pssmid = 0,
		acxn,
		sname,
		defl,
		len,
		clid,
		multi,
		title
	};
};


namespace Dart_GetAllClusterInfo_FieldIdx
{
	enum _idx: size_t
	{
		clid = 0,
		pssmid,
		rep,
		size
	};
};

enum EFeatureSel
{
	eGeneric = 0,
	eSpecific = 1
};

namespace Dart_GetClusterInfo_FieldIdx
{
	enum _idx: size_t
	{
		pssmid = 0,
		rep,
		size
	};
};


// -- added 7/8/2013, for dart filter
void AlignEValueFilter(ncbi::objects::CSeq_annot::TData::TAlign &aligns, double dEValCutoff = DEF_EVALCUTOFF);

class CNcbiCdAlignProcessor: public CCdAlignProcessor
{
public:
	
	CNcbiCdAlignProcessor(const TDomClusterIndexIfx *dom_src = nullptr): CCdAlignProcessor(dom_src) {} ;
	
	virtual ~CNcbiCdAlignProcessor(void) {};
	
	// -- call when search (live) with a different db
	void ProcessCDAlign(const std::list<ncbi::CRef<ncbi::objects::CSeq_align> > &rAligns, std::vector<TDomSeqAlignment> &dst) const;
	
	// -- must set sequence info first
	void ProcessCDQuery(const std::list<ncbi::CRef<ncbi::objects::CSeq_align> > &rAligns, TDomQuery &dst, std::vector<PssmId_t> *missed = nullptr) const;
	
	//// -- must set sequence info first
	//void ProcessCDQuery2(const std::list<ncbi::CRef<ncbi::objects::CSeq_align> > &rAligns, TDomQuery &dst, std::vector<PssmId_t> *missed = nullptr) const;
	
	// -- these are bioseq and seq-align-set from Blast archive (CBlast4_archive)
	// -- dst is not cleaned! just appending new ones
	// -- TSeqLocInfoVector = vector< TMaskedQueryRegions >
	void ProcessBlastResults(std::list<TDomQuery> &dst, const std::list<ncbi::CRef<ncbi::objects::CSeq_entry> > &qseqs, const ncbi::TSeqLocInfoVector & masks, const std::list< ncbi::CRef< ncbi::objects::CSeq_align > > &aligns, int gcode = 1, std::vector<PssmId_t> *missed = nullptr) const;
	
	
protected:
	// -- add to collection
	virtual PssmId_t x_GetPssmId(const ncbi::objects::CSeq_id &seqid) const;
};



#endif

