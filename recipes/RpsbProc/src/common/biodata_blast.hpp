#if !defined(__BIODATA_BLAST__)
#define __BIODATA_BLAST__
#include "biodata_core.hpp"
#include <algo/segmask/segmask.hpp>
#include <objects/blast/Blast4_mask.hpp>
#include <objects/seq/seqlocinfo.hpp>
#include <objects/seqalign/seqalign__.hpp>
#include <list>

// -- defined in objects/seqloc/Na_strand.hpp
//enum ENa_strand NCBI_PACKED_ENUM_TYPE( unsigned char )
//{
//	eNa_strand_unknown  =   0,
//	eNa_strand_plus     =   1,
//	eNa_strand_minus    =   2,
//	eNa_strand_both     =   3,  ///< in forward orientation
//	eNa_strand_both_rev =   4,  ///< in reverse orientation
//	eNa_strand_other    = 255
//} NCBI_PACKED_ENUM_END();

typedef std::list< ncbi::CRef< ncbi::objects::CBlast4_mask > > TBlast4MaskList;

//struct TBlastParams
//{
//	double m_eval_cutoff;
//	bool m_lc_filter;
//	bool m_composition_adjust;
//	int m_max_hits;
//	std::string m_db;	//database used in search
//	char m_db_type;	//'p' or 'n'
//	
//	TBlastParams(void):
//		m_eval_cutoff
//};


// -- return true as processed, false otherwise
ncbi::CRef<ncbi::objects::CSeq_id> ParseAlignSegs(const ncbi::objects::CSeq_align::TSegs &c_segs, TSeqAlignment &dst);

void ParseAlignScores(const ncbi::objects::CSeq_align &align, TSeqAlignment &dst);


void ConvertBlastMaskListToSeqLocInfoVector(const TBlast4MaskList &bmlist, ncbi::TSeqLocInfoVector &dst);

//-- may throw, please try...catch
//void CalculateBiasedRegions(const ncbi::objects::CBioseq& bioseq, std::vector<TSequence::__SegMask> &dst);

#endif



