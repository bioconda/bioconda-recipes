#if !defined(__BIODATA_CORE__)
#define __BIODATA_CORE__
#include "basedata.hpp"
#if defined(__DB_OFFLINE__)
#include "objutils.hpp"
#else
#include <NcbiBase/objutils.hpp>
#endif
#include <objects/seq/seq__.hpp>
#include <objects/seqloc/seqloc__.hpp>


constexpr const char * k_lpszBlastDefLocalId = "local";
constexpr const size_t k_BlastLocalIdSize = 5;
//constexpr const size_t k_BlastLocalIdSize = strlen(k_lpszBlastDefLocalId);	//not working for visual studio

constexpr const char * k_lpszConsensusId = "$consensus";
constexpr const char * k_lpszQueryId = "$query";



// -- seq-id utilities
ncbi::CRef<ncbi::objects::CSeq_id> CreateMD5SeqId(const std::string &seqdata);
bool IsMD5SeqId(const ncbi::objects::CObject_id &lclid);
// -- must guarantee the seqid is a "unique MD5 seqid".
std::string ExtractMD5FromMD5SeqId(const ncbi::objects::CSeq_id& seqid);
// -- pack up all ids in dst. return if MD5 local id string, if exists. otherwise 0
void PackSeqIds(const ncbi::objects::CBioseq::TId &ids, std::string &dst);
void UnpackSeqIds(const std::string &packed, ncbi::objects::CBioseq::TId &ids);
std::string GetAccessionFromSeqId(const ncbi::objects::CSeq_id& seqid);

// -- caller must make sure  dimAaData has at least 6 elements
void TranslateAll(const std::string &NASeq, int gcode, std::string dimAaData[]);
bool IsProtein(const ncbi::objects::CSeq_inst& rSeqInst);
// -- return 0: protein
// -- return 1: na
// -- -1: should not happen
int SeqDataTo1LtrSeq(const ncbi::objects::CSeq_data &rSeqData, std::string &dst);
std::string Get1LetterSeqData(const ncbi::objects::CSeq_inst& rSeqInst);
// -- bioseq parsers
GI_t GetGiFromBioseq(const ncbi::objects::CBioseq& rBioseq);
std::string GetBestAccFromBioseq(const ncbi::objects::CBioseq& rBioseq);

SeqLen_t GetSeqLengthFromBioseq(const ncbi::objects::CSeq_inst& rSeqInst);
const std::string& GetDescrTitleFromBioseq(const ncbi::objects::CBioseq& rBioseq);
std::string GetEaaData(const ncbi::objects::CBioseq& rBioseq);
std::string GetFastaDeflineFromBioseq(const ncbi::objects::CBioseq& rBioseq);
std::string GetFirstDescrTitleFromBioseq(const ncbi::objects::CBioseq& rBioseq);
std::string GetMatchTitleFromBioseq(const ncbi::objects::CBioseq& rBioseq, const std::string& rPattern);
void AddAutoMD5SeqIdToBioseq(ncbi::objects::CBioseq& rBioseq);
ncbi::CRef<ncbi::objects::CSeq_id> ObtainAutoMD5SeqIdFromBioseq(const ncbi::objects::CBioseq &bioseq);
int IsLocalSequence(const ncbi::objects::CBioseq& rBioseq);	//see if has local id
void ObtainUserDeflineFromBioseq(const ncbi::objects::CBioseq &bioseq, std::string &dst);

// -- seq-annot related
void TruncateDeflineInSeqAnnot(ncbi::objects::CSeq_annot& rTarget, size_t uiCutOff = 255);
void RemoveIncompleteFeaturesInSeqAnnot(ncbi::objects::CSeq_annot& rTarget, double dCompletenessCutOff = 0.5);

void PaulAlignReplaceQueryLocal(std::string &rPaulOutput, const std::string &rAutoId, const std::string &rLocalId);
void PaulAlignRemoveStatus(std::string &rPaulOutput);
	
constexpr const char * k_lpszCdSearchAnnotTag = "CDDSearch";
ncbi::CRef<ncbi::objects::CSeq_annot> __CreateTaggedSeqAnnot(const char * const pTag = k_lpszCdSearchAnnotTag, const char * pVersion = nullptr);


void FillDomainFromBioseq(const ncbi::objects::CBioseq &rConsensus, TDomain &dst);
void FillSegSetFromSeqLoc(const ncbi::objects::CSeq_loc & rSeqLoc, CSegSet &d);

void FillSequenceFromBioseq(const ncbi::objects::CBioseq &bioseq, TSequence &dst);
ncbi::CRef<ncbi::objects::CBioseq> CreateBioseqFromSequence(const TSequence &dst);
void FillPdbIdFromPdbSeqId(const ncbi::objects::CPDB_seq_id &pdbseqid, CPdbId &dst);

ncbi::CRef<ncbi::objects::CSeq_id> ConstructPdbSeqId(const CPdbId &dst);

void SetSeqLocMixFromSegSet(const CSegSet &sset, const ncbi::objects::CSeq_id& rUseId, ncbi::objects::CSeq_loc_mix& container);




#endif
