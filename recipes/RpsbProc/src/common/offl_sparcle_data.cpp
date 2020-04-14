#include <ncbi_pch.hpp>
#include "offl_sparcle_data.hpp"
#if defined(__DB_OFFLINE__)
#include "basealgo.hpp"
#else
#include <BasicUtils/basealgo.hpp>
#endif
#include <corelib/ncbifile.hpp>
#include <fstream>
#include <iostream>

USING_NCBI_SCOPE;
void COfflDomClusterData::Reset(void)
{
	CDomClusterIndex::Reset();
	m_CDStore.Reset();
	m_ClusterStore.Reset();
}

void COfflDomClusterData::Reset(bool mem_realloc, const std::string &datadir, const char *cddids, const char *spfeats, const char *genfeats, const char *bscores, const char *cdtrack, const char *famlinks)
{
	if (mem_realloc)
		Reset();
	else
	{
		CDomClusterIndex::Reset();
		m_CDStore.Clear();
		m_ClusterStore.Clear();
	}
	LoadData(datadir, cddids, spfeats, genfeats, bscores, cdtrack, famlinks);
}

void COfflDomClusterData::Reset(bool mem_realloc, const std::string &cddids, const std::string &spfeats, const std::string &genfeats, const std::string &bscores, const std::string &cdtrack, const std::string &famlinks)
{
	if (mem_realloc)
		Reset();
	else
	{
		CDomClusterIndex::Reset();
		m_CDStore.Clear();
		m_ClusterStore.Clear();
	}
	LoadData_real(cddids, spfeats, genfeats, bscores, cdtrack, famlinks);
}

void COfflDomClusterData::LoadData(const std::string &datadir, const char *cddids, const char *spfeats, const char *genfeats, const char *bscores, const char *cdtrack, const char *famlinks)
{
	
	if (m_CDStore.IsEmpty())	//not loaded yet, load it
	{
		ifstream dfstream;
		string buf;
		
		string
			_cddids = (cddids ? datadir + "/" + cddids : datadir + "/" + COfflDomClusterData::__cdd_ids_file),
			_cdtrack = (cdtrack ? datadir + "/" + cdtrack : datadir + "/" + COfflDomClusterData::__cdtrack_file),
			_famlinks =	(famlinks ? datadir + "/" + famlinks : datadir + "/" + COfflDomClusterData::__domfam_link_file),
			_spfeats = (spfeats ? datadir + "/" + spfeats : datadir + "/" + COfflDomClusterData::__spec_feats_file),
			_genfeats = (genfeats ? datadir + "/" + genfeats : datadir + "/" + COfflDomClusterData::__gen_feats_file),
			_bscores = (bscores ? datadir + "/" + bscores : datadir + "/" + COfflDomClusterData::__bs_thrlds_file);
			
		LoadData_real(_cddids, _spfeats, _genfeats, _bscores, _cdtrack, _famlinks);
	}
}

void COfflDomClusterData::LoadData_real(const string &cddids, const string &spfeats, const string &genfeats, const string &bscores, const string &cdtrack, const string &famlinks)
{
	//static constexpr const size_t TOTAL_CDS_ESTI = 52000;	//estimated domains
	//static constexpr const size_t TOTAL_CLSTS_ESTI = 6000;
	if (m_CDStore.IsEmpty())	//not loaded yet, load it
	{
		ifstream dfstream;
		string buf;
		
		CFile srcfile;
		srcfile.Reset(cddids);

		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{

			// -- cluster search
			vector< TCluster* > clst_ptrs;
			clst_ptrs.reserve(TOTAL_CLSTS_ESTI);
			
			// -- cd search, exclude sd
			vector< TDomain* > cd_ptrs;
			cd_ptrs.reserve(TOTAL_CDS_ESTI);
			
			// -- both cd and sd
			vector< TDomain* > dom_ptrs;
			dom_ptrs.reserve(TOTAL_CDS_ESTI);
			
			dfstream.open(srcfile.GetPath().c_str());
			
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				LTrimString(buf);
				if (!buf.empty() && '#' != buf[0])
				{
					
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					//unsigned int pssmid = (unsigned int)atoi(buf.substr(pos0, pos1 - pos0).c_str());
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t> (buf.substr(pos0, pos1 - pos0));
					
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					string tmp(buf.substr(pos0, pos1 - pos0));
					TrimString(tmp);
					if ('c' == tmp[0] && 'l' == tmp[1] && (tmp[2] >= '0' && tmp[2] <= '9'))	//cluster
					{
						// is cluster
						TCluster * p_clst = m_ClusterStore.Append();
						p_clst->m_uiPssmId = pssmid;
						p_clst->m_strAccession = move(tmp);
						p_clst->m_iClusterId = NStr::StringToNumeric<ClusterId_t> (p_clst->m_strAccession.substr(2));
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						p_clst->m_strShortName = buf.substr(pos0, pos1 - pos0);
						TrimString(p_clst->m_strShortName);
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						p_clst->m_strDefline = buf.substr(pos0, pos1 - pos0);
						TrimString(p_clst->m_strDefline);
						// -- no need -- cluster length is always 0
						//pos0 = pos1 + 1;
						//iterClst->second.m_uiLength = NStr::StringToNumeric<unsigned int>(buf.substr(pos0));
						clst_ptrs.emplace_back(p_clst);
					}
					else	//cd
					{
						TDomain * p_cd = m_CDStore.Append();
						p_cd->m_uiPssmId = pssmid;
						p_cd->m_strAccession = buf.substr(pos0, pos1 - pos0);
						TrimString(p_cd->m_strAccession);
						if (isdigit(p_cd->m_strAccession[2]))	//cdxxx, sdxxx or clxxx
						{
							if ('d' == p_cd->m_strAccession[1])	//cd or sd
							{
								if ('c' == p_cd->m_strAccession[0])	//curated
								{
									p_cd->m_bCurated = true;
									cd_ptrs.emplace_back(p_cd);
								}
									
								else if ('s' == p_cd->m_strAccession[0])	//curated
									p_cd->m_bIsStructDom = true;
							}
						}
						
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						p_cd->m_strShortName = buf.substr(pos0, pos1 - pos0);
						TrimString(p_cd->m_strShortName);
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						p_cd->m_strDefline = buf.substr(pos0, pos1 - pos0);
						TrimString(p_cd->m_strDefline);
						pos0 = pos1 + 1;
						string tmp1(buf.substr(pos0));
						TrimString(tmp1);
						p_cd->m_uiLength = NStr::StringToNumeric<SeqLen_t> (tmp1);
						dom_ptrs.emplace_back(p_cd);
					}
				}
			}
			dfstream.close();
			
			// -- now create maps, 
			clst_ptrs.shrink_to_fit();	//cluster
			cd_ptrs.shrink_to_fit();	//curated
			dom_ptrs.shrink_to_fit();	//all domains
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": cd_ptrs.size() = " << cd_ptrs.size() << ", clst_ptrs.size() = " << clst_ptrs.size() << endl;
#endif
// ***********************************************************/

			SetPssmId2CdPtrs(move(dom_ptrs));
			SetAcxn2CdPtrs(move(cd_ptrs));


			SetPssmId2ClusterPtrs(clst_ptrs);
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": cd_ptrs.size() = " << cd_ptrs.size() << ", clst_ptrs.size() = " << clst_ptrs.size() << endl;
#endif
// ***********************************************************/
			SetClusterId2ClusterPtrs(move(clst_ptrs));
		}
		
		// -- CDTrack information just for parent and root of domains
		srcfile.Reset(cdtrack);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			dfstream.open(srcfile.GetPath().c_str());
			
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				LTrimString(buf);

				if (!buf.empty() && '#' != buf[0])
				{
					// -- accession
					size_t pos0 = 0, pos1 = buf.find(' ', pos0);

					string currAcc = buf.substr(pos0, pos1 - pos0);

					TrimString(currAcc);
					
					// -- title
					while(buf[pos1] <= ' ') ++pos1;
					pos0 = pos1;
					pos1 = buf.find(' ', pos0);
					
					
					// -- pssmid
					while(' ' == buf[pos1]) ++pos1;
					pos0 = pos1;
					pos1 = buf.find(' ', pos0);
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t> (buf.substr(pos0, pos1 - pos0));
					//unsigned int pssmid = (unsigned int)atoi(buf.substr(pos0, pos1 - pos0).c_str());
					TDomain * p_dom = const_cast< TDomain* > (FindCdInfo(pssmid));
					
					if (nullptr != p_dom)
					{
						// -- parent acc
						while(buf[pos1] <= ' ') ++pos1;
						pos0 = pos1;
						pos1 = buf.find(' ', pos0);
						
						string parentAcc = buf.substr(pos0, pos1 - pos0);
						TrimString(parentAcc);
						if ("N/A" != parentAcc)
						{
							if (parentAcc == p_dom->m_strAccession)
								p_dom->m_uiHierarchyParent = pssmid;
							else
							{
								const TDomain * ppcd = FindCdInfo(parentAcc);
								if (nullptr != ppcd) 
									p_dom->m_uiHierarchyParent = ppcd->m_uiPssmId;
							}
						}

						// -- root acc
						while(buf[pos1] <= ' ') ++pos1;
						pos0 = pos1;
						pos1 = buf.find(' ', pos0);
						string rootAcc = buf.substr(pos0, pos1 - pos0);
						TrimString(rootAcc);
						if (rootAcc == parentAcc)
							p_dom->m_uiHierarchyRoot = p_dom->m_uiHierarchyParent;
						else if (rootAcc == p_dom->m_strAccession)
							p_dom->m_uiHierarchyRoot = pssmid;
						else
						{
							const TDomain * prcd = FindCdInfo(rootAcc);
							if (nullptr != prcd) 
								p_dom->m_uiHierarchyParent = prcd->m_uiPssmId;
							
						}
					}
				}
			}	//dfstream
			dfstream.close();
		}
		
		// -- get domain superfamily associations
		srcfile.Reset(famlinks);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			dfstream.open(srcfile.GetPath().c_str());
  		
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				LTrimString(buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					string tmp(buf.substr(pos0, pos1 - pos0));
					TrimString(tmp);
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t> (tmp);
					TDomain * p_dom = const_cast< TDomain* > (FindCdInfo(pssmid));
					
					if (nullptr != p_dom)
					{
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						pos0 = pos1 + 1;
						//pos1 = buf.find('\t', pos0);
						tmp = buf.substr(pos0);	//
						TrimString(tmp);
						p_dom->m_uiClusterPssmId = NStr::StringToNumeric<PssmId_t>(tmp);
						if (p_dom->m_uiClusterPssmId > 0)	//valid cluster pssmid
						{
							const TCluster *p_clst = FindClusterByPssmId(p_dom->m_uiClusterPssmId);
							if (nullptr != p_clst)
								p_dom->m_iClusterId = p_clst->m_iClusterId;
							else if (p_dom->m_uiClusterPssmId == pssmid)
								p_dom->m_iClusterId = SINGLEMEMBERCLUSTER;
						}
						p_dom->m_bMultiDom = false;
					}
				}
			}
			
			dfstream.close();
		}
		
		TDomSite featValue;
		// -- specific site annotations
		srcfile.Reset(spfeats);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			dfstream.open(srcfile.GetPath().c_str());
			
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				LTrimString(buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					string tmp(buf.substr(pos0, pos1 - pos0));
					TrimString(tmp);
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t>(tmp);
					TDomain * p_dom = const_cast< TDomain* > (FindCdInfo(pssmid));
					
					if (nullptr != p_dom)
					{
						p_dom->m_lstSpecificFeatures.emplace_back(featValue);
						TDomSite &tgt =  *(p_dom->m_lstSpecificFeatures.rbegin());
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//accession
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//shortname
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//index
						
						tmp = buf.substr(pos0, pos1 - pos0);
						TrimString(tmp);
						tgt.m_iIndex = NStr::StringToNumeric<int>(tmp);
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//title
						
						tgt.m_strTitle = buf.substr(pos0, pos1 - pos0);
						TrimString(tgt.m_strTitle);
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//Motif
						
						if ('0' != buf[pos0])
						{
							//tgt.SetMotifStr(buf.substr(pos0, pos1 - pos0).c_str());
							tgt.m_strMotif = buf.substr(pos0, pos1 - pos0);
							TrimString(tgt.m_strMotif);
						}
						
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//structure based evidence present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::STRUCTURE_BASED_EVIDENCE;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//reference based evidence present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::REFERENCE_BASED_EVIDENCE;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//additional comments present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::ADDITIONAL_COMMENTS;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//site coordinates
						
						vector<TSignedSeqPos> vecSitePos;	//to store coordinates
						
						vecSitePos.reserve((pos1 - pos0) * 3);	//estimated
						
						size_t pos_c = buf.find(',', pos0);
						
						while (pos_c < pos1)
						{
							vecSitePos.emplace_back(NStr::StringToNumeric<SeqPos_t>(buf.substr(pos0, pos_c - pos0)));
							pos0 = pos_c + 1;
							pos_c = buf.find(',', pos0);
						}
						
						// -- last one
						vecSitePos.emplace_back(NStr::StringToNumeric<SeqPos_t>(buf.substr(pos0, pos1 - pos0)));
						
						tgt.SetData(vecSitePos);
						
						tgt.m_iCompleteSize = (int)vecSitePos.size();
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//type
						
						if (string::npos == pos1)	//no other field
							tgt.m_iType = NStr::StringToNumeric<int>(buf.substr(pos0));
						else	//assume has motif string added
							tgt.m_iType = NStr::StringToNumeric<int>(buf.substr(pos0, pos1 - pos0));
					}
				}
			}
			
			dfstream.close();
		}	
			
		// -- get generic site annotations
		srcfile.Reset(genfeats);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			dfstream.open(srcfile.GetPath().c_str());
  		
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t> (buf.substr(pos0, pos1 - pos0));
					TDomain * p_dom = const_cast< TDomain* > (FindCdInfo(pssmid));
					if (nullptr != p_dom)
					{
						p_dom->m_lstGenericFeatures.push_back(featValue);
						TDomSite &tgt =  *(p_dom->m_lstGenericFeatures.rbegin());
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//accession
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//shortname
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//index
						
						tgt.m_iIndex = NStr::StringToNumeric<int>(buf.substr(pos0, pos1 - pos0));
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//title
						
						tgt.m_strTitle = buf.substr(pos0, pos1 - pos0);
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//Motif
						
						if ('0' != buf[pos0])
						{
							//tgt.SetMotifStr(buf.substr(pos0, pos1 - pos0).c_str());
							tgt.m_strMotif = buf.substr(pos0, pos1 - pos0);
							TrimString(tgt.m_strMotif);
						}
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//structure based evidence present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::STRUCTURE_BASED_EVIDENCE;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//reference based evidence present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::REFERENCE_BASED_EVIDENCE;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//additional comments present
						
						if ('1' == buf[pos0])
							tgt.m_flags |= TDomSite::ADDITIONAL_COMMENTS;
							
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//site coordinates
						
						vector<SeqPos_t> vecSitePos;	//to store coordinates
						
						vecSitePos.reserve((pos1 - pos0) * 3);	//estimated
						
						size_t pos_c = buf.find(',', pos0);
						
						while (pos_c < pos1)
						{
							vecSitePos.push_back(NStr::StringToNumeric<SeqPos_t>(buf.substr(pos0, pos_c - pos0)));
							pos0 = pos_c + 1;
							pos_c = buf.find(',', pos0);
						}
						
						// -- last one
						vecSitePos.push_back(NStr::StringToNumeric<SeqPos_t>(buf.substr(pos0, pos1 - pos0)));
						
						tgt.SetData(vecSitePos);
						
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);	//type
						
						if (string::npos == pos1)	//no other field
							tgt.m_iType = NStr::StringToNumeric<int>(buf.substr(pos0));
						else	//assume has motif string added
							tgt.m_iType = NStr::StringToNumeric<int>(buf.substr(pos0, pos1 - pos0));
					}
				}
			}

			dfstream.close();

		}
			
		// -- read bitscore thresholds
		srcfile.Reset(bscores);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{

			dfstream.open(srcfile.GetPath().c_str());
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					PssmId_t pssmid = NStr::StringToNumeric<PssmId_t>(buf.substr(pos0, pos1 - pos0));
					
					TDomain * p_dom = const_cast< TDomain* > (FindCdInfo(pssmid));
					if (nullptr != p_dom)
					{
						// -- accession, no need
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
						
						// -- score
						pos0 = pos1 + 1;
						pos1 = buf.find('\t', pos0);
  		
						if (string::npos == pos1)
							p_dom->m_dMinBitScore = NStr::StringToNumeric<double>(buf.substr(pos0));
						else
							p_dom->m_dMinBitScore = NStr::StringToNumeric<double>(buf.substr(pos0, pos1 - pos0));
					}
				}
			}
			dfstream.close();

		}
	}
}

void COfflArchData::LoadData(const std::string &datadir, const char *sparchs, const char *famarchs)
{
	if (m_SpArchStore.IsEmpty())	//not loaded yet, load it
	{
		ifstream dfstream;
		string buf;
		
		CFile srcfile;
		// -- Specific architectures
		srcfile.Reset(sparchs ? datadir + "/" + sparchs : datadir + "/" + COfflArchData::__specific_arch_file);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			vector< TSpDomArch* > sp_arch_ptrs;
			sp_arch_ptrs.reserve(140000);
			
			
			dfstream.open(srcfile.GetPath().c_str());
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					ArchId_t archid = NStr::StringToNumeric<ArchId_t>(buf.substr(pos0, pos1 - pos0));
					
					// -- get string
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					
					TSpDomArch * p_sparch = m_SpArchStore.Append(archid, buf.substr(pos0, pos1 - pos0));
					
					// -- name
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					p_sparch->m_strName = buf.substr(pos0, pos1 - pos0);
					
					// -- label
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					p_sparch->m_strLabel = buf.substr(pos0, pos1 - pos0);
					
					// -- review level
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					
					p_sparch->m_strReviewLevel = buf.substr(pos0, pos1 - pos0);
						
					// -- associated superfamily architecture
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					if (string::npos == pos1)
						p_sparch->m_uiSupFamArchId = NStr::StringToNumeric<ArchId_t>(buf.substr(pos0));
					else
						p_sparch->m_uiSupFamArchId = NStr::StringToNumeric<ArchId_t>(buf.substr(pos0, pos1 - pos0));
					
					sp_arch_ptrs.emplace_back(p_sparch);
				}
			}
			dfstream.close();
			sp_arch_ptrs.shrink_to_fit();
			SetArchId2SpPtrs(sp_arch_ptrs);
			SetArchStr2SpPtrs(move(sp_arch_ptrs));
		}
		
		// -- read bitscore thresholds
		srcfile.Reset(famarchs ? datadir + "/" + famarchs : datadir + "/" + COfflArchData::__supfam_arch_file);
		if (!srcfile.Exists())
			throw CSimpleException(__FILE__, __LINE__, "Data file " + srcfile.GetPath() + " does not exist");
		else
		{
			vector< TDomArch* > arch_ptrs;
			arch_ptrs.reserve(312000);
			dfstream.open(srcfile.GetPath().c_str());
			while (dfstream.good())
			{
				buf.clear();
				getline(dfstream, buf);
				if (!buf.empty() && '#' != buf[0])
				{
					size_t pos0 = 0, pos1 = buf.find('\t', pos0);
					ArchId_t archid = NStr::StringToNumeric<ArchId_t>(buf.substr(pos0, pos1 - pos0));
					
					// -- get string
					pos0 = pos1 + 1;
					pos1 = buf.find('\t', pos0);
					if (string::npos == pos1)
						pos1 = buf.size();
					
					TDomArch * p_arch = m_ArchStore.Append(archid, buf.substr(pos0, pos1 - pos0));
					arch_ptrs.emplace_back(p_arch);
				}
			}
			dfstream.close();
			arch_ptrs.shrink_to_fit();
			SetArchId2FamPtrs(arch_ptrs);
			SetArchStr2FamPtrs(move(arch_ptrs));
		}
	}
}

void COfflArchData::Reset(void)
{
	CArchIndex::Reset();
	m_SpArchStore.Reset();
	m_ArchStore.Reset();
}
void COfflArchData::Reset(bool mem_realloc, const std::string &datadir, const char *sparchs, const char *famarchs)
{
	if (mem_realloc)
		Reset();
	else
	{
		CArchIndex::Reset();
		m_SpArchStore.Clear();
		m_ArchStore.Clear();
	}
	LoadData(datadir, sparchs, famarchs);
}
