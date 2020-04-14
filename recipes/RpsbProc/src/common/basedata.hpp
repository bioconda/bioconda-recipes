#if !defined(__BASE_DATA__)
#define __BASE_DATA__

#include "segset.hpp"
#if defined(__DB_OFFLINE__)
#include "envdef.hpp"
#include "ptrmap.hpp"
//#include "compactstore.hpp"
#include "enumlit.hpp"
#include "ljson.hpp"
#else
#include <NcbiBase/envdef.hpp>
#include <BasicUtils/ptrmap.hpp>
//#include <BasicUtils/compactstore.hpp>
#include <BasicUtils/enumlit.hpp>
#include <BasicUtils/ljson.hpp>
#endif
#include <vector>
#include <string>
/**********************************************************************
*	Constants. To avoid static object fiasco
***********************************************************************/

constexpr const PssmId_t INVALIDPSSMID = 100000000;
constexpr const ClusterId_t INVALIDCLUSTERID = -1;
constexpr const ClusterId_t SINGLEMEMBERCLUSTER = k_INT_MAX;

constexpr const int SEARCH_FAIL_FLAG = 4096;	//a flag, | to datasrc to indicate failure

constexpr const char * k_lpszEaaMD5 = "local_D5";	//to be compatible to blast "local" signature
constexpr const size_t k_AutoMD5IdSize = 8;
//constexpr const size_t k_AutoMD5IdSize = strlen(k_lpszEaaMD5);	//not working for visual studio

constexpr const char * CLUSTERSIG = "cl";
constexpr const char * CURATEDSIG = "cd";
constexpr const char * STRUCTSIG = "sd";


// -- unified property names for JSON objects
constexpr const char * _PROP_CDD = "cdd";
constexpr const char * _PROP_DOMS = "doms";
constexpr const char * _PROP_CLSTS = "clsts";
constexpr const char * _PROP_ALNS = "alns";
constexpr const char * _PROP_ALNRFS = "alnrfs";	//aligns by reading frames
constexpr const char * _PROP_ID = "id";	//generic id
constexpr const char * _PROP_ACC = "acc";
constexpr const char * _PROP_PSSMID = "pssmid";
constexpr const char * _PROP_SNAME = "sname";	//shortname
constexpr const char * _PROP_TTL = "ttl";
constexpr const char * _PROP_DEFL = "defl";
constexpr const char * _PROP_SZ = "sz";	//length, total counts, etc
constexpr const char * _PROP_ISNCBI = "isncbi";	//ncbi curated
constexpr const char * _PROP_ISMULTI = "ismulti";	//multidom
constexpr const char * _PROP_ISSD = "issd";	//multidom
constexpr const char * _PROP_CLID = "clid";	//cluster id
constexpr const char * _PROP_SRC = "src";	//source database
constexpr const char * _PROP_ROOT = "root";	//hiarchy root
constexpr const char * _PROP_MINBSCORE = "minbscore";	//minimal bitscore 
constexpr const char * _PROP_FEATS = "feats";
constexpr const char * _PROP_GENFTS = "genfts";	//generic features
constexpr const char * _PROP_SPFTS = "spfts";	//specific features
constexpr const char * _PROP_SEQDATA = "seqdata";	//sequence data (consensus, etc)
constexpr const char * _PROP_GCODE = "gcode";	//genetic code
constexpr const char * _PROP_MASKED = "masked";	//sequence data (consensus, etc)
constexpr const char * _PROP_MBRS = "mbrs";	//members
constexpr const char * _PROP_DESCR = "descr";	//description
constexpr const char * _PROP_TYPE = "type";	//members
constexpr const char * _PROP_IDX = "idx";	//index
constexpr const char * _PROP_FULLSZ = "fullsz";	//full size
constexpr const char * _PROP_EVDLST = "evdlst";	//evidence list, not used for now.
constexpr const char * _PROP_SPLABEL = "splabel";
constexpr const char * _PROP_ALNLEN = "alnlen";	//aligned length
constexpr const char * _PROP_ALNISMINUS = "alnisminus";	//aligned length
constexpr const char * _PROP_ALNPCT = "alnpct";	//aligned percentage
constexpr const char * _PROP_ALNSCORE = "alnscore";	//aligned score
constexpr const char * _PROP_ALNEV = "alnev";	//aligned evalue
constexpr const char * _PROP_ALNBS = "alnbs";	//aligned bitscore
constexpr const char * _PROP_ALNNUMID = "alnnumid";	//aligned number identical
constexpr const char * _PROP_ALNIDT = "alnidt";	//aligned seq identity
constexpr const char * _PROP_ALNSTR = "alnstr";	//align string for cddsrv
constexpr const char * _PROP_MSEGS = "msegs";	//master segments
constexpr const char * _PROP_TSEGS = "tsegs";	//target segments
constexpr const char * _PROP_FROM = "from";	//segment start
constexpr const char * _PROP_TO = "to";	//segment stop
constexpr const char * _PROP_REGIDX = "regidx";
constexpr const char * _PROP_ASN = "asn";
constexpr const char * _PROP_TID = "tid";	//target id, could be anything to index target sequence
constexpr const char * _PROP_LMSS = "lmss";	//left side missing percentage
constexpr const char * _PROP_RMSS = "rmss";	//right side missing percentage
constexpr const char * _PROP_ISREP = "isrep";	//is it rep (in concise view, CD aligns only)
constexpr const char * _PROP_ISSPEC = "isspec";	//is it specific (bright color, CD aligns only)
constexpr const char * _PROP_ISLIFTED = "islifted";	//is it specific (bright color, CD aligns only)
constexpr const char * _PROP_ISSUPPRESSED = "ispuppressed";	//is it specific (bright color, CD aligns only)
constexpr const char * _PROP_MSGS = "msgs";
constexpr const char * _PROP_MSG = "msg";
constexpr const char * _PROP_SEQTYPE = "seqtype";
constexpr const char * _PROP_LOCAT = "locat";
constexpr const char * _PROP__ID = "_id";
constexpr const char * _PROP_QSEQ = "qseq";
constexpr const char * _PROP_QTRANS = "qtrans";
constexpr const char * _PROP_DOMFAMS = "domfams";
constexpr const char * _PROP_ALNDOMS = "alndoms";	//align domains for superfamily hits
constexpr const char * _PROP_TAXID = "taxid";
constexpr const char * _PROP_SITES = "sites";
constexpr const char * _PROP_MOTIFS = "motifs";
constexpr const char * _PROP_LOCS = "locs";
constexpr const char * _PROP_TITLE = "title";
constexpr const char * _PROP_DEFLINE = "defline";
constexpr const char * _PROP_SEGS = "segs";
constexpr const char * _PROP_REALSEGS = "realsegs";
constexpr const char * _PROP_ORIFROM = "orifrom";
constexpr const char * _PROP_ORITO = "orito";
constexpr const char * _PROP_COORDS = "coords";
constexpr const char * _PROP_ORICOORDS = "oricoords";
constexpr const char * _PROP_EVALUE = "evalue";
constexpr const char * _PROP_REGION = "region";
constexpr const char * _PROP_BITSCORE = "bitscore";
constexpr const char * _PROP_TRUNC_N = "trunc_n";
constexpr const char * _PROP_TRUNC_C = "trunc_c";
constexpr const char * _PROP_USEROOT = "useroot";
constexpr const char * _PROP_CONSENSUS = "consensus";
constexpr const char * _PROP_RFS = "rfs";
constexpr const char * _PROP_RFID = "rfid";
constexpr const char * _PROP_RFIDX = "rfidx";
constexpr const char * _PROP_RID = "rid";
constexpr const char * _PROP_VALID = "valid";
constexpr const char * _PROP_STATUS = "status";
constexpr const char * _PROP_DATA = "data";
constexpr const char * _PROP_RDATA = "rdata";	//retrieved data
constexpr const char * _PROP_ALNACC = "alnacc";
constexpr const char * _PROP_SRCDOM = "srcdom";
constexpr const char * _PROP_MATCHID = "matchid";
constexpr const char * _PROP_ARCH = "arch";
constexpr const char * _PROP_ARCHSTR = "archstr";
constexpr const char * _PROP_SFARCHID = "sfarchid";
constexpr const char * _PROP_LABEL = "label";
constexpr const char * _PROP_NAME = "name";
constexpr const char * _PROP_SPECS = "specs";
constexpr const char * _PROP_NUMPIGS = "numpigs";
constexpr const char * _PROP_SCORE = "scores";
constexpr const char * _PROP_SUCCESS = "success";
constexpr const char * _PROP_URL = "url";
constexpr const char * _PROP_GI = "gi";
constexpr const char * _PROP_PIG = "pig";
constexpr const char * _PROP_RESPONSE = "response";
constexpr const char * _PROP_DOCS = "docs";

	

struct READINGFRAME
{
	typedef int TFRAMEID;
	typedef unsigned int TFRAMEINDEX;
	
	static constexpr const TFRAMEINDEX RF_SIZE = 3;	//reading frame size
	static constexpr const TFRAMEINDEX TOTAL_RFS = RF_SIZE + RF_SIZE;	//total reading frames
	
	static const char * RF_TITLES[TOTAL_RFS];
	static TFRAMEID RF_IDS[TOTAL_RFS];
	
	

	// -- return idx from id, invalid id, regardless of the value, will return 0
	static TFRAMEINDEX Id2Idx(TFRAMEID id) noexcept;
	
	// -- idx can be negative, which counts from last. -1 == 5, -2 == 4, -3 == 3, -4 == 2, -5 == 1, -6 == 0
	// -- if invalid, return 0 (invalid id)
	static TFRAMEID Idx2Id(TFRAMEINDEX idx) noexcept;
	
	// -- idx can be negative, which counts from last. -1 == 5, -2 == 4, -3 == 3, -4 == 2, -5 == 1, -6 == 0
	// -- if invalid, return nullptr (invalid title)
	static const char * Idx2Title(TFRAMEINDEX idx) noexcept;
	static const char * Id2Title(TFRAMEID id) noexcept;
	
	
	// -- Here are set of coordination conversion methods using readingframe index (rfidx, 0-5)
	// -- When dealing with alignments between na sequence and pr sequence, only the plus strand coordinates
	// -- actually matters
	// -- always assume translate the full length of na
	
	// -- from a plus strand get the corresponding coor
	static SeqPos_t PlusNA2MinusNA(SeqPos_t na, SeqLen_t na_len) {return na_len - na - 1;}
	
	// -- convert a plus strand reading frame index to minus strand reading frame index. Need the sequence length
	// -- assume it's na sequence.
	static TFRAMEINDEX PlusRFIdx2MinusRFIdx(TFRAMEINDEX prfidx, SeqLen_t na_len) {return (na_len - prfidx) % READINGFRAME::RF_SIZE + READINGFRAME::RF_SIZE;}
	
	// -- convert **plus** reading frame ID to plus strand rfidx. 
	static TFRAMEINDEX PlusId2PlusRFIdx(TFRAMEID rf, SeqLen_t na_len)
	{
		return rf - 1;
	}
	
	// -- convert **minus** reading frame ID to plus strand rfidx. 
	static TFRAMEINDEX MinusId2PlusRFIdx(TFRAMEID rf, SeqLen_t na_len)
	{
		return (na_len + rf + 1) % READINGFRAME::RF_SIZE;
	}
	
	
	
	// -- convert protein coordinate to PLUS strand, even the protein is encoded by minus strand
	// -- the returned na coordinate is the start of pr on plus strand. the coverage is r, r+1, r+2.
	
	// -- The next two convert protein to plus coordinates, which is always the first residue of
	// -- the codon. Which means, for proteins on plus strand, the codon residues are n, n+1, n+2; 
	// -- while for minus strand proteins, the codon on plus strand is n, n-1, n-2.
	// -- for efficiency
	// -- assume 0 <= rfidx < READINGFRAME::RF_SIZE
	static SeqPos_t PlusPr2PlusNA(SeqPos_t pr, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		return pr * READINGFRAME::RF_SIZE + rfidx;
	}
	
	// -- assume READINGFRAME::RF_SIZE <= rfidx < READINGFRAME::TOTAL_RFS
	static SeqPos_t MinusPr2PlusNA(SeqPos_t pr, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		// = na_len - (pr * READINGFRAME::RF_SIZE + (rfidx - READINGFRAME::RF_SIZE)) - 1
		// = na_len - (pr * READINGFRAME::RF_SIZE + rfidx - READINGFRAME::RF_SIZE) - 1
		// = na_len - (pr - 1) * READINGFRAME::RF_SIZE - rfidx - 1
		return na_len - (pr - 1) * READINGFRAME::RF_SIZE - rfidx - 1;
	}
	
	// -- for convenience
	static SeqPos_t Pr2PlusNA(SeqPos_t pr, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		return rfidx < READINGFRAME::RF_SIZE ? PlusPr2PlusNA(pr, rfidx, na_len) : MinusPr2PlusNA(pr, rfidx, na_len);
	}
	
	
	// -- Convert Plus strand coordinates to protein coordinates
	// - for efficiency
	// -- assume 0 <= rfidx < READINGFRAME::RF_SIZE
	static SeqPos_t PlusNA2PlusPr(SeqPos_t na, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		return (na - rfidx) / READINGFRAME::RF_SIZE;
	}
	
	// -- assume READINGFRAME::RF_SIZE <= rfidx < READINGFRAME::TOTAL_RFS
	// -- the +2 is due to the reverse of na in a codon of minus strand.
	static SeqPos_t PlusNA2MinusPr(SeqPos_t na, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		return (na_len - na - rfidx + 2) / READINGFRAME::RF_SIZE;
	}

	// -- for convenience
	// -- not much of use? but just for completion..
	// -- na may not be the start nt of the codon, could be any of the three.
	static SeqPos_t PlusNA2Pr(SeqPos_t na, TFRAMEINDEX rfidx, SeqLen_t na_len)
	{
		return rfidx < READINGFRAME::RF_SIZE ? PlusNA2PlusPr(na, rfidx, na_len) : PlusNA2MinusPr(na, rfidx, na_len);
	}
	
	
	//// -- protein/na coordinates conversion
	//static SeqPos_t NAPlus2Pr(SeqPos_t na) {return na / RF_SIZE;}
	//static SeqPos_t NAMinus2Pr(SeqPos_t na, SeqLen_t na_seq_len) {return (na_seq_len - na - 1) / READINGFRAME::RF_SIZE;}
	//
	//// -- rf: reading frame id: 1, 2, 3 as positive, -1, -2, -3. if 0 or any other invalid value, will be treated as protein and return the same value as input cooridinate 
	//static SeqPos_t NA2Pr(SeqPos_t napos, int rf, SeqLen_t na_len);
	//static SeqPos_t Pr2NA(SeqPos_t prpos, int rf, SeqLen_t pr_len);
	//
	//
	//static SeqPos_t Pr2NAPlus(SeqPos_t pr, int rf) {return pr * READINGFRAME::RF_SIZE + rf;}
	//
	//static SeqPos_t Pr2NAMinus(SeqPos_t pr, int rf, SeqLen_t aa_seq_len) {return (aa_seq_len - pr - 1) * READINGFRAME::RF_SIZE - rf - 1;}
	
};


/**********************************************************************
*	Result redundent level
***********************************************************************/
struct TDataModes
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		e_rep = eEnumStart,
		e_std = e_rep + 1,
		e_full = e_std + 1,
		eEnumStop = e_full + 1
	};
	
	static const char * e_std_alias;
	static const EIndex eDefault = e_rep;
	static const char* dimLits[eEnumStop - eEnumStart];
	static const char* dimDisplay[eEnumStop - eEnumStart];
};

struct TSearchModes
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		e_prec = eEnumStart,
		e_live,
		// ----------------
		eEnumStop
	};
	static const EIndex eDefault = e_prec;
	static const char* dimLits[eEnumStop - eEnumStart];
};




/**********************************************************************
*	Target data
***********************************************************************/
struct TTargetData
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		e_doms = eEnumStart,
		e_feats = e_doms + 1,
		e_both = e_feats + 1,
		eEnumStop = e_both + 1
	};
	
	static const EIndex eDefault = e_both;
	static const char* dimLits[eEnumStop - eEnumStart];
	static const char* dimDisplay[eEnumStop - eEnumStart];
};


struct TDartStatus
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		// ------------------
		eNoConn = eEnumStart,
		eUnknownGi = eNoConn + 1,
		eAnnotNotReady = eUnknownGi + 1,
		eNoHit = eAnnotNotReady + 1,
		eDartData = eNoHit + 1,
		eBlastRid = eDartData + 1,
		eError = eBlastRid + 1,
		eUnQualified = eError + 1,
		// ------------------
		eEnumStop = eUnQualified + 1
	};
	
	static const EIndex eDefault = eDartData;
	static const char* dimLits[eEnumStop];
};

struct TPublicDBs
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		// ------------------
		e_cdd = eEnumStart,
		e_cdd_ncbi,
		e_pfam,
		e_smart,
		e_kog,
		e_cog,
		e_prk,
		e_tigr,
		// ------------------
		eEnumStop
	};
	
	static const EIndex eDefault = e_cdd;
	static const char* dimLits[eEnumStop];
	static const char* dimDispNames[eEnumStop];
	
	static std::string GetFilterString(void);
	
};



/**********************************************************************
*	Special handling: PDB IDs
*	PDB IDs have been a mess due to the one-letter chain representation
*	Currently they are allowing up to 4 letters to identify a chain. The 
*	delimit between molecule and chain is not in the specs
*	Reference:
*		https://www.wwpdb.org/deposition/preparing-pdbx-mmcif-files
***********************************************************************/
class CPdbId
{
	friend class CDataCache & operator << (CDataCache &dc, const CPdbId& d);
	friend class CDataCache & operator >> (CDataCache &dc, CPdbId& d);
public:
	typedef unsigned int TCHAIN;
	static constexpr const int PDBMOL_LEN = 4;
	static constexpr const int PDBCHN_MAX_LEN = 15;
	static constexpr const char DELIM_CHAR = '_';
	CPdbId(void);
	CPdbId(const std::string &acxn);
	
	
	
	bool IsValid(void) const;
	
	// -- only if chain id has only two identical uppercase letters
	
	bool ParsePdbAcxn(const std::string & acxn);
	bool ParsePdbAcxn(const char * acxn);
	void Reset(void);	//does not reset m_usedelim
	
	const char * GetMol(void) const {return m_mol;}
#if !defined(_STRUCTURE_USE_LONG_PDB_CHAINS_)
	TCHAIN GetChain(void) const {return (TCHAIN)m_chain[0];}
	char GetChainLetter(void) const {return m_chain[0];}
#endif
	const char * GetChainId(void) const {return m_chain;}
	operator std::string(void) const;
	
	//void ParsePdbAcc(const std::string& rPdbAcc);
	//std::string GetStringAcc(char cDelimit = 0, char cEndChar = 0) const;
	//ncbi::CRef<ncbi::objects::CSeq_id> ConstructPdbId(void) const;
	//
	//const char * GetMol(void) const {return dimMol;}
	//char GetChainLetter(void) const {return cChainLetter;}
	//unsigned int GetMmdbId(void) const {return uiMmdbId;}
	//
	//
	//bool IsValid(void) const {return 0 != dimMol[0];}
	//bool operator == (const CPdbId& dst) const;
	//bool operator == (const ncbi::objects::CSeq_id &dstId) const;
	//bool operator == (const ncbi::objects::CPDB_seq_id &dstId) const;
	char m_usedelim;
protected:
	bool x_SetAcxn(const char * acxn, size_t len);
	char m_mol[PDBMOL_LEN + 1];	//the remaining 3-letter of molecule id, extra char for tail '\0'
	char m_chain[PDBCHN_MAX_LEN + 1];
	
};



/**********************************************************************
*	Biodata structure -- feature (site annotation)
*	Make it an individual class (not inherit segset class) because 
* in-house version of data may expand TSeg_base and inherit from there
***********************************************************************/

struct TDocsum
{
	// -- data members
	GI_t m_iGi;
	std::string m_strAccession;
	std::string m_strNcbiId;
	SeqLen_t m_uiSeqLen;
	std::string m_strTitle;
	//enum CSeq_inst::EMol
	//{
	//	ncbi::eMol_not_set =   0,  ///<   > cdna = rna
	//	eMol_dna     =   1,
	//	eMol_rna     =   2,
	//	eMol_aa      =   3,
	//	eMol_na      =   4,  ///< just a nucleic acid
	//	eMol_other   = 255
	//};	
	bool m_bIsNa;
	//int m_iMolType;
	// -- taxonomy information
	TaxId_t m_iTaxId;
	// -- reference http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi
	int m_iGenCode;
	int m_iMGenCode;	//mitochondrial genetic code
	std::string m_strSciName;	//scientific name
	std::string m_strBlastName;	//blast name
	std::string m_strCommonName;	//common name
	
	TDocsum(void):
		m_iGi(0), m_strAccession(k_strEmptyString), m_strNcbiId(k_strEmptyString), m_uiSeqLen(0), m_strTitle(k_strEmptyString), m_bIsNa(false),
		m_iTaxId(0), m_iGenCode(1), m_iMGenCode(2), m_strSciName(k_strEmptyString), m_strBlastName(k_strEmptyString), m_strCommonName(k_strEmptyString) {};
	
/*debug*******************************************************
#if defined(_DEBUG)
~TDocsum(void) {std::cerr << __FILE__ << ':' << __LINE__ << ": Entering ~TDocsum" << std::endl;}
#endif
// ***********************************************************/
	
	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
};

struct TSequence: public TDocsum
{
	enum EValidLevel
	{
		e_Invalid = 0,
		e_Current,
		e_NonCurrent,
		e_IsLocal,
		e_ValidStop
	};
	int m_iInputType;	//CCleanInput::EStringDataType values
	std::string m_strCleanedInput;	//also from CCleanInput
	std::string m_strSeqData;	//1-letter seqdata
	std::string m_Src;
	std::string m_B64PackedIds;
	std::string m_OriDefline;	//fasta origin defline
	int m_iValid;
	int m_iStatus;	//misc status for compatibility, previous field name is m_iOid
	PIG_t m_iPig;	//if has one. otherwise 0
	// -- added 2012/4/12 -- for range. m_iStart is default to 0, m_iEnd is default to -1, meaning whole length.
	SeqPos_t m_iFrom;
	SeqPos_t m_iTo;
	//std::vector<int> m_vecGis;	//from db, 	alias gi
	
	struct __SegMask
	{
		int from;
		int to;
		int rf;	//reading frame
		__SegMask(void): from(0), to(0), rf(0) {};
		__SegMask(int f, int t, int r): from(r), to(t), rf(r) {};
	};
	
	std::vector<__SegMask> m_vecMaskedRegions;
	// -- methods
	TSequence(void):
		TDocsum(),
		m_iInputType(0), m_strCleanedInput(), m_strSeqData(), m_Src(), m_B64PackedIds(), m_OriDefline(), m_iValid(e_Invalid), m_iStatus(0), m_iPig(0), m_iFrom(0), m_iTo(-1), m_vecMaskedRegions()
	{};
	

	// -- return if have seqdata. cannot blast without it.
	virtual SeqLen_t GetSeqLength(void) const {return m_uiSeqLen;}
	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
};



struct TDomSite: public CSegSet
{
	enum EFeatType	//this is arbitrary. 
	{
		eType_Other = 0,
		eType_Active = 1,
		eType_PolyPBinding = 2,
		eType_NtBinding = 3,
		eType_IonBinding = 4,
		eType_ChemBinding = 5,
		eType_PostTransMod = 6,
		eType_StructMotif = 7
	};
	
	static const int TOTAL_OFFL_TYPES = eType_StructMotif + 1;	//for offline only
	static const char * GENERIC_SITE_TITLE;
	static const char * FEATTYPES[TOTAL_OFFL_TYPES];
	
	//static std::map<int, std::string> m_mapActualFeatTypes;
	
	static const Flags_t STRUCTURE_BASED_EVIDENCE = 0x1 << 0;
	static const Flags_t REFERENCE_BASED_EVIDENCE = 0x1 << 1;
	static const Flags_t ADDITIONAL_COMMENTS = 0x1 << 2;
	
	static std::map<int, std::string> m_stFeatTypes;
	
	
	std::string m_strTitle;	//short title
	std::string m_strDescr;	//descrption, future use
	std::string m_strMotif;
	int m_iMotifuse;
	int m_iIndex;	//index within pssm or other sequence
	int m_iType;
	SeqPos_t m_iCompleteSize;
	Flags_t m_flags;
	
	TDomSite(void):
		CSegSet(),
		m_strTitle(), m_strDescr(), m_strMotif(), m_iMotifuse(0), m_iIndex(0), m_iType(0), m_iCompleteSize(0), m_flags(0)
	{};
	
	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
	
	static const char * GetFeatType(int idx);
	static LJSON::JSVar CreateLocs(const CSegSet &segset);




	
	virtual SeqPos_t GetCompleteSize(void) const {return m_iCompleteSize;}
	void GetMotifResPos(std::vector<SeqPos_t> &dst) const;
	//void SetMotifStr(const std::string &rMotifStr) {m_strMotif = rMotifStr;}
	// -- this is to checked the mapped site with motif. If rSeqData is provided, it ckecks
	// -- both the residue position and type. If rSeqData is not provided, just check for
	// -- all non-x residues are mapped. return values:
	// -- 0: success or No motif to check.
	// -- 1: Essential positions not complete
	// -- 2: Essential positions complete but residue type mismatch.
	//TResiduePos contains mapped and original positions, both on protein sequence
	int MotifCheck(const std::vector<TSeg_base::TResiduePos> &rMappedRes, const std::string &aaSeq = k_strEmptyString) const;
	
	
};




bool DomAcxnSig(const std::string &acxn, const char * sig);

struct TCluster
{
	PssmId_t m_uiPssmId;
	SeqLen_t m_uiLength;	// for cluster, this is the cluster size. For TDomain this is the domain length
	ClusterId_t m_iClusterId;
	std::string m_strAccession;
	std::string m_strShortName;
	std::string m_strTitle;
	std::string m_strDefline;
	TCluster(void);
	void Reset(void);
	
	// -- caller must guarantee enough space in buffer
	const char* ConstructClusterAccession(char *buf) const;
	virtual LJSON::JSVar CreateJson(void) const;
};

struct TDomain: public TCluster
{
	PssmId_t m_uiHierarchyRoot;	//root pssmid
	PssmId_t m_uiHierarchyParent;	//root pssmid
	PssmId_t m_uiClusterPssmId;
	double m_dMinBitScore;
	bool m_bCurated;
	bool m_bIsStructDom;
	bool m_bMultiDom;
	std::string m_strConsensus;
	std::string m_strSource;	//where is this domain defined, usually db name.
	
	std::list<TDomSite> m_lstSpecificFeatures;
	std::list<TDomSite> m_lstGenericFeatures;
	TDomain(void);
	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
};

// -- a template interface!
struct TDomClusterIndexIfx
{
	virtual const TDomain * FindCdInfo(PssmId_t pssmid) const = 0;
	virtual const TDomain * FindCdInfo(const std::string &acxn) const = 0;
	virtual const TCluster * FindClusterInfo(ClusterId_t clusterid) const = 0;
	virtual const TCluster * FindClusterByPssmId(PssmId_t pssmid) const = 0;
};

class CDomClusterIndex: public TDomClusterIndexIfx
{
public:
	// -- Since TCluster is a base class of TDomain, the sort object
	// -- can share
	struct TSortByPssmId
	{
		int operator () (const TCluster & v1, const TCluster & v2) const
		{
			return (int)v1.m_uiPssmId - (int)v2.m_uiPssmId;
		}
		
		int operator () (PssmId_t pssmid, const TCluster & v) const
		{
			return (int)pssmid - (int)v.m_uiPssmId;
		}
	};
	
	struct TSortByClusterId
	{
		int operator () (const TCluster & v1, const TCluster & v2) const
		{
			return v1.m_iClusterId - v2.m_iClusterId;
		}
		
		int operator () (ClusterId_t clstid, const TCluster & v) const
		{
			return (int)clstid - (int)v.m_iClusterId;
		}
	};
	
	struct TSortByAcxn
	{
		int operator () (const TCluster & v1, const TCluster & v2) const
		{
			return v1.m_strAccession.compare(v2.m_strAccession);
		}
		
		int operator () (const std::string & acxn, const TCluster & v) const
		{
			return acxn.compare(v.m_strAccession);
		}
	};
	
	typedef CPtrMap<PssmId_t, TDomain, TSortByPssmId> TPssmId2CdInfo;
	typedef CPtrMap<std::string, TDomain, TSortByAcxn> TAcxn2CdInfo;
	typedef CPtrMap<PssmId_t, TCluster, TSortByPssmId> TPssmId2ClusterInfo;
	typedef CPtrMap<ClusterId_t, TCluster, TSortByClusterId> TClusterId2ClusterInfo;
	
	virtual const TDomain * FindCdInfo(PssmId_t pssmid) const {return m_pssmid2cd.Find(pssmid);}
	virtual const TDomain * FindCdInfo(const std::string & acxn) const {return m_acxn2cd.Find(acxn);}
	virtual const TCluster * FindClusterInfo(ClusterId_t clusterid) const {return m_clid2fam.Find(clusterid);}
	virtual const TCluster * FindClusterByPssmId(PssmId_t pssmid) const {return m_pssmid2fam.Find(pssmid);}
	
	CDomClusterIndex(void): TDomClusterIndexIfx(), m_pssmid2cd(), m_acxn2cd(), m_pssmid2fam(), m_clid2fam() {};
	
	
	template<typename _TDomStore, typename _ClusterStore>
	CDomClusterIndex(_TDomStore& doms, _ClusterStore& clsts):
		TDomClusterIndexIfx(),
		m_pssmid2cd(doms.GetPointers()), m_acxn2cd(doms.GetPointers()), m_pssmid2fam(clsts.GetPointers()), m_clid2fam(clsts.GetPointers())
	{};
	
	
	void InsertDomainIdx(TDomain *p);
	void InsertClusterIdx(TCluster *p);
	
	void Reset(void);
	
	template<typename _T>
	void SetPssmId2CdPtrs(_T&& vec) {m_pssmid2cd.Reset(std::forward<_T> (vec));}
		
	template<typename _T>
	void SetAcxn2CdPtrs(_T&& vec) {m_acxn2cd.Reset(std::forward<_T> (vec));}
	
	template<typename _T>
	void SetPssmId2ClusterPtrs(_T&& vec) {m_pssmid2fam.Reset(std::forward<_T> (vec));}
		
	template<typename _T>
	void SetClusterId2ClusterPtrs(_T&& vec) {m_clid2fam.Reset(std::forward<_T> (vec));}
	
protected:
	
	TPssmId2CdInfo m_pssmid2cd;
	TAcxn2CdInfo m_acxn2cd;
	TPssmId2ClusterInfo m_pssmid2fam;
	TClusterId2ClusterInfo m_clid2fam;
};


struct TDomArch
{
	ArchId_t m_uiArchId;	//specific or not
	std::string m_strArchString;
	std::string m_strReviewLevel;
	TDomArch(void): m_uiArchId(0), m_strArchString(k_strEmptyString), m_strReviewLevel() {};
	TDomArch(ArchId_t archid, const std::string &archstr = k_strEmptyString): m_uiArchId(archid), m_strArchString(archstr), m_strReviewLevel() {};
	TDomArch(ArchId_t archid, std::string &&archstr): m_uiArchId(archid), m_strArchString(move(archstr)), m_strReviewLevel() {};
	

	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
};



struct TSpDomArch: public TDomArch
{
	std::string m_strName;
	std::string m_strLabel;
	ArchId_t m_uiSupFamArchId;	//superfamily
	
	TSpDomArch(void): TDomArch(), m_strName(k_strEmptyString), m_strLabel(k_strEmptyString), m_uiSupFamArchId(0) {};
	//TSpDomArch(ArchId_t archid, const std::string &archstr = k_strEmptyString): TDomArch(archid, k_strEmptyString), m_strName(k_strEmptyString), m_strLabel(k_strEmptyString), m_uiSupFamArchId(0) {};
	template<typename TArchStr>
	TSpDomArch(ArchId_t archid, TArchStr&& archstr):
		TDomArch(archid, std::forward<TArchStr> (archstr)), m_strName(k_strEmptyString), m_strLabel(k_strEmptyString), m_uiSupFamArchId(0) {};

/*debug*******************************************************
#if defined(_DEBUG)
void Print(void) const;
#endif
// ***********************************************************/
	void Reset(void);
	virtual LJSON::JSVar CreateJson(void) const;
};

// -- interface
struct TArchIndexIfx
{
	virtual const TSpDomArch * FindSpArch(ArchId_t archid) const = 0;
	virtual const TSpDomArch * FindSpArch(const std::string & archstr) const = 0;
	
	virtual const TDomArch * FindFamArch(ArchId_t archid) const = 0;
	virtual const TDomArch * FindFamArch(const std::string & archstr) const = 0;
};

class CArchIndex: public TArchIndexIfx
{
public:
	
	// -- as TDomArch is a base class of TSpDomArch, the sort object can share
	struct TSortByArchStr
	{
		int operator () (const TDomArch & v1, const TDomArch & v2) const
		{
			return v1.m_strArchString.compare(v2.m_strArchString);
		}
		int operator () (const std::string & archstr, const TDomArch & v) const
		{
			return archstr.compare(v.m_strArchString);
		}
	};
	
	struct TSortByArchId
	{
		int operator () (const TDomArch & v1, const TDomArch & v2) const
		{
			return (int)v1.m_uiArchId - (int)v2.m_uiArchId;
		}
		int operator () (unsigned int archid, const TDomArch & v) const
		{
			return (int)archid - (int)v.m_uiArchId;
		}
	};
	
	typedef CPtrMap<ArchId_t, TSpDomArch, TSortByArchId> TArchId2SpArch;
	typedef CPtrMap<std::string, TSpDomArch, TSortByArchStr> TArchStr2SpArch;
	
	typedef CPtrMap<ArchId_t, TDomArch, TSortByArchId> TArchId2FamArch;
	typedef CPtrMap<std::string, TDomArch, TSortByArchStr> TArchStr2FamArch;
		
	virtual const TSpDomArch * FindSpArch(ArchId_t archid) const {return m_id2sp.Find(archid);}
	virtual const TSpDomArch * FindSpArch(const std::string & archstr) const {return m_str2sp.Find(archstr);}
	
	virtual const TDomArch * FindFamArch(ArchId_t archid) const {return m_id2fam.Find(archid);}
	virtual const TDomArch * FindFamArch(const std::string & archstr) const {return m_str2fam.Find(archstr);}
	
	CArchIndex(void): TArchIndexIfx(), m_id2sp(), m_str2sp(), m_id2fam(), m_str2fam() {};
	
	void InsertSpArchIdx(TSpDomArch *p);
	void InsertFamArchIdx(TDomArch *p);
	
	
	template<typename _TSpArchStore, typename _FamArchStore>
	CArchIndex(_TSpArchStore& sp, _FamArchStore& fam):
		TArchIndexIfx(),
		m_id2sp(sp.GetPointers()), m_str2sp(sp.GetPointers()), m_id2fam(fam.GetPointers()), m_str2fam(fam.GetPointers())
	{};
	
	void Reset(void);

	template<typename _T>
	void SetArchId2SpPtrs(_T&& vec) {m_id2sp.Reset(std::forward<_T> (vec));}
		
	template<typename _T>
	void SetArchStr2SpPtrs(_T&& vec) {m_str2sp.Reset(std::forward<_T> (vec));}
	
	template<typename _T>
	void SetArchId2FamPtrs(_T&& vec) {m_id2fam.Reset(std::forward<_T> (vec));}
		
	template<typename _T>
	void SetArchStr2FamPtrs(_T&& vec) {m_str2fam.Reset(std::forward<_T> (vec));}
	
protected:
	TArchId2SpArch m_id2sp;
	TArchStr2SpArch m_str2sp;
	TArchId2FamArch m_id2fam;
	TArchStr2FamArch m_str2fam;
};




struct TSeqAlignment
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		// ------------------
		SORT_BY_EVALUE = eEnumStart,
		SORT_BY_BITSCORE,
		SORT_BY_SEQ_IDENTITY,
		SORT_BY_ALIGNED_LENGTH,
		SORT_BY_SCORE_COMBO,
		
		// ------------------
		eEnumStop
	};
	
	
	static const EIndex eDefault = SORT_BY_EVALUE;
	static const char* dimLits[eEnumStop];
	static const char* dimLabels[eEnumStop];
	
	typedef bool LPFN_COMPARE(const TSeqAlignment *p1, const TSeqAlignment *p2);
	
	static bool EValueCompare(const TSeqAlignment *p1, const TSeqAlignment *p2)
	{
		return p1->m_dEValue < p2->m_dEValue;
	}
	
	static bool BitScoreCompare(const TSeqAlignment *p1, const TSeqAlignment *p2)
	{
		return p1->m_dBitScore > p2->m_dBitScore;
	}
	
	static bool AlignedLengthCompare(const TSeqAlignment *p1, const TSeqAlignment *p2)
	{
		return p1->m_uiAlignedLen > p2->m_uiAlignedLen;
	}
	
	static bool SeqIdentityCompare(const TSeqAlignment *p1, const TSeqAlignment *p2)
	{
		return p1->m_dSeqIdentity > p2->m_dSeqIdentity;
	}
	
	
	static bool ScoreComboEvaluate(const TSeqAlignment *p1, const TSeqAlignment *p2)
	{
		if (p1->m_dEValue < p2->m_dEValue) return true;
		else if (p1->m_dEValue > p2->m_dEValue) return false;
		else return (p1->m_dBitScore > p2->m_dBitScore);
	}
	
	struct TSortObj
	{
		TSortObj(LPFN_COMPARE lpfnCompare): m_lpfnCompare(lpfnCompare) {};
		TSortObj(int iSortIdx);
		LPFN_COMPARE * GetCompareFunc(void) const {return m_lpfnCompare;}
		
		bool operator () (const TSeqAlignment *p1, const TSeqAlignment *p2)
		{
			return m_lpfnCompare(p1, p2);
		}
		
		LPFN_COMPARE *m_lpfnCompare;
	};
	
	// -- added 6/27/2011 -- for na aligns
	enum EAlignType
	{
		eNormal,	//master = protein, slave = protein
		ePr2Na	//master = na, slave = protein
	};
	
	
	static void PrintEValue(char *buf, double eval);
	static void PrintBitScore(char *buf, double bscore);
	static void PrintPercentage(char *buf, double pct);	//pct is 0.0~100.0
	

	// -- scores
	SeqLen_t m_uiAlignedLen;
	double m_dAlignedPct;
	int m_iScore;
	double m_dEValue;
	double m_dBitScore;
	int m_iNumIdent;
	double m_dSeqIdentity;
	
	
	EAlignType m_eAlignType;
	


	// -- added 6-23-2011: for NA search
	// -- defined in objects/seqloc/Na_strand.hpp
	//int m_eStrand;
	bool m_bIsMinus;	//master is minus strand.
	
	
	// -- Use unsigned int. The lowest two bits contains the "positive" readingframe index: 0 to 2 as 
	// -- offset from the 5'-end of the current sequence used in alignment. IF it is the protein is 
	// -- encoded by this stramd. then it is the actual rfidx. If encoded by the complement strand, 
	// -- then the actual rfidx depends on the length of the sequence, which may not be known in some cases.
	// -- It must be obtained after the length of sequence becomes available, using READINGFRAME::PlusRFIdx2MinusRFIdx(READINGFRAME::TFRAMEINDEX prfidx, SeqLen_t na_len);
	
	// -- the higher bits (30 for a 32-bit unsigned integer type, 1073741823 max, is still very much enough to hold the aligned sequence length)
	READINGFRAME::TFRAMEINDEX m_ReadingFrame;
	
	
	
	
	//SeqPos_t m_iSlaveCoordConvert;	//a slave coordination conversion factor for negative factor
	
	// -- overall master re
	SeqPos_t m_iFrom;
	SeqPos_t m_iTo;
// -- processed align info
	std::vector<SeqPos_t> m_vecMStarts;	//regardless the align type, MStarts and SStarts always be protein-to-protein. 
	std::vector<SeqPos_t> m_vecSStarts;
	std::vector<SeqLen_t> m_vecLens;
	//std::vector<TGap> m_mstGaps;
	
	CSegSet m_ClipSet;	//must be in aa coordinates!
	
	// -- methods
	TSeqAlignment(void):
		m_uiAlignedLen(0), m_dAlignedPct(0.0), m_iScore(0), m_dEValue(0.0), m_dBitScore(0), m_iNumIdent(0), m_dSeqIdentity(0.0),
		m_eAlignType(eNormal),
		//m_eStrand(ncbi::objects::eNa_strand_unknown),
		m_bIsMinus(false),
		m_ReadingFrame(0), m_iFrom(0), m_iTo(0), m_vecMStarts(), m_vecSStarts(), m_vecLens(),
		m_ClipSet()
	{};
	
	void Reset(void);
	

	
	inline
	void PrintEValue(char *buf) const {TSeqAlignment::PrintEValue(buf, m_dEValue);}
	inline
	void PrintBitScore(char *buf) const {TSeqAlignment::PrintEValue(buf, m_dBitScore);}
	inline
	void PrintAlignedPct(char *buf) const {TSeqAlignment::PrintEValue(buf, m_dAlignedPct);}
	inline
	void PrintSeqIdentity(char *buf) const {TSeqAlignment::PrintEValue(buf, m_dSeqIdentity);}
	
	// -- this is for getting the aligned string for cddsrv.
	std::string GetAlignString(void) const;

	
	//void StrandConvert(CSegSet &segset) const;
	void Pr2NaConvert(CSegSet &segset) const;
	void MapSegSet(CSegSet &segset, bool doConvert = true) const;
	
	// -- convert segs to translated cooridinates so TDomSite can perform motif check.
	// -- assume segs contains master coordinates, but not converted to na (if na/pr alignment) net. only need to consider the actual protein seq length
	// -- because alignment mapping for minus chain translation only have the aligned range, not the whole protein length
	// -- qlen is the query length, either aa or na. Will automatically convert.
	READINGFRAME::TFRAMEINDEX GetTranslatedPosMap(const CSegSet &mappedAAsegs, SeqLen_t qLen, std::vector<TSeg_base::TResiduePos> &rMappedAAPos) const;
	
	//void CreateNormalSegs(CSegSet &segset) const;
	void CreateSlaveSegs(CSegSet &segset) const;
	void CreateMasterSegs(CSegSet &segset) const;
	void CalcMasterGaps(SeqLen_t gapThreshold, CSegSet &segset) const;

	//seqLen is the query seq len, aa or na. 
	READINGFRAME::TFRAMEINDEX GetRFIdx(SeqLen_t seqLen) const;

	//int Na2Pr(SeqPos_t na, SeqPos_t &pr) const;
	//int Pr2Na(SeqPos_t pr, SeqPos_t &na) const;
	
	virtual void AddSegs(LJSON::JSVar &pobj) const;
	
	virtual LJSON::JSVar CreateJson(void) const;
	
};

//// -- this is to convert denseg align format to TSeqAlignment
//void CleanAlignment(const std::vector<SeqPos_t> & rSrcStarts, const std::vector<SeqLen_t> & rSrcLens, std::vector<SeqPos_t>& rMStarts, std::vector<SeqPos_t>& rSStarts, std::vector<SeqLen_t>& rLens);

template<typename NCBISeqPosType, typename NCBISeqLenType>
void CleanAlignment(const std::vector<NCBISeqPosType> & rSrcStarts, const std::vector<NCBISeqLenType> & rSrcLens, std::vector<SeqPos_t>& rMStarts, std::vector<SeqPos_t>& rSStarts, std::vector<SeqLen_t>& rLens)
{
	rMStarts.clear();
	rSStarts.clear();
	rLens.clear();

	for (size_t i = 0; i < rSrcLens.size(); ++i)
	{
		size_t ii = i + i;
		if (rSrcStarts[ii] >=0 && rSrcStarts[ii + 1] >= 0)
		{
			rMStarts.push_back(rSrcStarts[ii]);
			rSStarts.push_back(rSrcStarts[ii + 1]);
			rLens.push_back(rSrcLens[i]);
		}
	}
}




struct TDomSeqAlignment: public TSeqAlignment
{
	static constexpr const SeqLen_t GAP_THRESHOLD = 35;
	PssmId_t m_uiPssmId;
	int m_iRegionIdx;	//region on the query sequence. 
	
	double m_dNMissing;
	double m_dCMissing;
	bool m_bSpecQualified;	//higher bitscore than threshold
	int m_iRepClass;	//single and multi -- sort separately
	bool m_bRep;
	bool m_bLifted;	//lifted by a higher evalue and approved by architecture frequencs
	bool m_bSuppressed;
	
	
	
	TDomSeqAlignment(void):
		m_uiPssmId(0), m_iRegionIdx(0), m_dNMissing(0.0), m_dCMissing(0.0), m_bSpecQualified(false), m_iRepClass(0), m_bRep(0), m_bLifted(0), m_bSuppressed(0)
	{};
	
	// -- including properly mapped features
	
	// -- extra
	bool IsSpecific(void) const {return m_bRep && m_bSpecQualified;}
	
	
	//bool IsSpecific(void) const {return m_bSpecQualified;}
	
	// -- map a feature to dst. return 0: success. Return 1: not all
	// -- essential residues are mapped. return 2: residue type
	// -- mismatch (if seqData is not empty)
	
	//// -- convert segs (master coordinates already) to translated cooridinates so TDomSite can perform motif check.
	//// -- return reading frame for the alignment, which can be used to select a translation frame index (0 - 5). if 
	//// -- return 0 for protein sequence that needs no translation.
	//int GetTranslatedPosMap(const CSegSet &segs, SeqLen_t seqLen, std::vector<TSeg_base::TResiduePos> &rMappedAAPos) const;
	virtual void AddSegs(LJSON::JSVar &pobj) const;
	virtual LJSON::JSVar CreateJson(void) const;
};

// -- qLen is the query length, aa or na
int MapCdFeature(const TDomSite &rFeat, const TDomSeqAlignment &rAlign, SeqLen_t qLen, const std::string dimAaData[], CSegSet &dst);


struct TDomSeqAlignIndex
{
	struct __TCdAlignRecordBase
	{
		const TDomSeqAlignment * pAlign;
		const TDomain * pCdInfo;
		
		__TCdAlignRecordBase(void): pAlign(nullptr), pCdInfo(nullptr) {};
	};
	
	struct __TEquClusterHit
	{
		bool operator () (const __TCdAlignRecordBase &a, const __TCdAlignRecordBase &b) const;
	};
	
	// -- this compare assume 
	struct __TEquivalentHit
	{
		bool operator () (const __TCdAlignRecordBase &a, const __TCdAlignRecordBase &b) const;
	};
	
	struct TSortByFromObj
	{
		bool operator () (const __TCdAlignRecordBase &a, const __TCdAlignRecordBase &b) const
		{
			return a.pAlign->m_iFrom < b.pAlign->m_iFrom;
		}
	};
	

	struct __TCdAlignRecord: public __TCdAlignRecordBase
	{
		const TCluster * pClst;
		const TDomain * pRootCdInfo;
		
		//const CDomainInfoMaps::TCuratedClusterInfo * pCuratedClst;
		size_t idx;	//need to give area id an index to align info
		size_t idxidx;	//the index in concise
		
		__TCdAlignRecord(void): __TCdAlignRecordBase(), pClst(nullptr), pRootCdInfo(nullptr), idx(-1), idxidx(-1) {};
	};
	
	// -- used by rpsbproc
	struct __MotifType_base
	{
		std::list<TDomSite> :: const_iterator iterMotifFeat;
		std::vector<__TCdAlignRecord> :: const_iterator iterAlignRec;
		bool bIsSpecific;
		PssmId_t uiSrcPssmId;
		__MotifType_base(void):
			iterMotifFeat(), iterAlignRec(), bIsSpecific(false), uiSrcPssmId(0) {};
		
		__MotifType_base(std::list<TDomSite> :: const_iterator iterM, std::vector<__TCdAlignRecord> :: const_iterator iterA, bool isspec = false, PssmId_t srcpssm = 0):
			iterMotifFeat(iterM), iterAlignRec(iterA), bIsSpecific(isspec), uiSrcPssmId(srcpssm) {};
	};
	
	struct __MotifType: public __MotifType_base
	{
		int feat_idx;
		const TDomain *pSrcCdInfo;
		
		__MotifType(void): __MotifType_base(), feat_idx(0), pSrcCdInfo(nullptr) {};
		__MotifType(std::list<TDomSite> :: const_iterator iterM, std::vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterA, bool isspec = false, PssmId_t srcpssm = 0, int fidx = 0, const TDomain *pscd = nullptr): 
			__MotifType_base(iterM, iterA, isspec, srcpssm),
			feat_idx(fidx), pSrcCdInfo(pscd) {};
	};
	
	
	
	
	std::vector<size_t> m_vecSortedIndice;
	std::vector<size_t> m_vecConciseIndice;
	std::vector<size_t> m_vecStdIndice;
	// -- modified 5/8/2012 -- now feature and rep hits are separated -- since we introduced non-NCBI-curated specific hits
	std::vector<size_t> m_vecQualifiedFeatIndice;	//should be every region's best evalue curated
	// -- modified 9/8/2014 -- Structure domains to add motif annotations
	std::vector<size_t> m_vecSDIndice;
	
	TDomSeqAlignIndex(void): m_vecSortedIndice(), m_vecConciseIndice(), m_vecStdIndice(), m_vecQualifiedFeatIndice(), m_vecSDIndice() {};
	void CreateRecordSets(const std::vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, std::vector<__TCdAlignRecord> &rDomAligns, std::vector<__TCdAlignRecord> &rFeatAligns, int mode) const;
	// -- added 12/6/2016: Concise view now should always include curated models (if available).
	void CreateConciseAmends(const std::vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, const std::vector<__TCdAlignRecord> &rConciseAligns, std::vector<__TCdAlignRecord> &rAmendAligns) const;
	void ExtractFeatAligns(const __TCdAlignRecord &rRepRec, const std::vector<TDomSeqAlignment> &rAlignments, const TDomClusterIndexIfx & rDomInfo, std::vector<__TCdAlignRecord> &rResult) const;
};


struct TDomQuery: public TSequence
{
	int m_iDataSrc;	//precalc or live
	std::vector<TDomSeqAlignment> m_vecAlignments;	//alignments from rpsblast
	TDomSeqAlignIndex m_dimSplitAligns[READINGFRAME::TOTAL_RFS];
	
	TDomQuery(void): TSequence(), m_iDataSrc(TSearchModes::eEnumStop), m_vecAlignments(), m_dimSplitAligns() {};
/*debug*******************************************************
#if defined(_DEBUG)
~TDomQuery(void) {std::cerr << __FILE__ << ':' << __LINE__ << ": Entering ~TDomQuery" << std::endl;}
#endif
// ***********************************************************/
	
	//struct __MotifType
	//{
	//	std::list<TDomSite> :: const_iterator iterMotifFeat;
	//	std::vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterAlignRec;
	//	bool bIsSpecific;
	//	PssmId_t uiSrcPSSMId;
	//	__MotifType(std::list<TDomSite> :: const_iterator iterM, std::vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterA, bool spec, PssmId_t srcpssm): 
	//		iterMotifFeat(iterM), iterAlignRec(iterA), bIsSpecific(spec), uiSrcPSSMId(srcpssm) {};
	//};
	//virtual LJSON::JSVar CreateJson(void) const;
};

struct TSnpData
{
	int iSnpId;
	int iSnpTitle;
	SeqPos_t iMstPos;	// -- 0 based
	SeqPos_t iNbrPos;	// -- 0 based
	std::string strType;	//such as "rs"
	std::string strId;	//numeric
	char cOriRes;	//original residue
	char cMutRes;	//mutate to residue
	
	TSnpData(void):
		iSnpId(0), iSnpTitle(-1), iMstPos(-1), iNbrPos(-1), strType(NcbiEmptyString), strId(NcbiEmptyString), cOriRes(' '), cMutRes(' ')
	{};
	
	inline
	bool IsSynon(void) const {return cOriRes == cMutRes;}
	
	void ConstructTitle(std::string& rDest) const;
	std::string ConstructTitle(void) const;
	
	virtual LJSON::JSVar CreateJson(void) const;
};

/**********************************************************************
*	blast search parameters
// ********************************************************************/
constexpr const size_t DEF_MAXHIT = 500;
constexpr const bool DEF_LIFT = false;
constexpr const bool DEF_SUPPR = false;
constexpr const bool DEF_FORCE_LIVE = false;
constexpr const bool DEF_FILTER = false;
constexpr const bool DEF_COMP_BASED_ADJUST = true;

constexpr const double DEF_EVALCUTOFF = 0.01;	//default evalue cut off
constexpr const double PRECALC_EVALUE = 0.01;	//default evalue cut off
constexpr const double LIFT_EVALUE = 1.0;	//default evalue cut off
constexpr const double COREARCH_EVALUE = 1.0e-3;	//default evalue cut off
constexpr const double PRIORITYEVAL = 1.0e-5;

constexpr const char * DEF_DB = "cdd";
constexpr const char * DEF_DB_PATH = "CDSEARCH";
constexpr const char * RPSB_MATRIX = "BLOSUM62";

constexpr const char * DEF_DARTDB = "cdart";

// -- internal search
constexpr const char * INTERNAL_DEF_DB = "cdd_loc";	//cdd_loc
constexpr const char * INTERNAL_DB_PATH = "CDSEARCH_TEST";	//cdsearch_test

constexpr const Flags_t fINCLUDE_UNRELEASED = 1 << 0;
constexpr const Flags_t fLOAD_CLUSTERS = 1 << 1;
constexpr const Flags_t fLOAD_FEATURES = 1 << 2;
constexpr const Flags_t fLOAD_CONSENSUS = 1 << 3;
constexpr const Flags_t fOUTPUT_REPS_ONLY = 1 << 4;
// -- deprecated, always load curated cluster info
//Flags_t fLOAD_CURATED_CLUSTER_INFO = 1 << 5;
constexpr const Flags_t fLOAD_CD_FROM_BLASTDB = 1 << 6;

// -- added 4/8/2011 -- for jsonnode generation
constexpr const Flags_t fLOAD_ALIGN_ASN = 1 << 7;
constexpr const Flags_t fLOAD_ALIGN_SEGS = 1 << 8;
constexpr const Flags_t fLOAD_ALIGN_STRING = 1 << 9;
constexpr const Flags_t fLOAD_FEAT_EVIDENCE = 1 << 10;
constexpr const Flags_t fLOAD_CLST_MEMBERS = 1 << 11;
// -- added 12/2/2013 to adapt Extended View
constexpr const Flags_t fUSE_EXTENSIVE_RESULTS = 1 << 12;



struct TBlastParams
{
/******************************************************
*	Added 5/28/2014. When true, always do live search @ evalue=1.0;
*	Study extra domains to see if they form biologically more relavent
* architectures 
*******************************************************/
	bool m_bUseLift;
// ****************************************************/

/******************************************************
*	Added 4/14/2015. When true, always do live search @ evalue=1.0;
*	Study extra domains to see if they form biologically more relavent
* architectures 
*******************************************************/
	bool m_bUseSuppression;
// ****************************************************/

	int m_iSearchMode;
	std::string m_strDbPath;
	std::string m_strDbName;
	double m_dEvalCutOff;
	bool m_bLCFilter;
	bool m_bCompBasedAdj;
	size_t m_nMaxHits;
	Flags_t m_fDataOpts;
	
	// -- m_iSearchMode initialized to TSearchModes::eEnumStop for "auto" mode
	TBlastParams(void):
		m_bUseLift(DEF_LIFT), m_bUseSuppression(DEF_SUPPR), m_iSearchMode(TSearchModes::eEnumStop), m_strDbPath(DEF_DB_PATH),
		m_strDbName(GetLit<TPublicDBs>(TPublicDBs::eDefault)),
		m_dEvalCutOff(DEF_EVALCUTOFF),
		m_bLCFilter(DEF_FILTER),
		m_bCompBasedAdj(DEF_COMP_BASED_ADJUST),
		m_nMaxHits(DEF_MAXHIT),
		m_fDataOpts(fLOAD_CLUSTERS | fLOAD_FEATURES | fLOAD_CONSENSUS)
	{};
	
};


struct TBlastProcessInfo
{
	std::string m_strDartServer;
	std::string m_strDartDb;	//usually cdart, but could sometimes use a temp db
	std::string m_strDartVer;
	std::string m_strBlastProgram;
	std::string m_strBlastService;
	std::string m_strSearchCreator;
	int m_blStatus;	//CRemoteBlast::ESearchStatus
	bool m_bProcessed;
	std::vector<std::string> m_vecStatusMsgs;	//if not empty, error.
	std::vector<std::string> m_vecBlastRids;
	
	TBlastProcessInfo(void):
		m_strDartServer(), m_strDartDb(DEF_DARTDB), m_strDartVer(), m_strBlastProgram(), m_strBlastService(), m_strSearchCreator(),
		m_blStatus(0), m_bProcessed(false), m_vecStatusMsgs(), m_vecBlastRids()
	{};
};

template<typename TDOMSTORE, typename TCLSTORE>
struct TFlatDomClusterMap: public CDomClusterIndex
{
	TDOMSTORE m_cdstore;
	TCLSTORE m_clstore;
	
	TFlatDomClusterMap(void):
		CDomClusterIndex(), m_cdstore(), m_clstore()
	{};
	
	void MoveIn(TDOMSTORE &&doms, TCLSTORE && cls);
	void RefreshIndices(void);
	//void MoveIn(TDOMSTORE &&doms, TCLSTORE && cls, const CDomClusterIndex &idx);
};

template<typename TDOMSTORE, typename TCLSTORE>
void TFlatDomClusterMap<TDOMSTORE, TCLSTORE> :: RefreshIndices(void)
{
	std::vector<typename TDOMSTORE::DATA_PTR> domptrs = m_cdstore.GetPointers();
	m_pssmid2cd.Reset(domptrs);
	m_acxn2cd.Reset(move(domptrs));
	
	std::vector<typename TCLSTORE::DATA_PTR> clptrs = m_clstore.GetPointers();
	m_pssmid2fam.Reset(clptrs);
	m_clid2fam.Reset(move(clptrs));
}

template<typename TDOMSTORE, typename TCLSTORE>
void TFlatDomClusterMap<TDOMSTORE, TCLSTORE> :: MoveIn(TDOMSTORE &&doms, TCLSTORE && cls)
{
	m_cdstore.Reset();
	m_clstore.Reset();
	m_cdstore = std::move(doms);
	m_clstore = std::move(cls);
	
	RefreshIndices();
}

//template<typename TDOMSTORE, typename TCLSTORE>
//void TFlatDomClusterMap<TDOMSTORE, TCLSTORE> :: MoveIn(TDOMSTORE &&doms, TCLSTORE && cls, const CDomClusterIndex &idx)
//{
//	m_cdstore.Reset();
//	m_clstore.Reset();
//	m_cdstore = std::move(doms);
//	m_clstore = std::move(cls);
//	
//	CDomClusterIndex::operator = (idx);
//	
//	//std::vector<typename TDOMSTORE::DATA_PTR> domptrs = m_cdstore.GetPointers();
//	//m_pssmid2cd.Reset(domptrs);
//	//m_acxn2cd.Reset(move(domptrs));
//	//
//	//std::vector<typename TCLSTORE::DATA_PTR> clptrs = m_clstore.GetPointers();
//	//m_pssmid2fam.Reset(clptrs);
//	//m_clid2fam.Reset(move(clptrs));
//}

/**********************************************************************
*	some misc utilities
// ********************************************************************/
// -- misc literal string manipulation
// -- some string values in out database contains html entities that disrupts processing. Replace them with norma character
void ReplaceEntities(std::string &dst);
void GetShortDomainDefline(const std::string &ori, std::string &dst);
std::string TruncateDefline(const std::string& strFullDefline, size_t uiCutOff = 255);

std::string CreateMD5SeqIdStr(const std::string &seqdata);

void FastaAddLocalId(std::string& rBareSeq);
std::string FastaAddLocalId(const std::string& rBareSeq);
void ParseUserDefl(const std::string& rUsrDefl, std::string& rIdStr, std::string& rDefl);

// -- sequence data (string) manipulation
std::string CalcSeqMD5(const std::string &seqdata);
std::string GetComplementSeq(const std::string &rSeq);

// -- sometimes defline can have duplicated prefixes, remove them for cosmetic sake
std::string RemoveDupPrefix(const std::string &pfx, const std::string &txt);

bool IsValidGeneticCode(int gc);





// *******************************************************************/


#endif
