#include <ncbi_pch.hpp>
#include "basedata.hpp"
#include "prosite.hpp"

#if defined(__DB_OFFLINE__)
#include "basealgo.hpp"
#else
#include <BasicUtils/basealgo.hpp>
#endif
#include <sstream>

using namespace LJSON;
using namespace std;

// -- definition of reading frame match
//enum EBlast4_frame_type {
//    eBlast4_frame_type_notset = 0,
//    eBlast4_frame_type_plus1  = 1,
//    eBlast4_frame_type_plus2  = 2,
//    eBlast4_frame_type_plus3  = 3,
//    eBlast4_frame_type_minus1 = 4,
//    eBlast4_frame_type_minus2 = 5,
//    eBlast4_frame_type_minus3 = 6
//};
// -- objects/blast/Blast4_frame_type_.hpp
const char * READINGFRAME::RF_TITLES[] = {"RF +1", "RF +2", "RF +3", "RF -1", "RF -2", "RF -3"};
READINGFRAME::TFRAMEID READINGFRAME::RF_IDS[] = {1, 2, 3, -1, -2, -3};
	
READINGFRAME::TFRAMEINDEX READINGFRAME::Id2Idx(READINGFRAME::TFRAMEID id) noexcept
{
	if (id == 0 || id < -3 || id > 3)
		return 0;	//invalid id always return 0, the first, as protein uses it
	return (id < 0 ? READINGFRAME::RF_SIZE - id - 1 : id - 1);
}

READINGFRAME::TFRAMEID READINGFRAME::Idx2Id(READINGFRAME::TFRAMEINDEX idx) noexcept
{
	if (idx >= READINGFRAME::TOTAL_RFS)
		return 0;
	return READINGFRAME::RF_IDS[idx];
}


const char * READINGFRAME::Idx2Title(READINGFRAME::TFRAMEINDEX idx) noexcept
{
	if (idx >= READINGFRAME::TOTAL_RFS)
		return nullptr;
	return READINGFRAME::RF_TITLES[idx];
}

const char * READINGFRAME::Id2Title(READINGFRAME::TFRAMEID id) noexcept
{
	return READINGFRAME::Idx2Title(READINGFRAME::Id2Idx(id));
}




//SeqPos_t READINGFRAME::NA2Pr(SeqPos_t napos, int rf, SeqLen_t na_len)
//{
//	if (rf > 0)
//	{
//		// -- plus
//		if (rf > 3)
//			return napos;
//		return napos / READINGFRAME::RF_SIZE;
//	}
//	else if (rf < 0)
//	{
//		if (rf < -3)
//			return napos;
//		return (na_len - napos - 1) / READINGFRAME::RF_SIZE;
//	}
//	// -- rf = 0;
//	return napos;
//	
//}
//
//SeqPos_t READINGFRAME::Pr2NA(SeqPos_t prpos, int rf, SeqLen_t pr_len)
//{
//	if (rf > 0)
//	{
//		// -- plus
//		if (rf > 3)
//			return prpos;
//		return prpos * READINGFRAME::RF_SIZE + rf - 1;
//	}
//	else if (rf < 0)
//	{
//		// -- minus
//		if (rf < -3)
//			return prpos;
//		return (pr_len - prpos - 1) * READINGFRAME::RF_SIZE - rf - 1;
//	}
//	// -- rf = 0;
//	return prpos;
//	
//}
	

const char * TDataModes::dimLits[] = {"rep", "std", "full"};
const char * TDataModes::dimDisplay[] = {"Concise", "Standard", "Full"};
const char * TDataModes::TDataModes::e_std_alias = "all";
const char * TSearchModes::dimLits[] = {"prec", "live"};
const char * TTargetData::dimLits[] = {"doms", "feats", "both"};
const char * TTargetData::dimDisplay[] = {"Domain hits", "Site annotations", "Domain hits and site annotations"};
// -- added 5/11/2011 -- for blast use -- dart result string
const char * TDartStatus::dimLits[] = 
{
	"no_connection",
	"unknown_id",
	"data_not_ready",
	"no_hits_found",
	"",
	"",
	"error",
	"unqualified"
};


const char* TPublicDBs::dimLits[] = {"cdd", "cdd_ncbi", "oasis_pfam", "oasis_smart", "oasis_kog", "oasis_cog", "oasis_prk", "oasis_tigr"};
const char* TPublicDBs::dimDispNames[] = {"CDD", "NCBI_Curated", "Pfam", "SMART", "KOG", "COG", "PRK", "TIGR"};

string TPublicDBs::GetFilterString(void)
{
	char dimDelimit[2] = {0, 0};
	string result(k_strEmptyString);
	result.reserve(128);
	for (int i = 0; i < eEnumStop - eEnumStart; ++i)
	{
		result.append(dimDelimit);
		result.append(dimLits[i]);
		dimDelimit[0] = '|';
	}
	return result;
}








CPdbId::CPdbId(void):
	m_usedelim(CPdbId::DELIM_CHAR)
	
{
	Reset();
}

CPdbId::CPdbId(const std::string &acxn):
	m_usedelim(CPdbId::DELIM_CHAR)
{
	Reset();
	ParsePdbAcxn(acxn);
	//if (!ParsePdbAcxn(acxn))
	//	THROW_SIMPLE("Invalid Pdb ID string " << acxn);
}

bool CPdbId::IsValid(void) const
{
	return m_mol[0];
}


CPdbId::operator string(void) const
{
	
	if (!m_mol[0])
		return k_strEmptyString;
	
	string s(m_mol);
	if (m_chain[0])
	{
		if (m_usedelim) s.push_back(m_usedelim);
		s.append(m_chain);
	}
	
	return s;
}

bool CPdbId::x_SetAcxn(const char * acxn, size_t len)
{
	if (len >= CPdbId::PDBMOL_LEN)
	{
		size_t ch_idx = 0;
		int midx = 0;
		if (!isdigit(acxn[ch_idx]))
			goto labelFalse;	//first must be digit
		m_mol[midx++] = acxn[ch_idx++];
		while (ch_idx < PDBMOL_LEN)
		{
			char c = acxn[ch_idx++];
			if (c < '0')
				goto labelFalse;
			else if (c <= '9')
				m_mol[midx] = c;
			else if (c < 'A')	//bad
				goto labelFalse;
			else if (c <= 'Z')
				m_mol[midx] = c;
			else if (c < 'a')
				goto labelFalse;
			else if (c <= 'z')
				m_mol[midx] = c - 0x20;	//to upper
			else
				goto labelFalse;
			
			++midx;
		}
		m_mol[midx] = 0;
		midx = 0;
		if (len > ch_idx)	//has chain
		{
			if (!isalnum(acxn[ch_idx]))
				++ch_idx;
			
			size_t chn_len = len - ch_idx;
			if (chn_len > PDBCHN_MAX_LEN)
				chn_len = PDBCHN_MAX_LEN;
#if !defined(_STRUCTURE_USE_LONG_PDB_CHAINS_)
			if (2 == chn_len && isupper(acxn[ch_idx]) && acxn[ch_idx] == acxn[ch_idx + 1])
				m_chain[midx++] = (char)tolower(acxn[ch_idx]);
			else
			{
#endif
				while (ch_idx < len)
				{
					char c = acxn[ch_idx++];
					if (!isalnum(c))
						goto labelFalse;
					m_chain[midx++] = c;
				}
#if !defined(_STRUCTURE_USE_LONG_PDB_CHAINS_)
			}
#endif
		}
		m_chain[midx] = 0;
		
		// -- copy
		return true;
	}
	
labelFalse:
	Reset();
	return false;
}

bool CPdbId::ParsePdbAcxn(const string & acxn)
{
	return x_SetAcxn(acxn.c_str(), acxn.size());
}

bool CPdbId::ParsePdbAcxn(const char * acxn)
{
	return x_SetAcxn(acxn, strlen(acxn));
}


void CPdbId::Reset(void)
{
	memset(m_mol, 0, (PDBMOL_LEN + 1) * sizeof(char));
	memset(m_chain, 0, (PDBCHN_MAX_LEN + 1) * sizeof(char));
}


void TDocsum::Reset(void)
{
	m_iGi = 0;
	m_strAccession.clear();
	m_strNcbiId.clear();
	m_uiSeqLen = 0;
	m_strTitle.clear();
	//m_iMolType = CSeq_inst::eMol_not_set;
	m_bIsNa = false;
	m_iTaxId = 0;
	m_iGenCode = 1;
	m_iMGenCode = 2;	//mitochondrial genetic code
	m_strSciName.clear();	//scientific name
	m_strBlastName.clear();	//blast name
	m_strCommonName.clear();	//common name
}

JSVar TDocsum::CreateJson(void) const
{
	JSVar dsjson(eObject);
	if (m_iGi > 0)
		dsjson[_PROP_GI] = m_iGi;
	dsjson[_PROP_ACC] = m_strAccession;
	dsjson[_PROP_SZ] = m_uiSeqLen;
	dsjson[_PROP_DEFLINE] = m_strTitle;
	dsjson[_PROP_TAXID] = m_iTaxId;
	dsjson[_PROP_SEQTYPE] = (m_bIsNa ? "na" : "aa");
	return dsjson;
}

void TSequence::Reset(void)
{
	TDocsum::Reset();
	m_iInputType = 0;	//CCleanInput::EStringDataType values
	m_strCleanedInput.clear();	//also from CCleanInput
	m_strSeqData.clear();	//1-letter seqdata
	m_Src.clear();
	m_B64PackedIds.clear();
	m_iValid = e_Invalid;
	m_iStatus = 0;	//misc status for compatibility, previous field name is m_iOid
	m_iPig = 0;	//if has one. otherwise 0
	// -- added 2012/4/12 -- for range. m_iStart is default to 0, m_iEnd is default to -1, meaning whole length.
	m_iFrom = 0;
	m_iTo = -1;

	m_vecMaskedRegions.clear();
}

JSVar TSequence::CreateJson(void) const
{
	JSVar seqjson = TDocsum::CreateJson();
	seqjson[_PROP_VALID] = m_iValid;
	//aSeq[_PROP_STATUS] = pSeq->m_iStatus;
	if (m_iPig > 0)
		seqjson[_PROP_PIG] = m_iPig;
	
	if (m_iFrom > 0 || m_iTo >= 0)
	{
		seqjson[_PROP_FROM] = m_iFrom;
		seqjson[_PROP_TO] = m_iTo < 0 ? m_uiSeqLen - 1 : m_iTo;
	}
	
	
	
	seqjson[_PROP_SEQDATA] = m_strSeqData;
	
	// -- mask regions
	if (!m_vecMaskedRegions.empty())
	{
		JSVar masked(eArray);
		for (const auto &v : m_vecMaskedRegions)
		{
			JSVar mreg(eObject);
			mreg[_PROP_FROM] = v.from;
			mreg[_PROP_TO] = v.to;
			mreg[_PROP_RFID] = v.rf;
			masked.push(mreg);
		}
		seqjson[_PROP_MASKED] = masked;
		
	}
	return seqjson;
}



const char * TDomSite::GENERIC_SITE_TITLE = "active site";
const char * TDomSite::FEATTYPES[] = {"other", "active site", "polypeptide binding site", "nucleotide binding site", "ion binding site", "chemical binding site", "posttranslational modification", "structural motif"};
	
map<int, string> TDomSite::m_stFeatTypes;

const char * TDomSite::GetFeatType(int idx)
{
	if (!TDomSite::m_stFeatTypes.empty())
	{
		map<int, string> :: const_iterator iter = TDomSite::m_stFeatTypes.find(idx);
		if (TDomSite::m_stFeatTypes.end() != iter)
			return iter->second.c_str();
	}
	
	if (idx >= 0 && idx < TOTAL_OFFL_TYPES)
		return FEATTYPES[idx];
	return GENERIC_SITE_TITLE;
}

JSVar TDomSite::CreateLocs(const CSegSet &segset)
{
	JSVar mapArrays(eObject), coords(eArray), oriCoords(eArray);
	mapArrays[_PROP_COORDS] = coords;
	mapArrays[_PROP_ORICOORDS] = oriCoords;
	const CSegSet::TSegs &segs = segset.GetSegs();
	
	for (CSegSet::TSegs::const_iterator iter = segs.begin(), iterEnd = segs.end(); iterEnd != iter; ++iter)
	{

		for (SeqPos_t i = iter->from; i <= iter->to; ++i)
		{
			coords.push(i);
			oriCoords.push(segset.GetOriTo(iter, i));
		}
	}
	return mapArrays;
}

void TDomSite::GetMotifResPos(vector<SeqPos_t> &dst) const
{
	size_t ttlsegs = m_lstContainer.size();
	vector<TSegs::const_iterator> segs;
	segs.reserve(ttlsegs);
	
	size_t ttlres = 0;
	for (TSegs::const_iterator iter = m_lstContainer.begin(), iterEnd = m_lstContainer.end(); iterEnd != iter; ++iter)
	{
		segs.emplace_back(iter);
		ttlres += iter->to - iter->from + 1;
	}
	
	
	dst.clear();
	dst.reserve(ttlres);
	for (auto v : segs)
		for (SeqPos_t c = v->from; c <= v->to; ++c)
			dst.push_back(c);
}

void TDomSite::Reset(void)
{	
	CSegSet::Clear();
	m_iFactor = 1;
	m_strTitle.clear();
	m_strDescr.clear();
	m_strMotif.clear();
	m_iMotifuse = 0;
	m_iIndex = 0;
	m_iType = 0;
	m_iCompleteSize = 0;
	m_flags = 0;
}

JSVar TDomSite::CreateJson(void) const
{
	JSVar stjson(eObject);
	stjson[_PROP_TITLE] = m_strTitle;
	if (!m_strDescr.empty())
		stjson[_PROP_DESCR] = m_strDescr;
	stjson[_PROP_TYPE] = TDomSite::GetFeatType(m_iType);
	stjson[_PROP_IDX] = m_iIndex;
	
	// -- add plain coordinates
	JSVar coords(eArray);
	const CSegSet::TSegs &segs = GetSegs();
	for (CSegSet::TSegs::const_iterator iter = segs.begin(), iterEnd = segs.end(); iterEnd != iter; ++iter)
		for (SeqPos_t i = iter->from; i <= iter->to; ++i)
			coords.push(i);
	
	stjson[_PROP_COORDS] = coords;
	
	return stjson;
	
}

int TDomSite::MotifCheck(const vector<TSeg_base::TResiduePos> &rMappedRes, const string &aaSeq) const
{
	static vector<SeqPos_t> st_motif_pos;
	
	if (!m_strMotif.empty())
	{
		if (st_motif_pos.empty())
			GetMotifResPos(st_motif_pos);
		
		//vector<TSeg_base::TResiduePos> vecOriPoses;
		//GetTranslatedPosMap(seqLen, vecOriPoses);

		CProSite ps;
		size_t errPos;
		CProSite::EParseError err = ps.Parse(m_strMotif, errPos);
		if (CProSite::eNoError != err)
		{
			THROW_SIMPLE("Motif string parse error -- Motif = " << m_strMotif << ", error position: " << errPos);
			
			
			//stringstream ss;
			//ss << "Motif string parse error -- Motif = " << m_strMotif << ", error position: " << errPos;
			//throw CSimpleException(__FILE__, __LINE__, ss.str());
		}
		string minMap(k_strEmptyString);
		ps.GetMinimalXMap(minMap);
		
		size_t mtfIdx = 0, mtfLen = minMap.size();
		size_t mapIdx = 0, mappedLen = rMappedRes.size();
//		assert(mtfLen == vecOriPoses.size());
		
		while (mtfIdx < mtfLen)
		{
			while (mapIdx < mappedLen)
			{
				if (rMappedRes[mapIdx].ori > st_motif_pos[mtfIdx])	//failed
					return 1;
				else if (rMappedRes[mapIdx].ori == st_motif_pos[mtfIdx])
				{
					++mapIdx;
					goto labelContinue;
				}
				++mapIdx;
					
			}
			// -- exhausted, fail
			return 1;
		labelContinue:
			++mtfIdx;
		}
		
		size_t seqLen = aaSeq.size();
		if (!aaSeq.empty())
		{
			minMap.clear();	//borrow this for other use
			
			for (size_t i = 0; i < mappedLen; ++i)
				if ((size_t)rMappedRes[i].curr < seqLen)
				{
					minMap.push_back(aaSeq[rMappedRes[i].curr]);
				}

			size_t endPos = ps.Match(minMap, seqLen, 0);
			if (string::npos == endPos)
			{
				return 2;
			}
		}
	}

	return 0;
}

bool DomAcxnSig(const string &acxn, const char * sig)
{
	size_t pos = acxn.find(':');
	if (string::npos == pos) pos = 0;
	else ++pos;

	return 0 == acxn.compare(pos, strlen(sig), sig);
}

TCluster::TCluster(void):
	m_uiPssmId(0), m_uiLength(0), m_iClusterId(INVALIDCLUSTERID), m_strAccession(k_strEmptyString), m_strShortName(k_strEmptyString), m_strTitle(k_strEmptyString), m_strDefline(k_strEmptyString)
{}

void TCluster::Reset(void)
{
	m_uiPssmId = 0;
	m_uiLength = 0;
	m_iClusterId = INVALIDCLUSTERID;
	m_strAccession.clear();
	m_strShortName.clear();
	m_strTitle.clear();
	m_strDefline.clear();
}

const char*  TCluster::ConstructClusterAccession(char *buf) const
{
	static char stbuf[16];	//just for safety
	if (nullptr == buf)
		buf=stbuf;
	sprintf(buf, "cl%05d", m_iClusterId);
	return buf;
}



JSVar TCluster::CreateJson(void) const
{
	JSVar clstjson(eObject);
	clstjson[_PROP_PSSMID] = m_uiPssmId;
	string ttl(m_strTitle);
	if (ttl.empty())
		GetShortDomainDefline(m_strDefline, ttl);
	clstjson[_PROP_SNAME] = m_strShortName;
	clstjson[_PROP_TITLE] = ttl;
	clstjson[_PROP_DEFLINE] = m_strDefline;
	clstjson[_PROP_SZ] = m_uiLength;
	clstjson[_PROP_PSSMID] = m_uiPssmId;
	clstjson[_PROP_CLID] = m_iClusterId;
	clstjson[_PROP_ACC] = m_strAccession;
	return clstjson;
}



TDomain::TDomain(void):
	TCluster(), m_uiHierarchyRoot(0), m_uiHierarchyParent(0), m_uiClusterPssmId(0),
	m_dMinBitScore(0.0), m_bCurated(false), m_bIsStructDom(false), m_bMultiDom(false),
	m_strConsensus(), m_strSource(),
	m_lstSpecificFeatures(), m_lstGenericFeatures()
{}

void TDomain::Reset(void)
{
	TCluster::Reset();
	m_uiHierarchyRoot = 0;	//root pssmid
	m_uiHierarchyParent = 0;	//root pssmid
	m_uiClusterPssmId = 0;
	m_dMinBitScore = 0;
	m_bCurated = 0;
	m_bIsStructDom = 0;
	m_bMultiDom = 0;
	m_strConsensus.clear();
	m_strSource.clear();
	m_lstSpecificFeatures.clear();
	m_lstGenericFeatures.clear();
}


JSVar TDomain::CreateJson(void) const
{
	JSVar domjson = TCluster::CreateJson();
	domjson[_PROP_ISNCBI] = m_bCurated;
	domjson[_PROP_ISMULTI] = m_bMultiDom;
	domjson[_PROP_ISSD] = m_bIsStructDom;
	domjson[_PROP_MINBSCORE] = m_dMinBitScore;
	domjson[_PROP_ROOT] = m_uiHierarchyRoot;
	domjson[_PROP_CONSENSUS] = m_strConsensus;
	
	// -- add sites, but no coordinates
	
	if (!m_lstSpecificFeatures.empty())
	{
		JSVar spfeats(eArray);
		for (const auto v : m_lstSpecificFeatures)
			spfeats.push(v.CreateJson());
		
		domjson[_PROP_SPFTS] = spfeats;
	}
	
	if (!m_lstGenericFeatures.empty())
	{
		JSVar genfeats(eArray);
		for (const auto v : m_lstGenericFeatures)
			genfeats.push(v.CreateJson());
		
		domjson[_PROP_GENFTS] = genfeats;
	}
	
	return domjson;
	
}


void CDomClusterIndex::Reset(void)
{
	m_pssmid2cd.Reset();
	m_acxn2cd.Reset();
	m_pssmid2fam.Reset();
	m_clid2fam.Reset();
}

void CDomClusterIndex::InsertDomainIdx(TDomain *p)
{
	bool ins_dummy;
	m_pssmid2cd.Insert(p, ins_dummy);
	m_acxn2cd.Insert(p, ins_dummy);
}
void CDomClusterIndex::InsertClusterIdx(TCluster *p)
{
	bool ins_dummy;
	m_pssmid2fam.Insert(p, ins_dummy);
	m_clid2fam.Insert(p, ins_dummy);
}

void CArchIndex::Reset(void)
{
	m_id2sp.Reset();
	m_str2sp.Reset();
	m_id2fam.Reset();
	m_str2fam.Reset();
}

void CArchIndex::InsertSpArchIdx(TSpDomArch *p)
{
	bool ins_dummy;
	m_id2sp.Insert(p, ins_dummy);
	m_str2sp.Insert(p, ins_dummy);
}
void CArchIndex::InsertFamArchIdx(TDomArch *p)
{
	bool ins_dummy;
	m_id2fam.Insert(p, ins_dummy);
	m_str2fam.Insert(p, ins_dummy);
}

void TDomArch::Reset(void)
{
	m_uiArchId = 0;
	m_strArchString.clear();
	m_strReviewLevel.clear();
}

void TSpDomArch::Reset(void)
{
	TDomArch::Reset();
	m_strName.clear();
	m_strLabel.clear();
	m_uiSupFamArchId = 0;
}

JSVar TDomArch::CreateJson(void) const
{
	JSVar archjson(eObject);
	archjson[_PROP__ID] = m_uiArchId;
	archjson[_PROP_ARCHSTR] = m_strArchString;
	return archjson;
}

JSVar TSpDomArch::CreateJson(void) const
{
	JSVar sparchjson = TDomArch::CreateJson();
	sparchjson[_PROP_NAME] = m_strName;
	sparchjson[_PROP_TITLE] = m_strLabel;
	if (m_uiSupFamArchId > 0)
		sparchjson[_PROP_SFARCHID] = m_uiSupFamArchId;
	
	return sparchjson;
}

/*debug*******************************************************
#if defined(_DEBUG)
void TDomArch::Print(void) const
{
	cout << "m_uiArchId " << m_uiArchId << " ====================================" << endl;
	cout << "m_strArchString = " << m_strArchString << endl;
	cout << "----------------------------------------------------------------" << endl;
}
void TSpDomArch::Print(void) const
{
	TDomArch::Print();
	cout << "m_strName = " << m_strName << endl;
	cout << "m_strLabel = " << m_strLabel << endl;
	cout << "m_uiSupFamArchId = " << m_uiSupFamArchId << endl;
	cout << "===============================================================" << endl;
}
#endif
// ***********************************************************/

void TSeqAlignment::PrintEValue(char *buf, double eval)
{
	if (eval < 1.0e-180) sprintf(buf, "%.0e", eval);
	else if (eval < 0.01) sprintf(buf, "%.2e", eval);
	else if (eval < 1.0) sprintf(buf, "%.2f", eval);
	else if (eval < 10.0) sprintf(buf, "%.1f", eval);
	else sprintf(buf, "%.0f", eval);
}

void TSeqAlignment::PrintBitScore(char *buf, double bscore)
{
	if (bscore < 0.0)
		sprintf(buf, "NA");
	else if (bscore > 9999.0)
		sprintf(buf, "%.2e", bscore);
	else if (bscore > 99.9)
		sprintf(buf, "%.0ld", (long)bscore);
	else
		sprintf(buf, "%.2f", bscore);
}


const char * TSeqAlignment::dimLits[] = {"evalue", "bitscore", "seqidentity", "alignedlen", "scorecombo1"};
const char * TSeqAlignment::dimLabels[] = {"BLAST E-value", "BLAST bit score", "Sequence Identity", "Aligned Length", "Score Combination"};
TSeqAlignment::TSortObj::TSortObj(int iSortIdx):
	m_lpfnCompare(TSeqAlignment::EValueCompare)
{
	switch (iSortIdx)
	{
		case TSeqAlignment::SORT_BY_BITSCORE:
			m_lpfnCompare = TSeqAlignment::BitScoreCompare;
			break;
		case TSeqAlignment::SORT_BY_SEQ_IDENTITY:
			m_lpfnCompare = TSeqAlignment::SeqIdentityCompare;
			break;
		case TSeqAlignment::SORT_BY_ALIGNED_LENGTH:
			m_lpfnCompare = TSeqAlignment::AlignedLengthCompare;
			break;
		case TSeqAlignment::SORT_BY_SCORE_COMBO:
			m_lpfnCompare = TSeqAlignment::ScoreComboEvaluate;
			break;
		default:;
	}
}



void TSeqAlignment::PrintPercentage(char *buf, double pct)
{
	sprintf(buf, "%d%%", (int)(pct + 0.5));
}

void TSeqAlignment::Reset(void)
{
	m_uiAlignedLen = 0;
	m_dAlignedPct = 0.0;
	m_iScore = 0.0;
	m_dEValue = 0.0;
	m_dBitScore = 0;
	m_iNumIdent = 0;
	m_dSeqIdentity = 0.0;
	m_eAlignType = eNormal;
	m_bIsMinus = false;
	m_ReadingFrame = 0;
	m_iFrom = 0;
	m_iTo = 0;
	m_vecMStarts.clear();
	m_vecSStarts.clear();
	m_vecLens.clear();
	m_ClipSet.Clear();
	
}

string TSeqAlignment::GetAlignString(void) const
{
	stringstream oAlignData;
	size_t ulTotalSegs = m_vecLens.size();
	oAlignData << ulTotalSegs;
	for (size_t j = 0; j < ulTotalSegs; ++j)
	{
		oAlignData << "," << m_vecMStarts[j] << "," << m_vecSStarts[j] << "," << m_vecLens[j];
	}
	oAlignData << '\0';
	return oAlignData.str();
}

// -- this should be final step after chain mapping. 
void TSeqAlignment::Pr2NaConvert(CSegSet &segset) const
{
	if (ePr2Na == m_eAlignType)
	{
		//SeqPos_t (*lpfnPr2PlusNA)(SeqPos_t pr, READINGFRAME::TFRAMEINDEX rfidx, SeqLen_t na_len) = nullptr;
		
		SeqLen_t alnLen = (m_ReadingFrame >> 2);
		
		READINGFRAME::TFRAMEINDEX rfidx = m_ReadingFrame & READINGFRAME::RF_SIZE;	//reading frame at positive strand
		segset.m_iFactor = READINGFRAME::RF_SIZE;
		if (alnLen > 0)	//is minus
		{
			// -- alnLen is aligned pr len. Convert to na len
			alnLen = alnLen * READINGFRAME::RF_SIZE + rfidx;
			//rfidx = READINGFRAME::RF_SIZE;	//use alnLen, it's always readingframe -1, ie, rfidx=3
			//lpfnPr2PlusNA = &READINGFRAME::MinusPr2PlusNA;
			for (CSegSet::TSegs::iterator iterSeg = segset.m_lstContainer.begin(); iterSeg != segset.m_lstContainer.end(); ++iterSeg)
			{
				SeqPos_t newFrom = READINGFRAME::MinusPr2PlusNA(iterSeg->from, READINGFRAME::RF_SIZE, alnLen);
				iterSeg->from = READINGFRAME::MinusPr2PlusNA(iterSeg->to, READINGFRAME::RF_SIZE, alnLen) - READINGFRAME::RF_SIZE + 1;
				iterSeg->to = newFrom;
				
				// -- reverse ori_as well
				iterSeg->ori_from += (iterSeg->to - iterSeg->from + 1) / segset.m_iFactor - 1;
				
			}
			segset.m_iFactor = -segset.m_iFactor;	//change direction
			segset.m_lstContainer.reverse();
		}
		else	//plus strand
		{
			for (CSegSet::TSegs::iterator iter = segset.m_lstContainer.begin(); iter != segset.m_lstContainer.end(); ++iter)
			{
				iter->from = READINGFRAME::PlusPr2PlusNA(iter->from, rfidx, 0);
				iter->to = READINGFRAME::PlusPr2PlusNA(iter->to, rfidx, 0) + READINGFRAME::RF_SIZE - 1;
				
			}
		}
	}
}

// -- the key function to track ori_from. 
// -- assume mapping is always from protein to protein
void TSeqAlignment::MapSegSet(CSegSet &segset, bool doConvert) const
{
	if (segset.IsEmpty()) return;

	CSegSet::TSegs::iterator iter = segset.m_lstContainer.begin();
	size_t idx = 0;
	
	while (iter != segset.m_lstContainer.end())
	{
		if (idx >= m_vecLens.size() || m_vecSStarts[idx] > iter->to)	// discard this seg
		{
			CSegSet::TSegs::iterator temp = iter;
			++iter;
			segset.m_lstContainer.erase(temp);
		}
		else
		{
			SeqPos_t diff = m_vecSStarts[idx] - m_vecMStarts[idx];
			SeqPos_t end = m_vecSStarts[idx] + m_vecLens[idx] - 1;
			if (end >= iter->to)	//No trunction from right side
			{
				if (iter->from < m_vecSStarts[idx])	//segment shrinked from left. deal with ori_from
				{
					iter->ori_from += (m_vecSStarts[idx] - iter->from);// / segset.m_iFactor;
					iter->from = m_vecSStarts[idx];
				}
			
				if (end == iter->to)	//seg happens to end at aligned seg
					++idx;	//here is the chance to advance idx
				
				
				// -- mapping
				iter->from -= diff;
				iter->to -= diff;

				++iter;
			}
			else if (end >= iter->from)	//end < iter->to, truncate from right side
			{
				CSegSet::TSeg temp(iter->from, end);
				temp.ori_from = iter->ori_from;
				
				if (temp.from < m_vecSStarts[idx])
				{
					temp.ori_from += (m_vecSStarts[idx] - temp.from);// / segset.m_iFactor;
					temp.from = m_vecSStarts[idx];
				}
				
				// -- mapping
				temp.from -= diff;
				temp.to -= diff;
				segset.m_lstContainer.emplace(iter, temp);
				
				// -- cut original seg for next round
				iter->ori_from += (end - iter->from + 1);// / segset.m_iFactor;
				iter->from = end + 1;
				//iter->ori_from += (iter->from) / segset.m_iFactor;
				++idx;
			}
			else	//end < iter->from, step to next denseg
				++idx;
		}
	}

	// -- check motif
	
	//if (eNa_strand_minus == m_eStrand) StrandConvert(segset);	//possible strand conversion
	// -- if protein to na, convert to na coord
	if (doConvert) Pr2NaConvert(segset);

}
// -- assume: segs contains the mapped segments in Protein coordinates. 
READINGFRAME::TFRAMEINDEX TSeqAlignment::GetTranslatedPosMap(const CSegSet &mappedAAsegs, SeqLen_t qLen, vector<TSeg_base::TResiduePos> &rMappedAAPos) const
{
	rMappedAAPos.clear();
	
	const CSegSet::TSegs &segs = mappedAAsegs.GetSegs();
	size_t ttlres = mappedAAsegs.GetTotalResidues();
	
	rMappedAAPos.reserve(ttlres);
	SeqLen_t aaLen = qLen;	//assume it's aa
	READINGFRAME::TFRAMEINDEX rfidx = m_ReadingFrame & READINGFRAME::RF_SIZE;
	
	if (ePr2Na == m_eAlignType)
	{
		SeqLen_t alignedLen = m_ReadingFrame >> 2;
		aaLen = (qLen - rfidx) / READINGFRAME::RF_SIZE;
		if (alignedLen > 0)	//minus strand
		{
			if (alignedLen > aaLen)	//error
				THROW_SIMPLE("Invalid protein length " << aaLen << ": shorter than aligned range " << alignedLen);
			rfidx = READINGFRAME::PlusRFIdx2MinusRFIdx(rfidx, qLen);
			SeqLen_t offset = aaLen - alignedLen;
/*DEBUG**********************************************/
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": aaLen = " << aaLen << ", alignedLen = " << alignedLen << endl;
#endif
// **************************************************/			
			for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(), iterSegEnd = segs.end(); iterSegEnd != iterSeg; ++iterSeg)
			{
				for (SeqPos_t c = iterSeg->from, inc = 0; c <= iterSeg->to; ++c, ++inc)
				{
					rMappedAAPos.emplace_back(c + offset, iterSeg->ori_from + inc);
				}
			}
			goto labelReturn;
		}
	}
	// -- either protein or plus strand translation, no adjust needed.
	for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(), iterSegEnd = segs.end(); iterSegEnd != iterSeg; ++iterSeg)
	{
		for (SeqPos_t c = iterSeg->from, inc = 0; c <= iterSeg->to; ++c, ++inc)
		{
			rMappedAAPos.emplace_back(c, iterSeg->ori_from + inc);
		}
	}
labelReturn:
	return rfidx;

		
	//// -- old implementation
	//segs.GetTranslatedPosMap(seqLen, rMappedAAPos);
	//if (ePr2Na == m_eAlignType)	//needs translation
	//	return GetRFIdx(seqLen);
	//else
	//	return 0;
}


void TSeqAlignment::CreateSlaveSegs(CSegSet &segset) const
{
	segset.Clear();
	for (size_t i = 0, len = m_vecLens.size(); i < len; ++i)
	{
		segset.AddSeg(m_vecSStarts[i], m_vecSStarts[i] + m_vecLens[i] - 1);
	}
}

void TSeqAlignment::CreateMasterSegs(CSegSet &segset) const
{
	segset.Clear();
	for (size_t i = 0, len = m_vecLens.size(); i < len; ++i)
	{
		segset.AddSeg(m_vecMStarts[i], m_vecMStarts[i] + m_vecLens[i] - 1);
	}
}


void TSeqAlignment::CalcMasterGaps(SeqLen_t gapThreshold, CSegSet &segset) const
{
	segset.Clear();
	if (!m_vecLens.empty())
	{
		size_t segs = m_vecLens.size();
		for (size_t i = 0; i < segs - 1; ++i)
		{
			SeqPos_t gapstart = m_vecMStarts[i] + (SeqPos_t)m_vecLens[i];
			SeqPos_t gaplen = m_vecMStarts[i + 1] - gapstart;
			
			if (gaplen >= (SeqPos_t)gapThreshold)	//consider a gap
				segset.AddSeg(gapstart, gapstart + gaplen - 1);
		}
	}
}

// -- seqLen is the length of query sequence, na or aa.
READINGFRAME::TFRAMEINDEX TSeqAlignment::GetRFIdx(SeqLen_t seqLen) const
{
	if (ePr2Na != m_eAlignType) return 0;
	SeqLen_t alignedLen = m_ReadingFrame >> 2;	//m_ReadingFrame contains the positive side reading frame, always.
	READINGFRAME::TFRAMEINDEX rfidx = m_ReadingFrame & READINGFRAME::RF_SIZE;
	
	if (alignedLen > 0)	//negative -- minus strand
		rfidx = READINGFRAME::PlusRFIdx2MinusRFIdx(rfidx, seqLen);
	return rfidx;
}

//int TSeqAlignment::Na2Pr(int na, int &pr) const
//{
//	int len = m_ReadingFrame >> 2;
//	if (len > 0)	//minus strand
//	{
//		pr = (len - na - 1) / 3;
//		return -3;
//	}
//	pr = na / 3;
//	return 3;
//}
//
//int TSeqAlignment::Pr2Na(int pr, int &na) const
//{
//	int len = m_ReadingFrame >> 2;
//	if (len > 0)
//	{
//		na = len - pr * 3 - (m_ReadingFrame & READINGFRAME::RF_SIZE) - 1;
//		return -1;
//	}
//	na = pr * 3 + (m_ReadingFrame & READINGFRAME::RF_SIZE);
//	return 1;
//}

void TSeqAlignment::AddSegs(LJSON::JSVar &pobj) const
{
	JSVar segs(eArray);
	CSegSet dst;
	CreateSlaveSegs(dst);
	MapSegSet(dst, true);
	
	const CSegSet::TSegs & rSegs = dst.GetSegs();
	for (CSegSet::TSegs::const_iterator iter = rSegs.begin(), iterEnd = rSegs.end(); iterEnd != iter; ++iter)
	{
		JSVar aSeg(eObject);
		aSeg[_PROP_FROM] = iter->from;
		aSeg[_PROP_TO] = iter->to;
		aSeg[_PROP_ORIFROM] = iter->ori_from;
		aSeg[_PROP_ORITO] = dst.GetOriTo(iter);
		segs.push(aSeg);
	}
	pobj[_PROP_SEGS] = segs;
}

JSVar TSeqAlignment::CreateJson(void) const
{
	JSVar alnjson(eObject);
	alnjson[_PROP_EVALUE] = m_dEValue;
	alnjson[_PROP_BITSCORE] = m_dBitScore;
	alnjson[_PROP_ALNSCORE] = m_iScore;
	alnjson[_PROP_ALNPCT] = m_dAlignedPct;
	alnjson[_PROP_ALNNUMID] = m_iNumIdent;
	alnjson[_PROP_ALNIDT] = m_dSeqIdentity;
	
	alnjson[_PROP_ALNLEN] = m_uiAlignedLen;
	//alnjson[_PROP_TRUNC_N] = (iterAlign->pAlign->m_dNMissing > 0.2);
	//alnjson[_PROP_TRUNC_C] = (iterAlign->pAlign->m_dCMissing > 0.2);
	alnjson[_PROP_TYPE] = m_eAlignType;
	if (ePr2Na == m_eAlignType)
	{
		alnjson[_PROP_ALNISMINUS] = m_bIsMinus;
	}
	
	if (m_iFrom != 0 && m_iTo != 0)
	{
		alnjson[_PROP_FROM] = m_iFrom;
		alnjson[_PROP_TO] = m_iTo;
	}
	
	// -- add segs
	AddSegs(alnjson);
	
	return alnjson;
}

//void CleanAlignment(const vector<SeqPos_t> & rSrcStarts, const vector<SeqLen_t> & rSrcLens, vector<SeqPos_t>& rMStarts, vector<SeqPos_t>& rSStarts, vector<SeqLen_t>& rLens)
//{
//	rMStarts.clear();
//	rSStarts.clear();
//	rLens.clear();
//	for (size_t i = 0; i < rSrcLens.size(); ++i)
//	{
//		size_t ii = i + i;
//		if (rSrcStarts[ii] >=0 && rSrcStarts[ii + 1] >= 0)
//		{
//			rMStarts.push_back(rSrcStarts[ii]);
//			rSStarts.push_back(rSrcStarts[ii + 1]);
//			rLens.push_back(rSrcLens[i]);
//		}
//	}
//}



void TDomSeqAlignment::AddSegs(LJSON::JSVar &pobj) const
{
	JSVar segs(eArray), realsegs(eArray);
	
	
	CSegSet dst;
	CreateSlaveSegs(dst);

	MapSegSet(dst, true);

	dst.m_ulGapThreshold = TDomSeqAlignment::GAP_THRESHOLD;
		
	CSegSet gaps;
	dst.GetGaps(gaps);
	

	const CSegSet::TSegs & rSegs = dst.GetSegs(), &rGapSegs = gaps.GetSegs();

	CSegSet::TSegs::const_iterator iter = rSegs.begin(), iterEnd = rSegs.end(), iterGap = rGapSegs.begin(), iterGapEnd = rGapSegs.end();
	CSegSet::TSegs::const_iterator iter0 = iter, iter1 = iter0;
	
	{{
		JSVar aRealSeg(eObject);
		aRealSeg[_PROP_FROM] = iter->from;
		aRealSeg[_PROP_TO] = iter->to;
		aRealSeg[_PROP_ORIFROM] = iter->ori_from;
		aRealSeg[_PROP_ORITO] = dst.GetOriTo(iter);
		realsegs.push(aRealSeg);
	}}
	
	++iter;	//first seg always in
	while (iterEnd != iter)
	{
		JSVar aRealSeg(eObject);
		aRealSeg[_PROP_FROM] = iter->from;
		aRealSeg[_PROP_TO] = iter->to;
		aRealSeg[_PROP_ORIFROM] = iter->ori_from;
		aRealSeg[_PROP_ORITO] = dst.GetOriTo(iter);
		realsegs.push(aRealSeg);
		
		
		if (iterGapEnd != iterGap)
		{
			if (iterGap->to < iter->from)	//gap reached. Push in last segment
			{
				JSVar aSeg(eObject);
				aSeg[_PROP_FROM] = iter0->from;
				aSeg[_PROP_TO] = iter1->to;
				aSeg[_PROP_ORIFROM] = iter0->ori_from;
				aSeg[_PROP_ORITO] = dst.GetOriTo(iter1);
				segs.push(aSeg);
				
				iter0 = iter;
				++iterGap;
			}
		}
		
		iter1 = iter;
		++iter;
	}
	
	// -- last seg
	JSVar aSeg(eObject);
	aSeg[_PROP_FROM] = iter0->from;
	aSeg[_PROP_TO] = iter1->to;
	aSeg[_PROP_ORIFROM] = iter0->ori_from;
	aSeg[_PROP_ORITO] = dst.GetOriTo(iter1);
	segs.push(aSeg);
	
	pobj[_PROP_SEGS] = segs;
	pobj[_PROP_REALSEGS] = realsegs;

}

JSVar TDomSeqAlignment::CreateJson(void) const
{
	JSVar domalnjson = TSeqAlignment::CreateJson();
	domalnjson[_PROP_PSSMID] = m_uiPssmId;
	domalnjson[_PROP_REGION] = m_iRegionIdx;
	
	
	bool isspec = IsSpecific() ;
	
	domalnjson[_PROP_ISSPEC] = isspec;
	domalnjson[_PROP_ISREP] = m_bRep;
	domalnjson[_PROP_TRUNC_N] = (m_dNMissing > 0.2);
	domalnjson[_PROP_TRUNC_C] = (m_dCMissing > 0.2);
	if (m_bLifted)
		domalnjson[_PROP_ISLIFTED] = true;
	if (m_bSuppressed)
		domalnjson[_PROP_ISSUPPRESSED] = true;
	
	return domalnjson;
}


int MapCdFeature(const TDomSite &rFeat, const TDomSeqAlignment &rAlign, SeqLen_t qLen, const string dimAaData[], CSegSet &dst)
{
	dst = rFeat;
	
	if (!rAlign.m_ClipSet.IsEmpty())
		dst.Cross(rAlign.m_ClipSet);

	rAlign.MapSegSet(dst, false);

	vector<TSeg_base::TResiduePos> vecMappedPos;
	int rfidx = rAlign.GetTranslatedPosMap(dst, qLen, vecMappedPos);

	if (rFeat.MotifCheck(vecMappedPos, dimAaData[rfidx]) > 0)
		dst.Clear();
	return rfidx;
}



void TDomSeqAlignIndex::CreateRecordSets(const vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, vector< TDomSeqAlignIndex::__TCdAlignRecord> &rDomAligns, vector<TDomSeqAlignIndex::__TCdAlignRecord> &rFeatAligns, int mode) const
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering TDomSeqAlignIndex::CreateRecordSets" << endl;
#endif
// ***********************************************************/

//	const vector<size_t> &rIndice = bConcise ? m_vecConciseIndice : m_vecSortedIndice;
	rDomAligns.clear();
	rFeatAligns.clear();
	
	size_t featIdx0 = 0;
	size_t amendCount = 0;
	size_t ccsBase = m_vecConciseIndice.size();
	
	if (TDataModes::e_rep == mode)	//all rep
	{

		for (size_t iidx = 0, iidxEnd = m_vecConciseIndice.size(); iidx < iidxEnd; ++iidx)
		{
			__TCdAlignRecord alignRec;
			alignRec.pAlign = &(rAlignments[m_vecConciseIndice[iidx]]);
			alignRec.pCdInfo = rDomInfo.FindCdInfo(alignRec.pAlign->m_uiPssmId);


			if (alignRec.pCdInfo->m_iClusterId > 0) alignRec.pClst = rDomInfo.FindClusterInfo(alignRec.pCdInfo->m_iClusterId);
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": alignRec.pCdInfo->m_iClusterId = " << alignRec.pCdInfo->m_iClusterId << ", alignRec.pClst = " << (void*)(alignRec.pClst);
if (alignRec.pClst) cerr << "m_uiPssmId = " << alignRec.pClst->m_uiPssmId;
cerr << endl;

#endif
// ***********************************************************/
			if (alignRec.pCdInfo->m_uiHierarchyRoot > 0)
			{
				if (alignRec.pCdInfo->m_uiHierarchyRoot == alignRec.pAlign->m_uiPssmId) alignRec.pRootCdInfo = alignRec.pCdInfo;
				else alignRec.pRootCdInfo = rDomInfo.FindCdInfo(alignRec.pCdInfo->m_uiHierarchyRoot);
			}
			alignRec.idx = m_vecConciseIndice[iidx];
			alignRec.idxidx = iidx;

			if (0 == alignRec.pAlign->m_iRepClass && alignRec.pAlign->m_bRep)	//non-multi
			{
				ExtractFeatAligns(alignRec, rAlignments, rDomInfo, rFeatAligns);
				
				size_t featIdx1 = rFeatAligns.size();
		    	
				for (size_t i = featIdx0; i < featIdx1; ++i)
				{
					if (rFeatAligns[i].idx == alignRec.idx)
						rFeatAligns[i].idxidx = alignRec.idxidx;
					else
						rFeatAligns[i].idxidx = iidxEnd + amendCount++;
				}
				
				featIdx0 = featIdx1;
			}
			
			rDomAligns.push_back(alignRec);
		}
	}
	else	//non-concise 
	{
		size_t repIdx = 0;
		
		size_t featIdx0 = 0;
		size_t amendCount = 0;
		
		const vector<size_t> &nonConciseIdx = (TDataModes::e_std == mode ? m_vecStdIndice : m_vecSortedIndice);
		
		for (size_t iidx = 0, iidxEnd = nonConciseIdx.size(); iidx < iidxEnd; ++iidx)
		{
			__TCdAlignRecord alignRec;
			alignRec.pAlign = &(rAlignments[nonConciseIdx[iidx]]);
			alignRec.pCdInfo = rDomInfo.FindCdInfo(alignRec.pAlign->m_uiPssmId);
			if (alignRec.pCdInfo->m_iClusterId > 0) alignRec.pClst = rDomInfo.FindClusterInfo(alignRec.pCdInfo->m_iClusterId);
			if (alignRec.pCdInfo->m_uiHierarchyRoot > 0)
			{
				if (alignRec.pCdInfo->m_uiHierarchyRoot == alignRec.pAlign->m_uiPssmId) alignRec.pRootCdInfo = alignRec.pCdInfo;
				else alignRec.pRootCdInfo = rDomInfo.FindCdInfo(alignRec.pCdInfo->m_uiHierarchyRoot);
			}
			alignRec.idx = nonConciseIdx[iidx];
			alignRec.idxidx = -1;
			if (alignRec.pAlign->m_bRep)
			{
				alignRec.idxidx = repIdx++;
				if (0 == alignRec.pAlign->m_iRepClass)	//non-multi
				{
					ExtractFeatAligns(alignRec, rAlignments, rDomInfo, rFeatAligns);
					size_t featIdx1 = rFeatAligns.size();
		    	
					for (size_t i = featIdx0; i < featIdx1; ++i)
					{
						if (rFeatAligns[i].idx == alignRec.idx)
							rFeatAligns[i].idxidx = alignRec.idxidx;
						else
							rFeatAligns[i].idxidx = ccsBase + amendCount++;
					}
					featIdx0 = featIdx1;
				}
			}
			rDomAligns.push_back(alignRec);
		}
	}

	
	// -- added 9/9/2014 handling structure motifs -- attach to 
	for (size_t iidx = 0, iidxEnd = m_vecSDIndice.size(); iidx < iidxEnd; ++iidx)
	{
		__TCdAlignRecord rec;
		
		rec.idx = m_vecSDIndice[iidx];
		
		rec.pAlign =  &(rAlignments[rec.idx]);
		
		rec.pCdInfo = rDomInfo.FindCdInfo(rec.pAlign->m_uiPssmId);
		
		rec.pClst = nullptr;
		
		rec.pRootCdInfo = nullptr;
		
		rec.idxidx = ccsBase + amendCount++;
		
		rFeatAligns.push_back(rec);
	}
}

void TDomSeqAlignIndex::CreateConciseAmends(const vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, const vector<TDomSeqAlignIndex::__TCdAlignRecord> &rConciseAligns, vector<TDomSeqAlignIndex::__TCdAlignRecord> &rAmendAligns) const
{
	rAmendAligns.clear();
	for (size_t ics = 0, icsend = rConciseAligns.size(); ics < icsend; ++ics)
	{
		const __TCdAlignRecord &csrec = rConciseAligns[ics];
		if (0 == csrec.pAlign->m_iRepClass && !csrec.pCdInfo->m_bCurated)	//monodom non-curated
		{
			__TCdAlignRecord arec;
			
			for (size_t iiamd = 0, iiamdend = m_vecStdIndice.size(); iiamd < iiamdend; ++iiamd)
			{
				arec.pAlign = &(rAlignments[m_vecStdIndice[iiamd]]);
				if (0 == arec.pAlign->m_iRepClass && arec.pAlign->m_iRegionIdx == csrec.pAlign->m_iRegionIdx && arec.pAlign != csrec.pAlign)
				{
					arec.pCdInfo = rDomInfo.FindCdInfo(arec.pAlign->m_uiPssmId);
					if (nullptr != arec.pCdInfo && arec.pCdInfo->m_bCurated)
					{
						if (arec.pAlign->m_bSpecQualified || !csrec.pAlign->m_bSpecQualified)
						{
							arec.pClst = rDomInfo.FindClusterInfo(arec.pCdInfo->m_iClusterId);
							if (arec.pCdInfo->m_uiHierarchyRoot > 0) arec.pRootCdInfo = rDomInfo.FindCdInfo(arec.pCdInfo->m_uiHierarchyRoot);
							rAmendAligns.emplace_back(arec);
							goto labelNextHit;
						}
					}
				}
			}
		}
	labelNextHit:;
	}
}

void TDomSeqAlignIndex :: ExtractFeatAligns(const TDomSeqAlignIndex::__TCdAlignRecord &rRepRec, const vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, vector<TDomSeqAlignIndex::__TCdAlignRecord> &rResult) const
{
	__TCdAlignRecord rec;
	if (rRepRec.pCdInfo->m_iClusterId > 0)	//has cluster, do cluster match
	{
		for (size_t fiidx = 0, fiidxEnd = m_vecQualifiedFeatIndice.size(); fiidx < fiidxEnd; ++fiidx)
		{
			rec.pAlign = &(rAlignments[m_vecQualifiedFeatIndice[fiidx]]);
			// -- check if duplicated
			for (const auto & r : rResult)
			{
				if (r.pAlign == rec.pAlign)
					goto labelSkip1;
			}
					
			
			
			if (rec.pAlign->m_iRegionIdx == rRepRec.pAlign->m_iRegionIdx)	//region match
			{
				rec.pCdInfo = rDomInfo.FindCdInfo(rec.pAlign->m_uiPssmId);
				if (rec.pCdInfo->m_iClusterId == rRepRec.pCdInfo->m_iClusterId)	//matched cluster
				{
					rec.pClst = rRepRec.pClst;
					rec.idx = m_vecQualifiedFeatIndice[fiidx];
					//rec.idxidx = FeatIdx2Iidx(rec.idx);
					if (rec.pCdInfo->m_uiHierarchyRoot > 0)
					{
						if (rec.pCdInfo->m_uiHierarchyRoot == rec.pAlign->m_uiPssmId) rec.pRootCdInfo = rec.pCdInfo;
						else rec.pRootCdInfo = rDomInfo.FindCdInfo(rec.pCdInfo->m_uiHierarchyRoot);
					}
					rResult.push_back(rec);
				}
			}
		labelSkip1:
			;
		}
	}
	else	//no cluster, just match region class -- should not happen
	{
		for (size_t fiidx = 0, fiidxEnd = m_vecQualifiedFeatIndice.size(); fiidx < fiidxEnd; ++fiidx)
		{
			rec.pAlign = &(rAlignments[m_vecQualifiedFeatIndice[fiidx]]);
			
			// -- check if duplicated
			for (const auto & r : rResult)
			{
				if (r.pAlign == rec.pAlign)
					goto labelSkip2;
			}
			if (rec.pAlign->m_iRegionIdx == rRepRec.pAlign->m_iRegionIdx)	//region match
			{
				rec.pCdInfo = rDomInfo.FindCdInfo(rec.pAlign->m_uiPssmId);
				rec.pClst = rDomInfo.FindClusterInfo(rec.pCdInfo->m_iClusterId);
				if (rec.pCdInfo->m_uiHierarchyRoot > 0)
				{
					if (rec.pCdInfo->m_uiHierarchyRoot == rec.pAlign->m_uiPssmId) rec.pRootCdInfo = rec.pCdInfo;
					else rec.pRootCdInfo = rDomInfo.FindCdInfo(rec.pCdInfo->m_uiHierarchyRoot);
				}
				rec.idx = m_vecQualifiedFeatIndice[fiidx];
				//rec.idxidx = FeatIdx2Iidx(rec.idx);
				rResult.push_back(rec);
			}
		labelSkip2:
			;
		}
	}
}


void TSnpData::ConstructTitle(string& rDest) const
{
	rDest = ConstructTitle();
}
string TSnpData::ConstructTitle(void) const
{
	char dimBuf[12];
	sprintf(dimBuf, ":%c%d%c", cOriRes, iMstPos + RESIDUE_DISPLAY_OFFSET, cMutRes);
	return strType + strId + dimBuf;
}

JSVar TSnpData::CreateJson(void) const
{
	return JSVar(ConstructTitle());
}

void ReplaceEntities(string &dst)
{
	size_t strlen = dst.size();
	
	if (strlen < 4) return;
		
	size_t idx0 = dst.find('&');
	
	
	while (string::npos != idx0)
	{
		size_t idx1 = dst.find(';', idx0);
		if (string::npos == idx1)
			break;
		
		if ('#' == dst[idx0 + 1])	//hash number
		{
			unsigned int charCode = 0;
			if ('x' == dst[idx0 + 2] || 'X' == dst[idx0 + 2])
				sscanf(dst.substr(idx0 + 3, idx1 - idx0 - 2).c_str(), "%x", &charCode);
			else
				sscanf(dst.substr(idx0 + 2, idx1 - idx0 - 1).c_str(), "%u", &charCode);
				
			if (charCode >= 0x20 && charCode < 127)
				dst.replace(idx0, idx1 - idx0 + 1, 1, char(charCode));
			else
				dst.replace(idx0, idx1 - idx0 + 1, 1, '_');
		}
		else
		{
			string entname = dst.substr(idx0 + 1, idx1 - idx0 - 1);
			if (entname == "apos")
				dst.replace(idx0, idx1 - idx0 + 1, 1, '\'');
			else if (entname == "lt")
				dst.replace(idx0, idx1 - idx0 + 1, 1, '<');
			else if (entname == "gt")
				dst.replace(idx0, idx1 - idx0 + 1, 1, '>');
			else if (entname == "quot")
				dst.replace(idx0, idx1 - idx0 + 1, 1, '"');
			else if (idx1 - idx0 < 9)	//unknown entity, use _
				dst.replace(idx0, idx1 - idx0 + 1, 1, '_');	
		}
		
		// -- next
		strlen = dst.size();
		idx0 = dst.find('&', idx0 + 1);
	}
}

void GetShortDomainDefline(const string &ori, string &dst)
{
	
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering GetShortDomainDefline, ori = " << endl;
cerr << ori << endl;
#endif
// ***********************************************************/

	vector<size_t> dps;	//delimit positions
	size_t start_pos = 0, len = ori.size();	//usually this
	
	size_t last_pos = start_pos, pos = ori.find(':', last_pos);
	
	if (string::npos != pos && pos - last_pos <= 10) 	//get rid of short name prefix
	{
		start_pos = pos + 1;
		last_pos = start_pos;
	}
	
	
	while (start_pos < len)
	{
		if (isalnum(ori[start_pos]))	//must start with alphanumeric
			break;
		++start_pos;
	}
	
	dps.reserve(16);	//estimation
	
	pos = ori.find(';', last_pos);
	
	//int isdigit ( int c );
	//int isalnum ( int c );
	
	
	
	while (string::npos != pos)
	{
		// -- check if it is an entity
		// -- entity name could be very long, also could be in numeric format
		size_t i = pos;
		bool hash_found = false; 
		while (i > last_pos)
		{
			//int isdigit ( int c );size_t i = pos;
			char tc = ori[i - 1];
			
			if (hash_found)
			{
				if ('&' != tc)	//invalid entity
					break;
				goto labelNextPos;
			}
			else if ('#' == tc)
				hash_found = true;
			else if ('&' == tc)
				goto labelNextPos;
			else if (!isalnum(tc))
				break;
			--i;
		}
		dps.push_back(pos);
		
	labelNextPos:
		last_pos = pos + 1;
		pos = ori.find(';', last_pos);
	}
	
	// now check for '.'
	last_pos = start_pos;
	pos = ori.find('.', last_pos);
	while (string::npos != pos)
	{
		dps.push_back(pos);
		last_pos = pos + 1;
		pos = ori.find('.', pos + 1);
	}
	
	
	if (!dps.empty())	//no delimits found, give the 
	{
		size_t posIdx = 0, posTtl = dps.size(), p = 0, s = 0, c = 0;	//counter for parenthes, square bracket, curly bracket
		last_pos = start_pos;
		size_t charIdx = last_pos;
		
		
		
		while (posIdx < posTtl)
		{
			pos = dps[posIdx];

			while (charIdx < pos)
			{
				switch (ori[charIdx])
				{
				case '(':
					++p;
					break;
				case '[':
					++s;
					break;
				case '{':
					++c;
					break;
				case ')':
					--p;
					break;
				case ']':
					--s;
					break;
				case '}':
					--c;
					break;
				}
				
				++charIdx;
			}
			
			if (0 == p && 0 == s && 0 == c)	//good
			{
				dst = ori.substr(start_pos, pos - start_pos);

				return;
			}
			
			// -- next position
			++posIdx;
		}
	}
	// -- no qualified delimit found. get the whole thing

	dst = ori;
}

string TruncateDefline(const string& strFullDefline, size_t uiCutOff)
{
	static const size_t k_ulRightSoftMargin = 6;
	size_t ulTotalChars = strFullDefline.size();
	
	if (ulTotalChars <= uiCutOff) return strFullDefline;
	if (uiCutOff <= 3)
		return "...";
	
	size_t idxLeft = uiCutOff - 1, idxRight = uiCutOff;	//check first non-alnum from both side
	
	while (idxRight < ulTotalChars)
	{
		if (idxRight > k_ulRightSoftMargin)
		{
			idxRight = 0;	//fail
			break;
		}
		char currCh = strFullDefline[idxRight];
		if (isalnum(currCh)) ++idxRight;
		else
		{
			switch (currCh)
			{
				case '_':
				case '-':
					++idxRight;
					break;
				default:
					goto labelRightDone;
					
			}
		} 
		
	}
labelRightDone:
	if (idxRight >= ulTotalChars) idxRight = 0;
	
	while (idxLeft > 0)
	{
		char currCh = strFullDefline[idxLeft];
		if (isalnum(currCh)) --idxLeft;
		else
		{
			switch (currCh)
			{
				case '_':
				case '-':
					--idxLeft;
					break;
				default:
					goto labelLeftDone;
			}
		}
	}
	
labelLeftDone:

	if (idxRight > 0 && idxRight - uiCutOff < uiCutOff - idxLeft) idxLeft = idxRight;
	if (0 == idxLeft)	//no breakpoint, use hard truncate
	{
		return strFullDefline.substr(0, uiCutOff) + "...";
	}
	
	string result(k_strEmptyString);
	
	switch (strFullDefline[idxLeft])
	{
		case '.':
		case ',':
		case ')':
		case ']':
		case '}':
		case '!':
		case ';':
		case ':':
		case '?':
			result = strFullDefline.substr(0, idxLeft + 1);
			result.append(" ...");
			return result;
		case ' ':
			result = strFullDefline.substr(0, idxLeft + 1);
			result.append("...");
			return result;
		default:
			result = strFullDefline.substr(0, idxLeft);
			result.append(" ...");
			return result;
	}
}


string CreateMD5SeqIdStr(const string &seqdata)
{
	return string(k_lpszEaaMD5) + "_" + CalcSeqMD5(seqdata);
}


void FastaAddLocalId(string& rBareSeq)
{
	rBareSeq = string(">lcl|") + CreateMD5SeqIdStr(rBareSeq) + "\n" + rBareSeq;
}

string FastaAddLocalId(const string& rBareSeq)
{
	string t(rBareSeq);
	FastaAddLocalId(t);
	return t;
}

void ParseUserDefl(const string& rUsrDefl, string& rIdStr, string& rDefl)
{
	char delim = '|';
	size_t ttlLen = rUsrDefl.size();
	if (ttlLen > 0)
	{
		size_t csr0 = 0;
		
		while (csr0 < ttlLen && ('>' == rUsrDefl[csr0] || rUsrDefl[csr0] <= 32)) ++csr0;	//skip 
		if (csr0 < ttlLen)
		{
			vector<string> vecParsed;
			while (csr0 < ttlLen)
			{
				size_t csr1 = rUsrDefl.find(delim, csr0);
				if (string::npos == csr1) csr1 = ttlLen;
				
				vecParsed.emplace_back(rUsrDefl.substr(csr0, csr1 - csr0));
				csr0 = csr1 + 1;
			}
			
			size_t totalSegs = vecParsed.size();
			size_t idFields = totalSegs / 2;
			
			if (idFields > 0)
			{
				char dimSep[4] = {0, 0, 0, 0};
				if (!rIdStr.empty())
				{
					dimSep[0] = '(';
					dimSep[2] = ')';
				}
			
				for (size_t i = 0; i < idFields; ++i)
				{
					size_t ii = i + i;
					rIdStr += (dimSep + vecParsed[ii]);
					dimSep[0] = delim;
					rIdStr += (dimSep + vecParsed[ii + 1]);
				}
				rIdStr.append(dimSep + 2);
			}
			
			idFields += idFields;	//double
			if (totalSegs > idFields)	//odd number
				rDefl = vecParsed[idFields];
				
		}
	}
}


string CalcSeqMD5(const string &seqdata)
{
	size_t len = seqdata.size();
	string cleaned(NcbiEmptyString);
	cleaned.reserve(len);
	
	for (string::const_iterator i = seqdata.begin(), ie = seqdata.end(); ie != i; ++i)
		if (isalpha(*i))
			cleaned.push_back(toupper(*i));
		else
			switch (*i)
			{
			case '(':
			case ')':
			case '=':
			case '.':
			case ',':
			case '/':
				cleaned.push_back(*i);
				break;
			default:;	//skip
			}
			
	return MD5Digest(cleaned);
}

string GetComplementSeq(const string &rSeq)
{
	string result(k_strEmptyString);
	result.reserve(rSeq.size());
	for (string::const_reverse_iterator riter = rSeq.rbegin(), riterEnd = rSeq.rend(); riter != riterEnd; ++riter)
	{
		char cap = toupper(*riter);
		switch (cap)
		{
		case 'A':
			result.push_back('T');
			break;
		
		case 'C':
			result.push_back('G');
			break;
		
		case 'G':
			result.push_back('C');
			break;
		
		case 'T':
		case 'U':
			result.push_back('A');
			break;
		case 'R':	//A/G, purine
			result.push_back('Y');
			break;
		case 'Y':	//C/T/U: pyrimidine
			result.push_back('R');
			break;
		case 'M':	//A or C
			result.push_back('K');
			break;
		case 'K':	//G or T
			result.push_back('M');
			break;
		case 'S':	//Strong, C or G
			result.push_back('W');
			break;
		case 'W':	//Weak, A or T
			result.push_back('S');
			break;
		case 'H':	//not G
			result.push_back('D');
			break;
		case 'D':	//not C
			result.push_back('H');
			break;
		case 'B':	//Not A
			result.push_back('V');
			break;
		case 'V':	//Not T or U
			result.push_back('B');
			break;
		case 'N':	//anything
			result.push_back('N');
			break;
		}
	}
	return result;
}


string RemoveDupPrefix(const string &pfx, const string &txt)
{
	size_t pfxlen = pfx.size(), txtlen = txt.size();
	if (0 == pfxlen || 0 == txtlen) return txt;
	
	if (pfxlen >= txtlen)
	{
		for (size_t i = 0; i < txtlen; ++i)
			if (pfx[i] != txt[i])
				goto labelNoTruncate;
		return k_strEmptyString;
	}
	else
	{
		size_t idx = 0;
		while (idx < pfxlen)
		{
			if (pfx[idx] != txt[idx])
				goto labelNoTruncate;
			++idx;
		}
		switch (txt[idx])
		{
		case ',':
		case '.':
		case ':':
		case ';':	//do truncate
			++idx;
			break;
		default:	//no trucation
			goto labelNoTruncate;
		}
		
		while (idx < txtlen)
		{
			if (txt[idx] <= 32 || '.' == txt[idx] || ',' == txt[idx] || ';' == txt[idx] || ':' == txt[idx])
				++idx;
			else
				goto labelTruncate;
		}
		
		return k_strEmptyString;
	labelTruncate:
		return txt.substr(idx, txtlen - idx);
		
	}
labelNoTruncate:
	return txt;
}

bool IsValidGeneticCode(int gc)
{
	return ((gc >= 1 && gc <= 6) || (gc >= 9 && gc <= 14) || (gc >= 21 && gc <= 25) || 16 == gc);
}
