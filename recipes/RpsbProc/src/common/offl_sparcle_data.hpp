#if !defined(__OFFL_SPARCLE_DATA__)
#define __OFFL_SPARCLE_DATA__
#if defined(__DB_OFFLINE__)
#include "compactstore.hpp"
#include "basedata.hpp"
#else
#include <BasicUtils/compactstore.hpp>
#include <DataUtils/basedata.hpp>
#endif
#include <corelib/ncbimtx.hpp>

class COfflDomClusterData: public CDomClusterIndex
{
	static constexpr const size_t TOTAL_CDS_ESTI = 52000;	//estimated domains
	static constexpr const size_t TOTAL_CLSTS_ESTI = 6000;
public:
	
	static constexpr const char * __cdd_ids_file = "cddid.tbl";
	static constexpr const char * __spec_feats_file = "cddannot.dat";
	static constexpr const char * __gen_feats_file = "cddannot_generic.dat";
	static constexpr const char * __bs_thrlds_file = "bitscore_specific.txt";
	static constexpr const char * __cdtrack_file = "cdtrack.txt";
	static constexpr const char * __domfam_link_file = "family_superfamily_links";
	
	typedef CCompactStore<TDomain, TOTAL_CDS_ESTI * sizeof(TDomain) > TOfflCDStore;
	typedef CCompactStore<TCluster, TOTAL_CLSTS_ESTI * sizeof(TCluster) > TOfflClusterStore;
	
	COfflDomClusterData(void):
		CDomClusterIndex(), m_CDStore(), m_ClusterStore() {};
	
	COfflDomClusterData(const std::string &datadir, const char *cddids = nullptr, const char *spfeats = nullptr, const char *genfeats = nullptr, const char *bscores = nullptr, const char *cdtrack = nullptr, const char *famlinks = nullptr):
		CDomClusterIndex(), m_CDStore(), m_ClusterStore()
	{LoadData(datadir, cddids, spfeats, genfeats, bscores, cdtrack, famlinks);}
	
	COfflDomClusterData(const std::string &cddids, const std::string &spfeats, const std::string &genfeats, const std::string &bscores, const std::string &cdtrack, const std::string &famlinks):
		CDomClusterIndex(), m_CDStore(), m_ClusterStore()
	{LoadData_real(cddids, spfeats, genfeats, bscores, cdtrack, famlinks);}
	
	// -- any file names be nullptr, use default file name
	void LoadData(const std::string &datadir, const char *cddids = nullptr, const char *spfeats = nullptr, const char *genfeats = nullptr, const char *bscores = nullptr, const char *cdtrack = nullptr, const char *famlinks = nullptr);	//uusing default file names
	
	void LoadData_real(const std::string &cddids, const std::string &spfeats, const std::string &genfeats, const std::string &bscores, const std::string &cdtrack, const std::string &famlinks);	//totaly customized data, 
	
	void Reset(void);
	void Reset(bool mem_realloc, const std::string &datadir, const char *cddids = nullptr, const char *spfeats = nullptr, const char *genfeats = nullptr, const char *bscores = nullptr, const char *cdtrack = nullptr, const char *famlinks = nullptr);
	void Reset(bool mem_realloc, const std::string &cddids, const std::string &spfeats, const std::string &genfeats, const std::string &bscores, const std::string &cdtrack, const std::string &famlinks);
	
private:
	
	TOfflCDStore m_CDStore;
	TOfflClusterStore m_ClusterStore;
	
};




class COfflArchData: public CArchIndex
{
	static constexpr const size_t TOTAL_SPARCH_ESTI = 28000;	//estimated domains
	static constexpr const size_t TOTAL_DOMARCH_ESTI = 80000;
public:
	static constexpr const char * __specific_arch_file = "specific_arch.txt";
	static constexpr const char * __supfam_arch_file = "superfamily_arch.txt";
	
	typedef CCompactStore<TSpDomArch, TOTAL_SPARCH_ESTI * sizeof(TSpDomArch) > TOfflSpArchStore;
	typedef CCompactStore<TDomArch, TOTAL_DOMARCH_ESTI * sizeof(TDomArch) > TOfflArchStore;
	
	COfflArchData(void):
		CArchIndex(), m_SpArchStore(), m_ArchStore() {};
	
	COfflArchData(const std::string &datadir, const char *sparchs = nullptr, const char *famarchs = nullptr):
		CArchIndex(), m_SpArchStore(), m_ArchStore()
	{LoadData(datadir, sparchs, famarchs);}
	
	void LoadData(const std::string &datadir, const char *sparchs = nullptr, const char *famarchs = nullptr);	//uusing default file names
	
	
	void Reset(void);
	void Reset(bool mem_realloc, const std::string &datadir, const char *sparchs = nullptr, const char *famarchs = nullptr);
	
private:
	
	TOfflSpArchStore m_SpArchStore;
	TOfflArchStore m_ArchStore;
};


#endif
