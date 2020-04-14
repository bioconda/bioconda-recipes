#include <ncbi_pch.hpp>
#include "cdalignproc_base.hpp"

#if defined(__DB_OFFLINE__)
//#include "biodata_core.hpp"
//#include "objutils.hpp"
#include "basealgo.hpp"
//#include "compactstore.hpp"
//#include "ptrmap.hpp"
#else
//#include <DataUtils/biodata_core.hpp>
//#include <NcbiBase/objutils.hpp>
#include <BasicUtils/basealgo.hpp>
//#include <BasicUtils/compactstore.hpp>
//#include <BasicUtils/ptrmap.hpp>
#endif

USING_NCBI_SCOPE;


array<int, TDomSrcCount::TOTALSRCS> TDomSrcCount::MAXCOUNTS = {1, 1, 1, 1, 1, 1, 1};

array<const char * , TDomSrcCount::TOTALSIGS > TDomSrcCount::DOMSRCSIGS = {"CD", "PFAM", "TIGR", "COG", "KOG", "SMART", "PRK", "CHL", "MTH", "PHA", "PLN", "PTZ"};


TDomSrcCount::ESrcIdx TDomSrcCount::DomAccType(const string &acxn)
{
	size_t iSig = 0, iChar = 0, iAccChar = 0, acclen = acxn.size();
	

	while (iSig < TOTALSIGS && 0 != DOMSRCSIGS[iSig][iChar] && iAccChar < acclen)
	{
		char accChar = acxn[iAccChar];
		if ('a' <= accChar && 'z' >= accChar) accChar -= 0x20;	//to uppercase
		if (accChar == DOMSRCSIGS[iSig][iChar])
		{
			++iAccChar;
			++iChar;
		}
		else
		{
			++iSig;
			iChar = 0;
			iAccChar = 0;
		}
	}

	if (iSig < ePRK)
		return static_cast<ESrcIdx> (iSig);
	else if (iSig < TOTALSIGS)
		return ePRK;
	else
		return TOTALSRCS;
}

TDomSrcCount::TDomSrcCount(const int * mcounts, size_t nums):
	m_SrcCounter(), m_max_counts(TDomSrcCount::MAXCOUNTS)
{
	if (nullptr != mcounts)
	{
		if (nums > TOTALSRCS)
			nums = TOTALSRCS;
		copy(mcounts, mcounts + nums, m_max_counts.begin());
	}
}
	

bool TDomSrcCount::CountSrc(const string &acxn)
{
	ESrcIdx srctype = DomAccType(acxn);
	if (TOTALSRCS == srctype) return true;	//unknown src always enter.
	
	map<ESrcIdx, int> :: iterator iter = m_SrcCounter.emplace(srctype, 0).first;

	if (iter->second >= m_max_counts[srctype]) return false;
	++iter->second;
	return true;
}


SeqLen_t CCdAlignProcessor::SortReadingFrames(vector<size_t> rfIndice[READINGFRAME::TOTAL_RFS], const TDomQuery &rSrc)
{
	// -- to calculate minus strand reading frame, we need the length of query sequence

	SeqLen_t qlen = 0;
	if (rSrc.m_uiSeqLen > 0)
		qlen = rSrc.m_uiSeqLen;
	else if (!rSrc.m_strSeqData.empty())
		qlen = rSrc.m_strSeqData.size();
	
	
	if (qlen > 0)	//calculate
		for (size_t idx = 0, len = rSrc.m_vecAlignments.size(); idx < len; ++idx)
		{
			//int alignedLen = rSrc.m_vecAlignments[idx].m_ReadingFrame >> 2;
			//int rfidx = rSrc.m_vecAlignments[idx].m_ReadingFrame & RF_SIZE;
			//if (alignedLen > 0)
			//	rfidx = (qlen - 1 - (alignedLen * RF_SIZE + rfidx)) % RF_SIZE + RF_SIZE;
      //
			//rfIndices[rfidx].emplace_back(idx);
			rfIndice[rSrc.m_vecAlignments[idx].GetRFIdx(qlen)].emplace_back(idx);
		}
	else	//should not happen
		THROW_SIMPLE("Cannot sort reading frames - query sequence length unknown"); 
	return qlen;
}


void CCdAlignProcessor::Calculate(vector<TDomSeqAlignment> &aligns, const vector<size_t> &selIdx, TDomSeqAlignIndex &dst, vector<PssmId_t> &missed, const int * stdmax, size_t nmax) const
{
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering Calculate" << endl;
#endif
// **************************************************/
	vector <CSegSet> vecGaps;
	vecGaps.emplace_back(CSegSet());	//sentinel
	size_t gapIdx = 0;
	vector <TDomAlignFacility> vecPrivileged, vecNonMulti, vecLongMultiDom, vecMultiDom, vecConcise, vecSDs;
	// -- added 12/6/2016: Concise view now should always include curated models (if available).
	if (!selIdx.empty())
	{
		TDomAlignFacility pholder;
		TDomAlignOrderByEValue sortingEV;
			
		vector<size_t> alignIdx;
		vector<size_t> missedIdx;

		for (vector<size_t> :: const_iterator iterIdx = selIdx.begin(), iterIdxEnd = selIdx.end(); iterIdx != iterIdxEnd; ++iterIdx)
		{
			TDomSeqAlignment &rAlign = aligns[*iterIdx];

			if (rAlign.m_vecSStarts.empty()) continue;	//somehow live blast search contains empty aligns.
			const TDomain *pCdInfo = nullptr;
#if defined(_MT)			
			{{
				CReadLockGuard rlck(m_mtxDomClusterIdx);
#endif
				pCdInfo = m_pDomSrc->FindCdInfo(rAlign.m_uiPssmId);
#if defined(_MT)
			}}
#endif
			if (nullptr == pCdInfo)	//unrecognized CD
			{
				missed.emplace_back(rAlign.m_uiPssmId);
				missedIdx.emplace_back(*iterIdx);
				//alignIdx.emplace_back(*iterIdx);
				continue;
			}
			rAlign.m_dSeqIdentity = (double)(rAlign.m_iNumIdent) / (double)(pCdInfo->m_uiLength) * 100.0;
			
			int iNMissing = *(rAlign.m_vecSStarts.begin());
			int iCMissing = pCdInfo->m_uiLength - (*(rAlign.m_vecSStarts.rbegin()) + *(rAlign.m_vecLens.rbegin()) - 1);
			
			rAlign.m_dNMissing = (double)(iNMissing) / (double)(pCdInfo->m_uiLength);
			rAlign.m_dCMissing = (double)(iCMissing) / (double)(pCdInfo->m_uiLength);
			rAlign.m_uiAlignedLen = pCdInfo->m_uiLength - iNMissing - iCMissing;
			rAlign.m_dAlignedPct = (double)(rAlign.m_uiAlignedLen) / (double)(pCdInfo->m_uiLength) * 100.0;
			rAlign.m_bSpecQualified = (rAlign.m_dBitScore >= pCdInfo->m_dMinBitScore);
			// -- sorting
			
			pholder.pAlign = &(rAlign);
			pholder.ulIdx = *iterIdx;
			pholder.pCdInfo = pCdInfo;
			pholder.ulGapsIdx = string::npos;
			
			rAlign.CalcMasterGaps(TDomSeqAlignment::GAP_THRESHOLD, vecGaps[gapIdx]);
			
			if (!vecGaps[gapIdx].IsEmpty())
			{
				pholder.ulGapsIdx = gapIdx;
				++gapIdx;
				vecGaps.emplace_back(CSegSet());
			}
		
			if (pCdInfo->m_bIsStructDom)
			{
				rAlign.m_iRepClass = 0x2;
				vecSDs.emplace_back(pholder);
			}
			// -- from 4/4/2018 m_bMultiDom should be ignored.
			else// if (pCdInfo->m_bCurated || !pCdInfo->m_bMultiDom)	//curated or non-multi are mixed together
			{
				rAlign.m_iRepClass = 0;
				vecNonMulti.emplace_back(pholder);
			}    
			// -- from 4/4/2018 m_bMultiDom should be ignored.
			//else
			//{
			//	rAlign.m_iRepClass = 1;
			//	vecMultiDom.emplace_back(pholder);
			//}
		}
		// -- online version may need to handle missed and load from cdtrack PssmId2Bioseq
		if (!missed.empty())
		{
			x_LoadMissingDomains(missed);
			for (size_t i = 0, ie = missed.size(); i < ie; ++i)
			{
				const TDomain *pCdInfo = nullptr;
#if defined(_MT)
				{{
					CReadLockGuard rlck(m_mtxDomClusterIdx);
#endif
					pCdInfo = m_pDomSrc->FindCdInfo(missed[i]); 
#if defined(_MT)
				}}
#endif

				if (nullptr != pCdInfo)
				{
					TDomSeqAlignment &rAlign = aligns[missedIdx[i]];
					rAlign.m_dSeqIdentity = (double)(rAlign.m_iNumIdent) / (double)(pCdInfo->m_uiLength) * 100.0;
					int iNMissing = *(rAlign.m_vecSStarts.begin());
					int iCMissing = pCdInfo->m_uiLength - (*(rAlign.m_vecSStarts.rbegin()) + *(rAlign.m_vecLens.rbegin()) - 1);
					
					rAlign.m_dNMissing = (double)(iNMissing) / (double)(pCdInfo->m_uiLength);
					rAlign.m_dCMissing = (double)(iCMissing) / (double)(pCdInfo->m_uiLength);
					rAlign.m_uiAlignedLen = pCdInfo->m_uiLength - iNMissing - iCMissing;
					rAlign.m_dAlignedPct = (double)(rAlign.m_uiAlignedLen) / (double)(pCdInfo->m_uiLength) * 100.0;
					rAlign.m_bSpecQualified = (rAlign.m_dBitScore >= pCdInfo->m_dMinBitScore);
					// -- sorting
			
					pholder.pAlign = &(rAlign);
					pholder.ulIdx = missedIdx[i];
					pholder.pCdInfo = pCdInfo;
					pholder.ulGapsIdx = string::npos;
					
					rAlign.CalcMasterGaps(TDomSeqAlignment::GAP_THRESHOLD, vecGaps[gapIdx]);
					if (!vecGaps[gapIdx].IsEmpty())
					{
						pholder.ulGapsIdx = gapIdx;
						++gapIdx;
						vecGaps.emplace_back(CSegSet());
					}
		  		
					if (pCdInfo->m_bIsStructDom)
					{
						rAlign.m_iRepClass = 0x2;
						vecSDs.emplace_back(pholder);
					}
					// -- from 4/4/2018 m_bMultiDom should be ignored.
					else// if (pCdInfo->m_bCurated || !pCdInfo->m_bMultiDom)	//curated or non-multi are mixed together
					{
						rAlign.m_iRepClass = 0;
						vecNonMulti.emplace_back(pholder);
					}
					// -- from 4/4/2018 m_bMultiDom should be ignored.
					//else
					//{
					//	rAlign.m_iRepClass = 1;
					//	vecMultiDom.emplace_back(pholder);
					//}		
				}
			}
		}
		map<int, TDomSrcCount> dimAccTypeCount;//, dimAccTypeCount_multi;	//one for single doms and one for multi-doms
		pair<int, TDomSrcCount> srccnt(0, TDomSrcCount(stdmax, nmax));
	  // -- sort
		sort(vecNonMulti.begin(), vecNonMulti.end(), sortingEV);
		for (vector <TDomAlignFacility>::const_iterator iter = vecNonMulti.begin(), iterEnd = vecNonMulti.end(); iterEnd != iter; ++iter)
		{
			CSegSet s_overlaps;	// to calculate combined overlap region
			
			CSegSet thisSegs;
			thisSegs.AddSeg(iter->pAlign->m_iFrom, iter->pAlign->m_iTo);
			if (string::npos != iter->ulGapsIdx)
				thisSegs.Clip(vecGaps[iter->ulGapsIdx]);
			
			int iThisLength = (int)thisSegs.GetTotalResidues();
			double dThisLength = (double)iThisLength;

			for (vector <TDomAlignFacility>::const_iterator iterRep = vecConcise.begin(), iterRepEnd = vecConcise.end(); iterRepEnd != iterRep; ++iterRep)
			{
				CSegSet repSegs;
				repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
				
				if (string::npos != iterRep->ulGapsIdx)
					repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
				
				int iRepLength = (int)repSegs.GetTotalResidues();
				double dRepLength = (double)iRepLength;
				
				// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
				
				CSegSet olSegs(thisSegs);
				olSegs.Cross(repSegs);
				
				int iOverlapLen = (int)olSegs.GetTotalResidues();
				double dOverlapLen = (double)iOverlapLen;
				
				if (dOverlapLen > 0)
				{

					if (dOverlapLen / dThisLength > 0.5 || (dOverlapLen / dRepLength > 0.5 && iter->pCdInfo->m_iClusterId == iterRep->pCdInfo->m_iClusterId))	//mutually overlap > 0.5
					//if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
					{
						iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
						iter->pAlign->m_bRep = false;
					
						goto labelNextNonMulti;
					}
				}
				s_overlaps.Merge(olSegs);

			}
	
			if ((iter->pAlign->m_bRep = (((double)(s_overlaps.GetTotalResidues()) / dThisLength) < 0.5)))	//new region
			{
				iter->pAlign->m_iRegionIdx = (int)vecConcise.size();

				vecConcise.emplace_back(*iter);

			}
		labelNextNonMulti:
			srccnt.first = iter->pAlign->m_iRegionIdx;
			map<int, TDomSrcCount> :: iterator iterSrcCounter = dimAccTypeCount.emplace(srccnt).first;

			if (iterSrcCounter->second.CountSrc(iter->pCdInfo->m_strAccession))
			{
				dst.m_vecStdIndice.emplace_back(iter->ulIdx);
				iter->pAlign->m_bRep = true;
				if (iter->pCdInfo->m_bCurated)
					dst.m_vecQualifiedFeatIndice.emplace_back(iter->ulIdx);
				
			}
			
			
			dst.m_vecSortedIndice.emplace_back(iter->ulIdx);
		}
	

		// -- When done, convert setup dst.m_vecConciseIndice
		size_t ttlWinners = vecConcise.size();
		if (ttlWinners > 0)
		{
			dst.m_vecConciseIndice.reserve(ttlWinners);
			for (size_t i = 0; i < ttlWinners; ++i)
				dst.m_vecConciseIndice.emplace_back(vecConcise[i].ulIdx);
		}
		vecPrivileged.clear();
		//sort(vecMultiDom.begin(), vecMultiDom.end(), sortingEV);
		//for (vector <TDomAlignFacility>::const_iterator iter = vecMultiDom.begin(), iterEnd = vecMultiDom.end(); iterEnd != iter; ++iter)
		//{
		//	CSegSet s_overlaps;	// to calculate combined overlap region
		//	CSegSet m_overlaps;
		//	
		//	double dSOverlap = 0.0;	//put here for scope reason
		//	double dMOverlap = 0.0;
		//	
		//	CSegSet thisSegs;
		//	thisSegs.AddSeg(iter->pAlign->m_iFrom, iter->pAlign->m_iTo);
		//	if (string::npos != iter->ulGapsIdx)
		//		thisSegs.Clip(vecGaps[iter->ulGapsIdx]);
		//	
		//	int iThisLength = (int)thisSegs.GetTotalResidues();
		//	double dThisLength = (double)iThisLength;
		//	
		//	//double dThisLength = (double)(iter->pAlign->m_iTo - iter->pAlign->m_iFrom + 1);
		//	for (vector <TDomAlignFacility>::const_iterator iterRep = vecConcise.begin(), iterRepEnd = vecConcise.end(); iterRepEnd != iterRep; ++iterRep)
		//	{
		//		if (!(iterRep->pAlign->m_iFrom > iter->pAlign->m_iTo || iterRep->pAlign->m_iTo < iter->pAlign->m_iFrom))	//overlap
		//		{
		//			CSegSet repSegs;
		//			repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
		//			
		//			if (string::npos != iterRep->ulGapsIdx)
		//				repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
		//			
		//			int iRepLength = (int)repSegs.GetTotalResidues();
		//			double dRepLength = (double)iRepLength;
		//			
		//			// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
		//			
		//			CSegSet olSegs(thisSegs);
		//			olSegs.Cross(repSegs);
		//			
		//			int iOverlapLen = (int)olSegs.GetTotalResidues();
		//			
		//			double dOverlapLen = (double)iOverlapLen;
		//			
		//			if (0 == iterRep->pAlign->m_iRepClass)	//single
		//			{
		//				s_overlaps.Merge(olSegs);
		//			}
		//			else	//multi
		//			{
		//				if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
		//				{
		//					iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
		//					iter->pAlign->m_bRep = false;
		//					goto labelNextMulti;
		//				}
		//				m_overlaps.Merge(olSegs);
		//			}
		//		}
		//	}
		//	
		//	
		//	for (vector <TDomAlignFacility>::const_iterator iterRep = vecPrivileged.begin(), iterRepEnd = vecPrivileged.end(); iterRepEnd != iterRep; ++iterRep)
		//	{
		//		if (!(iterRep->pAlign->m_iFrom > iter->pAlign->m_iTo || iterRep->pAlign->m_iTo < iter->pAlign->m_iFrom))	//overlap
		//		{
		//			
		//			CSegSet repSegs;
		//			repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
		//			
		//			if (string::npos != iterRep->ulGapsIdx)
		//				repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
		//			
		//			int iRepLength = (int)repSegs.GetTotalResidues();
		//			double dRepLength = (double)iRepLength;
		//			
		//			// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
		//			
		//			CSegSet olSegs(thisSegs);
		//			olSegs.Cross(repSegs);
		//			
		//			int iOverlapLen = (int)olSegs.GetTotalResidues();
		//			
		//			double dOverlapLen = (double)iOverlapLen;
		//			
		//			if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
		//			{
		//				iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
		//				iter->pAlign->m_bRep = false;
		//				goto labelNextMulti;
		//			}
		//			m_overlaps.Merge(olSegs);
		//		}
		//	}
		//	
		//	dSOverlap = (double)(s_overlaps.GetTotalResidues()) / dThisLength;
		//	dMOverlap = (double)(m_overlaps.GetTotalResidues()) / dThisLength;
    //
		//	if (dMOverlap <= 0.5)	//new multi-dom region
		//	{
		//		if ((dSOverlap <= 0.5 && iter->pAlign->m_dAlignedPct > 50.0) || iter->pAlign->m_bSpecQualified)	//rep!
		//		{
		//			iter->pAlign->m_iRegionIdx = dst.m_vecConciseIndice.size() + vecPrivileged.size();
		//			iter->pAlign->m_bRep = true;
		//			
		//			dst.m_vecConciseIndice.emplace_back(iter->ulIdx);
		//			vecConcise.emplace_back(*iter);
		//		}
		//		vecPrivileged.emplace_back(*iter);
		//	}
		//labelNextMulti:
		//	
		//	map<int, TDomSrcCount> :: iterator iterSrcCounter = dimAccTypeCount_multi.emplace(iter->pAlign->m_iRegionIdx, TDomSrcCount()).first;
		//	if (iterSrcCounter->second.CountSrc(iter->pCdInfo->m_strAccession))
		//		dst.m_vecStdIndice.emplace_back(iter->ulIdx);
		//	
		//	dst.m_vecSortedIndice.emplace_back(iter->ulIdx);
		//
		//}
		// -- to avoid empty concise
		
		if (!dst.m_vecSortedIndice.empty())
		{
			if (dst.m_vecConciseIndice.empty())
			{
				size_t iEnd = vecPrivileged.size();
				dst.m_vecConciseIndice.reserve(iEnd);
				for (size_t i = 0; i < iEnd; ++i)
				{
					dst.m_vecConciseIndice.emplace_back(vecPrivileged[i].ulIdx);
					vecPrivileged[i].pAlign->m_bRep = true;
				}
			}
			
			if (dst.m_vecStdIndice.empty())
			{
				dst.m_vecStdIndice = dst.m_vecSortedIndice;
			}
		}
		
		// -- finally calculate SDs
		// -- SDs: models are sorted according to evalues, each model reserve their regions on the query sequence. that would need to change the from/to and the aligned segments. Features are 
		// -- then mapped to the query from these regions -- to guarantee non-redundency. Proposed by Aron.
		// -- implementation: calculate a restriction segset for SD models, which will be used later to trim the sites first
		if (!vecSDs.empty())
		{
			sort(vecSDs.begin(), vecSDs.end(), sortingEV);
			//vecConcise.clear();
			dst.m_vecSDIndice.clear();
			dst.m_vecSDIndice.reserve(vecSDs.size());
			CSegSet covered_regions;
			
			for (vector <TDomAlignFacility>::const_iterator iter = vecSDs.begin(), iterEnd = vecSDs.end(); iterEnd != iter; ++iter)
			{

				CSegSet sdSegSet;
				sdSegSet.AddSeg(0, iter->pCdInfo->m_uiLength - 1);

				iter->pAlign->MapSegSet(sdSegSet);
				
				sdSegSet.Clip(covered_regions);
				
				if (!sdSegSet.IsEmpty())
				{
					iter->pAlign->m_ClipSet.Clear();
					const CSegSet::TSegs& sdSegs = sdSegSet.GetSegs();
					
					for (CSegSet::TSegs::const_iterator iterSeg = sdSegs.begin(), iterSegEnd = sdSegs.end(); iterSegEnd != iterSeg; ++iterSeg)
					{
						iter->pAlign->m_ClipSet.AddSeg(iterSeg->ori_from, sdSegSet.GetOriTo(iterSeg));
					}
					covered_regions.Merge(sdSegSet);
					dst.m_vecSDIndice.emplace_back(iter->ulIdx);
				}
			}
		}
	}
}

void CCdAlignProcessor::Calculate(vector<TDomSeqAlignment> &aligns, TDomSeqAlignIndex &dst, vector<PssmId_t> &missed, const int * stdmax, size_t nmax) const
{
	size_t ttl = aligns.size();
	vector<size_t> selIdx(ttl);
	for (size_t i = 0; i < ttl; ++i)
		selIdx[i] = i;
	Calculate(aligns, selIdx, dst, missed, stdmax, nmax);
}


void CCdAlignProcessor::MergeCalc(vector<TDomSeqAlignment> &aligns, const vector<size_t> &selIdx, TDomSeqAlignIndex &dst, const int * stdmax, size_t nmax) const
{
	vector <CSegSet> vecGaps;
	vecGaps.emplace_back(CSegSet());	//sentinel
	size_t gapIdx = 0;
	vector <TDomAlignFacility> vecPrivileged, vecNonMulti, vecLongMultiDom, vecMultiDom, vecConcise, vecSDs;
	// -- added 12/6/2016: Concise view now should always include curated models (if available).
	if (!selIdx.empty())
	{
		TDomAlignFacility pholder;
		TDomAlignOrderByEValue sortingEV;
			
		vector<size_t> alignIdx;
		
		for (vector<size_t> :: const_iterator iterIdx = selIdx.begin(), iterIdxEnd = selIdx.end(); iterIdx != iterIdxEnd; ++iterIdx)
		{
			TDomSeqAlignment &rAlign = aligns[*iterIdx];
			if (rAlign.m_vecSStarts.empty()) continue;	//somehow live blast search contains empty aligns.
				
			if (2 == rAlign.m_iRepClass)	// mergecalc: no concern about skip SD
				continue;
				
			const TDomain *pCdInfo = nullptr;
#if defined(_MT)
			{{
				CReadLockGuard rlck(m_mtxDomClusterIdx);
#endif			
				pCdInfo = m_pDomSrc->FindCdInfo(rAlign.m_uiPssmId);
#if defined(_MT)
			}}
#endif
			
			// -- There should not be any missing pssmids, and no need to calculate scores anymore, they are already filled by previsou calls to "Calculat"
			// -- sorting
			
			if (nullptr == pCdInfo) continue;	//omit "really" missing pssmids
			
			pholder.pAlign = &(rAlign);
			pholder.ulIdx = *iterIdx;
			pholder.pCdInfo = pCdInfo;
			pholder.ulGapsIdx = string::npos;
			
			rAlign.CalcMasterGaps(TDomSeqAlignment::GAP_THRESHOLD, vecGaps[gapIdx]);
			if (!vecGaps[gapIdx].IsEmpty())
			{
				pholder.ulGapsIdx = gapIdx;
				++gapIdx;
				vecGaps.emplace_back(CSegSet());
			}
			// -- mergecalc: m_iRepClass is already assigned by previous calls to Calculate. multi-doms and SDs are not affected by suppress or rescue
			// -- from 4/4/2018 m_bMultiDom should be ignored.
			vecNonMulti.push_back(move(pholder));
			//if (0 == rAlign.m_iRepClass)
			//{
			//	vecNonMulti.emplace_back(pholder);
			//}
			//else
			//{
			//	vecMultiDom.emplace_back(pholder);
			//}
		}
		
		// -- no more missing pssmids
		map<int, TDomSrcCount> dimAccTypeCount;//, dimAccTypeCount_multi;	//one for single doms and one for multi-doms
		pair<int, TDomSrcCount> srccnt(0, TDomSrcCount(stdmax, nmax));

	  // -- sort
		sort(vecNonMulti.begin(), vecNonMulti.end(), sortingEV);
		for (vector <TDomAlignFacility>::const_iterator iter = vecNonMulti.begin(), iterEnd = vecNonMulti.end(); iterEnd != iter; ++iter)
		{
			iter->pAlign->m_bRep = false;	//mergecalc: must assume no rep
			CSegSet s_overlaps;	// to calculate combined overlap region
			
			CSegSet thisSegs;
			thisSegs.AddSeg(iter->pAlign->m_iFrom, iter->pAlign->m_iTo);
			if (string::npos != iter->ulGapsIdx)
				thisSegs.Clip(vecGaps[iter->ulGapsIdx]);
			
			int iThisLength = (int)thisSegs.GetTotalResidues();
			double dThisLength = (double)iThisLength;

			for (vector <TDomAlignFacility>::const_iterator iterRep = vecConcise.begin(), iterRepEnd = vecConcise.end(); iterRepEnd != iterRep; ++iterRep)
			{
				CSegSet repSegs;
				repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
				
				if (string::npos != iterRep->ulGapsIdx)
					repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
				
				int iRepLength = (int)repSegs.GetTotalResidues();
				double dRepLength = (double)iRepLength;
				
				// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
				
				CSegSet olSegs(thisSegs);
				olSegs.Cross(repSegs);
				
				int iOverlapLen = (int)olSegs.GetTotalResidues();
				double dOverlapLen = (double)iOverlapLen;
				
				if (dOverlapLen > 0)
				{
				
					if (dOverlapLen / dThisLength > 0.5 || (dOverlapLen / dRepLength > 0.5 && iter->pCdInfo->m_iClusterId == iterRep->pCdInfo->m_iClusterId))	//mutually overlap > 0.5
					//if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
					{
						iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
						iter->pAlign->m_bRep = false;
						
						goto labelNextNonMulti;
					}
				}
				s_overlaps.Merge(olSegs);

			}
			
			if ((iter->pAlign->m_bRep = (((double)(s_overlaps.GetTotalResidues()) / dThisLength) < 0.5)))	//new region
			{
				iter->pAlign->m_iRegionIdx = (int)vecConcise.size();
				vecConcise.emplace_back(*iter);

			}
		labelNextNonMulti:
			srccnt.first = iter->pAlign->m_iRegionIdx;
			map<int, TDomSrcCount> :: iterator iterSrcCounter = dimAccTypeCount.emplace(srccnt).first;
			
			if (iterSrcCounter->second.CountSrc(iter->pCdInfo->m_strAccession))
			{
				dst.m_vecStdIndice.emplace_back(iter->ulIdx);
				iter->pAlign->m_bRep = true;
				if (iter->pCdInfo->m_bCurated)
					dst.m_vecQualifiedFeatIndice.emplace_back(iter->ulIdx);
			}
			
			dst.m_vecSortedIndice.emplace_back(iter->ulIdx);
		}
		// -- When done, convert setup dst.m_vecConciseIndice
		size_t ttlWinners = vecConcise.size();
		if (ttlWinners > 0)
		{
			dst.m_vecConciseIndice.reserve(ttlWinners);
			for (size_t i = 0; i < ttlWinners; ++i)
				dst.m_vecConciseIndice.emplace_back(vecConcise[i].ulIdx);
		}
		vecPrivileged.clear();
		//sort(vecMultiDom.begin(), vecMultiDom.end(), sortingEV);
		//for (vector <TDomAlignFacility>::const_iterator iter = vecMultiDom.begin(), iterEnd = vecMultiDom.end(); iterEnd != iter; ++iter)
		//{
		//	iter->pAlign->m_bRep = false;	// mergecalc: must assume no rep
		//	CSegSet s_overlaps;	// to calculate combined overlap region
		//	CSegSet m_overlaps;
		//	
		//	double dSOverlap = 0.0;	//put here for scope reason
		//	double dMOverlap = 0.0;
		//	
		//	CSegSet thisSegs;
		//	thisSegs.AddSeg(iter->pAlign->m_iFrom, iter->pAlign->m_iTo);
		//	if (string::npos != iter->ulGapsIdx)
		//		thisSegs.Clip(vecGaps[iter->ulGapsIdx]);
		//	
		//	int iThisLength = (int)thisSegs.GetTotalResidues();
		//	double dThisLength = (double)iThisLength;
		//	
		//	//double dThisLength = (double)(iter->pAlign->m_iTo - iter->pAlign->m_iFrom + 1);
		//	for (vector <TDomAlignFacility>::const_iterator iterRep = vecConcise.begin(), iterRepEnd = vecConcise.end(); iterRepEnd != iterRep; ++iterRep)
		//	{
		//		if (!(iterRep->pAlign->m_iFrom > iter->pAlign->m_iTo || iterRep->pAlign->m_iTo < iter->pAlign->m_iFrom))	//overlap
		//		{
		//			CSegSet repSegs;
		//			repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
		//			
		//			if (string::npos != iterRep->ulGapsIdx)
		//				repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
		//			
		//			int iRepLength = (int)repSegs.GetTotalResidues();
		//			double dRepLength = (double)iRepLength;
		//			
		//			// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
		//			
		//			CSegSet olSegs(thisSegs);
		//			olSegs.Cross(repSegs);
		//			
		//			int iOverlapLen = (int)olSegs.GetTotalResidues();
		//			
		//			double dOverlapLen = (double)iOverlapLen;
		//			
		//			if (0 == iterRep->pAlign->m_iRepClass)	//single
		//			{
		//				s_overlaps.Merge(olSegs);
		//			}
		//			else	//multi
		//			{
		//				if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
		//				{
		//					iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
		//					iter->pAlign->m_bRep = false;
		//					goto labelNextMulti;
		//				}
		//				m_overlaps.Merge(olSegs);
		//			}
		//		}
		//	}
		//	
		//	
		//	for (vector <TDomAlignFacility>::const_iterator iterRep = vecPrivileged.begin(), iterRepEnd = vecPrivileged.end(); iterRepEnd != iterRep; ++iterRep)
		//	{
		//		if (!(iterRep->pAlign->m_iFrom > iter->pAlign->m_iTo || iterRep->pAlign->m_iTo < iter->pAlign->m_iFrom))	//overlap
		//		{
		//			
		//			CSegSet repSegs;
		//			repSegs.AddSeg(iterRep->pAlign->m_iFrom, iterRep->pAlign->m_iTo);
		//			
		//			if (string::npos != iterRep->ulGapsIdx)
		//				repSegs.Clip(vecGaps[iterRep->ulGapsIdx]);
		//			
		//			int iRepLength = (int)repSegs.GetTotalResidues();
		//			double dRepLength = (double)iRepLength;
		//			
		//			// -- find gaps. any gap >= half of the domain model length are considered a gap and excluded from overlapping
		//			
		//			CSegSet olSegs(thisSegs);
		//			olSegs.Cross(repSegs);
		//			
		//			int iOverlapLen = (int)olSegs.GetTotalResidues();
		//			
		//			double dOverlapLen = (double)iOverlapLen;
		//			
		//			if (dOverlapLen / dThisLength + dOverlapLen / dRepLength > 1.0)	//mutually overlap > 0.5
		//			{
		//				iter->pAlign->m_iRegionIdx = iterRep->pAlign->m_iRegionIdx;
		//				iter->pAlign->m_bRep = false;
		//				goto labelNextMulti;
		//			}
		//			m_overlaps.Merge(olSegs);
		//		}
		//	}
		//	
		//	dSOverlap = (double)(s_overlaps.GetTotalResidues()) / dThisLength;
		//	dMOverlap = (double)(m_overlaps.GetTotalResidues()) / dThisLength;
    //
		//	if (dMOverlap <= 0.5)	//new multi-dom region
		//	{
		//		if ((dSOverlap <= 0.5 && iter->pAlign->m_dAlignedPct > 50.0) || iter->pAlign->m_bSpecQualified)	//rep!
		//		{
		//			iter->pAlign->m_iRegionIdx = dst.m_vecConciseIndice.size() + vecPrivileged.size();
		//			iter->pAlign->m_bRep = true;
		//			
		//			dst.m_vecConciseIndice.emplace_back(iter->ulIdx);
		//			vecConcise.emplace_back(*iter);
		//		}
		//		vecPrivileged.emplace_back(*iter);
		//	}
		//labelNextMulti:
		//	
		//	map<int, TDomSrcCount> :: iterator iterSrcCounter = dimAccTypeCount_multi.emplace(iter->pAlign->m_iRegionIdx, TDomSrcCount()).first;
		//	if (iterSrcCounter->second.CountSrc(iter->pCdInfo->m_strAccession))
		//		dst.m_vecStdIndice.emplace_back(iter->ulIdx);
		//	
		//	dst.m_vecSortedIndice.emplace_back(iter->ulIdx);
		//
		//}
		// -- to avoid empty concise
		
		if (!dst.m_vecSortedIndice.empty())
		{
			if (dst.m_vecConciseIndice.empty())
			{
				size_t iEnd = vecPrivileged.size();
				dst.m_vecConciseIndice.reserve(iEnd);
				for (size_t i = 0; i < iEnd; ++i)
				{
					dst.m_vecConciseIndice.emplace_back(vecPrivileged[i].ulIdx);
					vecPrivileged[i].pAlign->m_bRep = true;
				}
			}
			
			if (dst.m_vecStdIndice.empty())
			{
				dst.m_vecStdIndice = dst.m_vecSortedIndice;
			}
		}
	}
}


void CCdAlignProcessor::ExtractDomains(const list<TDomQuery> &rProcessed, vector< const TDomain* > &doms, vector< const TCluster* > &fams, int mode, int rfidx) const
{
	if (rfidx < 0 || rfidx > 5)
		rfidx = 0;
	
	vector<PssmId_t> pssmids;
	
	switch (mode)
	{
	case TDataModes::e_rep:
	default:
		for (const auto &q : rProcessed)
		{
			vector<size_t> iidx(q.m_dimSplitAligns[rfidx].m_vecConciseIndice);
			iidx.insert(iidx.end(), q.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.begin(), q.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.end());
			iidx.insert(iidx.end(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
			SortAndDeDup(iidx);
			size_t ttlaligns = iidx.size();
			pssmids.reserve(ttlaligns + pssmids.size());
			for (auto v : iidx)
				pssmids.emplace_back(q.m_vecAlignments[v].m_uiPssmId);
		}
		break;
	case TDataModes::e_std:
		for (const auto &q : rProcessed)
		{
			vector<size_t> iidx(q.m_dimSplitAligns[rfidx].m_vecStdIndice);
			iidx.insert(iidx.end(), q.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.begin(), q.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.end());
			iidx.insert(iidx.end(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
			SortAndDeDup(iidx);
			size_t ttlaligns = iidx.size();
			pssmids.reserve(ttlaligns + pssmids.size());
			for (auto v : iidx)
				pssmids.emplace_back(q.m_vecAlignments[v].m_uiPssmId);
		}
		break;
	case TDataModes::e_full:
		for (const auto &q : rProcessed)
		{
			vector<size_t> iidx(q.m_dimSplitAligns[rfidx].m_vecSortedIndice);
			iidx.insert(iidx.end(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), q.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
			SortAndDeDup(iidx);
			size_t ttlaligns = iidx.size();
			pssmids.reserve(ttlaligns + pssmids.size());
			for (auto v : iidx)
				pssmids.emplace_back(q.m_vecAlignments[v].m_uiPssmId);
		}
		break;
	}
	
	SortAndDeDup(pssmids);
	
	ExtractDomains(pssmids, doms, fams);
	
	
}
void CCdAlignProcessor::ExtractDomains(const TDomQuery &rProcessed, vector< const TDomain* > &doms, vector< const TCluster* > &fams, int mode, int rfidx) const
{
	vector<size_t> iidx;
	
	if (rfidx < 0 || rfidx > 5)
		rfidx = 0;
	
	switch (mode)
	{
	case TDataModes::e_rep:
	default:
		iidx = rProcessed.m_dimSplitAligns[rfidx].m_vecConciseIndice;
		iidx.insert(iidx.end(), rProcessed.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.begin(), rProcessed.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.end());
		iidx.insert(iidx.end(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
		break;
	case TDataModes::e_std:
		iidx = rProcessed.m_dimSplitAligns[rfidx].m_vecStdIndice;
		iidx.insert(iidx.end(), rProcessed.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.begin(), rProcessed.m_dimSplitAligns[rfidx].m_vecQualifiedFeatIndice.end());
		iidx.insert(iidx.end(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
		
		break;
	case TDataModes::e_full:
		iidx = rProcessed.m_dimSplitAligns[rfidx].m_vecSortedIndice;
		iidx.insert(iidx.end(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.begin(), rProcessed.m_dimSplitAligns[rfidx].m_vecSDIndice.end());
		break;
	}
	
	SortAndDeDup(iidx);
	size_t ttlaligns = iidx.size();
	vector<PssmId_t> pssmids;
	pssmids.reserve(ttlaligns);
	
	for (auto v : iidx)
		pssmids.emplace_back(rProcessed.m_vecAlignments[v].m_uiPssmId);
	
	iidx.clear();
	SortAndDeDup(pssmids);
	
	ExtractDomains(pssmids, doms, fams);
	
}

void CCdAlignProcessor::ExtractDomains(const vector<PssmId_t> &pssmids, vector< const TDomain* > &doms, vector< const TCluster* > &fams) const
{
	size_t ttl = pssmids.size();
	if (ttl > 0)
	{
		doms.reserve(ttl + doms.size());
		fams.reserve(ttl + fams.size());
		
#if defined(_MT)
		CReadLockGuard rlck(m_mtxDomClusterIdx);
#endif
		for (size_t i = 0; i < ttl; ++i)
		{
			const TDomain * pDom = m_pDomSrc->FindCdInfo(pssmids[i]);
			if (nullptr != pDom)
			{
				doms.emplace_back(pDom);
				if (pDom->m_iClusterId > 0 && SINGLEMEMBERCLUSTER != pDom->m_iClusterId)
				{
					const TCluster *pClst = m_pDomSrc->FindClusterInfo(pDom->m_iClusterId);
					if (nullptr != pClst)
						fams.emplace_back(pClst);
				}
			}
		}
		
		doms.shrink_to_fit();
		fams.shrink_to_fit();
	}
}

void CCdAlignProcessor::ExtractClusters(const vector<ClusterId_t> &clstids, vector< const TCluster* > &fams) const
{
	size_t ttl = clstids.size();
	if (ttl > 0)
	{
		fams.reserve(ttl);
#if defined(_MT)
		CReadLockGuard rlck(m_mtxDomClusterIdx);
#endif
		for (size_t i = 0; i < ttl; ++i)
		{
			const TCluster *pClst = m_pDomSrc->FindClusterInfo(clstids[i]);
			if (nullptr != pClst)
				fams.emplace_back(pClst);
		}
		fams.shrink_to_fit();
	}
}





string GetNameString(const TDomClusterIndexIfx &domInfo, const TDomSeqAlignIndex::__TCdAlignRecordBase& rec)
{
	if (rec.pAlign->m_bSpecQualified || rec.pCdInfo->m_iClusterId <= 0 || SINGLEMEMBERCLUSTER == rec.pCdInfo->m_iClusterId)
		return rec.pCdInfo->m_strShortName;
	else
	{
		const TCluster * pClstInfo = domInfo.FindClusterInfo(rec.pCdInfo->m_iClusterId);
		if (nullptr != pClstInfo)
			return pClstInfo->m_strShortName;
	}

	return k_strEmptyString;
}

void _TArchNameCols::clear()
{
	name.clear();
	label.clear();
	nameevds.clear();
	labelevds.clear();
	
}


void CreateSpArchName(const TDomClusterIndexIfx &domInfo, const TDomSeqAlignIndex &indice, const vector<TDomSeqAlignment> &aligns, _TArchNameCols &cols, string &remark)
{
	constexpr static const char evddelim = ' ';

	cols.clear();
	remark.clear();
	
	const vector<size_t> &conciseIdx = indice.m_vecConciseIndice;
	
	size_t ttlConcise = conciseIdx.size();
	// -- check for hits
	

	if (ttlConcise > 0)
	{
		//TDomSeqAlignIndex::__TCdAlignRecord rec;
		vector<TDomSeqAlignIndex::__TCdAlignRecord> namingRecs;
		namingRecs.reserve(ttlConcise);
		
		TDomSeqAlignIndex::__TCdAlignRecord rec;
		size_t iidx = 0;
		// -- always push in the first.
		while (iidx < ttlConcise)
		{
			rec.pAlign = &aligns[conciseIdx[iidx]];
			rec.pCdInfo = domInfo.FindCdInfo(rec.pAlign->m_uiPssmId);
			if (nullptr != rec.pCdInfo)
			{
				if (rec.pCdInfo->m_iClusterId > 0 && SINGLEMEMBERCLUSTER != rec.pCdInfo->m_iClusterId)
					rec.pClst = domInfo.FindClusterInfo(rec.pCdInfo->m_iClusterId);
				namingRecs.emplace_back(rec);
				++iidx;
				goto labelGotOne;
			}
			++iidx;
		}
		return;
		
	labelGotOne:
		if (0 == rec.pAlign->m_iRepClass)
		{
			while (iidx < ttlConcise)
			{
				rec.pAlign = &aligns[conciseIdx[iidx]];
				if (rec.pAlign->m_iRepClass > 0) break;
				rec.pCdInfo = domInfo.FindCdInfo(rec.pAlign->m_uiPssmId);
				rec.pClst = nullptr;
				if (nullptr != rec.pCdInfo)
				{
					if (rec.pCdInfo->m_iClusterId > 0 && SINGLEMEMBERCLUSTER != rec.pCdInfo->m_iClusterId)
						rec.pClst = domInfo.FindClusterInfo(rec.pCdInfo->m_iClusterId);
					
					namingRecs.emplace_back(rec);
				}
				++iidx;
			}
			
			if (namingRecs.size() > 1)
				goto labelMultiHit;
		}

		switch (TDomSrcCount::DomAccType(namingRecs[0].pCdInfo->m_strAccession))
		{
		case TDomSrcCount::eTIGRFam:
		case TDomSrcCount::eCOG:
		case TDomSrcCount::ePRK:
			cols.name = cols.label = namingRecs[0].pCdInfo->m_strShortName + " family protein";
			cols.nameevds = cols.labelevds = namingRecs[0].pCdInfo->m_strAccession;
			NStr::NumericToString<double>(remark, namingRecs[0].pAlign->m_dAlignedPct);
			remark.push_back('\t');
			remark.append(namingRecs[0].pCdInfo->m_strAccession);

			return;
		default:
			if (namingRecs[0].pAlign->m_iRepClass > 0)
				return;	//no multidom hit
			break;
		}
	labelMultiHit:
		
		vector<TDomSeqAlignIndex::__TCdAlignRecord> amends;
		indice.CreateConciseAmends(aligns, domInfo, namingRecs, amends);
		
		if (!amends.empty())
		{
			size_t je = amends.size();


			for (size_t i = 0, ie = namingRecs.size(); i < ie; ++i)
			{
				size_t j = 0;
				while (j < je)
				{
					if (namingRecs[i].pAlign->m_iRegionIdx == amends[j].pAlign->m_iRegionIdx)
					{

						namingRecs[i] = amends[j];
						amends.erase(amends.begin() + j);
						//VecRemoveData<TDomSeqAlignIndex::__TCdAlignRecord> (amends, j);

						--je;

						break;
					}
					++j;

				}
			}
		}
			// -- get rid of dups
		size_t nrecs = namingRecs.size();
		
		size_t curr = nrecs - 1;
		while (curr > 0)
		{
			size_t cmp = curr;
			while (cmp > 0)
			{
				if ((namingRecs[cmp - 1].pCdInfo == namingRecs[curr].pCdInfo))	//equivalent, no name
				{
					if (namingRecs[curr].pAlign->m_bSpecQualified && !namingRecs[cmp - 1].pAlign->m_bSpecQualified)
					{
						//VecRemoveData<TDomSeqAlignIndex::__TCdAlignRecord> (namingRecs, cmp - 1);
						namingRecs.erase(namingRecs.begin() + (cmp - 1));
						goto labelNext;
					}
					else
					{
						//VecRemoveData<TDomSeqAlignIndex::__TCdAlignRecord> (namingRecs, curr);
						namingRecs.erase(namingRecs.begin() + curr);
						goto labelNext;
					}


					

					
				}
				--cmp;
			}
			
			
		labelNext:;
			--curr;
		

		}
		
		vector<TDomSeqAlignIndex::__TCdAlignRecordBase> vecSpecNaming, vecNonSpecNaming;
		vecSpecNaming.reserve(nrecs);
		vecNonSpecNaming.reserve(nrecs);
		
		nrecs = namingRecs.size();
		for (size_t i = 0; i < nrecs; ++i)
			((namingRecs[i].pAlign->m_bSpecQualified) ? vecSpecNaming : vecNonSpecNaming).emplace_back(namingRecs[i]);

		if (!vecSpecNaming.empty())	//must have spec hits to generate a spArchName
		{
			char sep[2] = {0, 0};
			
			// -- naming protein from domain names
			size_t sphits = vecSpecNaming.size(), clshits = vecNonSpecNaming.size();
			if (sphits < 4)
			{
				size_t amend = 4 - sphits;
				if (clshits < amend) amend = clshits;
				//-- borrow it
				clshits = 0;
				while (clshits < amend) vecSpecNaming.emplace_back(vecNonSpecNaming[clshits++]);
			}
			else if (sphits > 4)
			{
				size_t extra = sphits - 4;
				while (extra > 0)
				{
					vecSpecNaming.pop_back();
					--extra;
				}
			}
			sphits = vecSpecNaming.size();
			if (sphits > 2)	//name and label are different
			{
				sep[0] = evddelim;
				vecNonSpecNaming.clear();	//use to hold name
				vecNonSpecNaming.emplace_back(vecSpecNaming[0]);
				vecNonSpecNaming.emplace_back(vecSpecNaming[1]);
				
				sort(vecNonSpecNaming.begin(), vecNonSpecNaming.end(), TDomSeqAlignIndex::TSortByFromObj());
				cols.name = GetNameString(domInfo, vecNonSpecNaming[0]);
				cols.nameevds = vecNonSpecNaming[0].pCdInfo->m_strAccession + sep + vecNonSpecNaming[1].pCdInfo->m_strAccession;
				
				string name2 = GetNameString(domInfo, vecNonSpecNaming[1]);
				
				if (!NStr::EqualNocase(cols.name, name2))
					cols.name += " and " + name2;
					
				cols.name += " domain-containing protein";
      	
				sort(vecSpecNaming.begin(), vecSpecNaming.end(), TDomSeqAlignIndex::TSortByFromObj());
				
				vector<string> snames;
				snames.reserve(sphits);
				
				cols.label = "protein containing domain";
				
				sep[0] = 0;
				for (clshits = 0; clshits < sphits; ++clshits)
				{
					string alabel = GetNameString(domInfo, vecSpecNaming[clshits]);
					cols.labelevds.append(sep);
					cols.labelevds.append(vecSpecNaming[clshits].pCdInfo->m_strAccession);
					sep[0] = evddelim;
					for (size_t j = snames.size(); j > 0; --j)
						if (NStr::EqualNocase(alabel, snames[j - 1]))
							goto labelSkipThis;
					snames.emplace_back(move(alabel));
				labelSkipThis:;
				}
				
				clshits = 0, sphits = snames.size();
				
				if (sphits > 1)
					cols.label.append("s ");
				else
					cols.label.push_back(' ');
				
				cols.label.append(snames[clshits]);
				++clshits;
				if (clshits < sphits)
				{
					while (clshits < sphits - 1)
					{
						cols.label.append(", ");
						cols.label.append(snames[clshits]);
						++clshits;
					}
					// -- last one
					cols.label.append(", and ");
					cols.label.append(snames[clshits]);
				}
				
			}
			else if (sphits > 0)
			{
				sort(vecSpecNaming.begin(), vecSpecNaming.end(), TDomSeqAlignIndex::TSortByFromObj());
				clshits = 0;
				string snames(GetNameString(domInfo, vecSpecNaming[clshits]));
				cols.nameevds = cols.labelevds = vecSpecNaming[clshits].pCdInfo->m_strAccession;
				
				++clshits;
				
				if (clshits < sphits)
				{
					sep[0] = evddelim;
					string alabel = GetNameString(domInfo, vecSpecNaming[clshits]);
					cols.nameevds.append(sep);
					cols.nameevds.append(vecSpecNaming[clshits].pCdInfo->m_strAccession);
					cols.labelevds.append(sep);
					cols.labelevds.append(vecSpecNaming[clshits].pCdInfo->m_strAccession);
					if (!NStr::EqualNocase(alabel, snames))
					{
						snames.append(" and ");
						snames.append(alabel);
					}
				}
				
				cols.name = cols.label = snames + " domain-containing protein";
				//cols.label = "protein containing " + ((sphits > 1 ? "domains " : "domain ") + snames);
			}
		}
	}
	else
	{
		cols.name = cols.label = NODOMPROT;
	}
}

void CreateArchStrings(const TDomClusterIndexIfx &domInfo, const vector<size_t> &conciseIdx, const vector<TDomSeqAlignment> &aligns, string &archStr, string &spArchStr)
{
	archStr.clear();
	spArchStr.clear();
	
	size_t ttlConcise = conciseIdx.size();

	if (ttlConcise > 0)
	{
		vector<TDomSeqAlignIndex::__TCdAlignRecordBase> vecSortByFrom;
		vecSortByFrom.reserve(ttlConcise);
		for (size_t i = 0; i < ttlConcise; ++i)
		{
			TDomSeqAlignIndex::__TCdAlignRecordBase recBase;
			recBase.pAlign = &(aligns[conciseIdx[i]]);
			
			if (recBase.pAlign->m_iRepClass > 0) break;
			recBase.pCdInfo = domInfo.FindCdInfo(recBase.pAlign->m_uiPssmId);

			// -- changed 5/1/2018: since we reintroduced multi-dom flag but choose to ignore that, we lift the condition of m_iClusterId > 0
			//if (nullptr != recBase.pCdInfo && recBase.pCdInfo->m_iClusterId > 0)
			if (nullptr != recBase.pCdInfo)
				vecSortByFrom.emplace_back(recBase);
		}
		
		ttlConcise = vecSortByFrom.size();
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": ttlConcise = " << ttlConcise << endl;
#endif
// ***********************************************************/


		if (ttlConcise > 0)	//has
		{
			// -- sort by position
			sort(vecSortByFrom.begin(), vecSortByFrom.end(), TDomSeqAlignIndex::TSortByFromObj());
			
			const TDomain *pLastCdInfo = nullptr;
			bool lastSpec = false, hasSpec = false;
			int lastClstId = 0;
			
			
			char dimSep0[2] = {0, 0};
			char dimSep1[2] = {0, 0};
			char dimBuf[16];
			
			for (size_t i = 0; i < ttlConcise; ++i)
			{

				if (vecSortByFrom[i].pAlign->m_bSpecQualified)
				{
					if (!lastSpec || vecSortByFrom[i].pCdInfo != pLastCdInfo)	//filter out tandem repeat
					{
						spArchStr.append(dimSep1);
						spArchStr.append(vecSortByFrom[i].pCdInfo->m_strAccession);
						dimSep1[0] = ARCH_STRING_DELIM;
						lastSpec = true;
						hasSpec = true;
						pLastCdInfo = vecSortByFrom[i].pCdInfo;
					}
				}
				// -- added 5/2/2018 to deal with non-clustered multidom 
				else if (vecSortByFrom[i].pCdInfo->m_iClusterId <= 0)
				{
					if (lastSpec || vecSortByFrom[i].pCdInfo != pLastCdInfo)	//filter out tandem repeat
					{
						sprintf(dimBuf, "cl%09d", INVALIDPSSMID + vecSortByFrom[i].pAlign->m_uiPssmId);
						spArchStr.append(dimSep1);
						spArchStr.append(dimBuf);
						dimSep1[0] = ARCH_STRING_DELIM;
						lastSpec = false;
						pLastCdInfo = vecSortByFrom[i].pCdInfo;
						
					}
				}
				else
				{
					if (lastSpec || vecSortByFrom[i].pCdInfo->m_iClusterId != lastClstId)	//non-spec hit
					{
						sprintf(dimBuf, "cl%05d", vecSortByFrom[i].pCdInfo->m_iClusterId);
						spArchStr.append(dimSep1);
						spArchStr.append(dimBuf);
						dimSep1[0] = ARCH_STRING_DELIM;
						lastSpec = false;
						pLastCdInfo = vecSortByFrom[i].pCdInfo;
					}
					
				}
				
				// -- regular arch string
				// -- for historical reason, the regular (superfamily) arch string needs to be in reverse order, ie, from C- to N- terminal.
				
				// -- regular arch string
				// -- for historical reason, the regular (superfamily) arch string needs to be in reverse order, ie, from C- to N- terminal.
				if (vecSortByFrom[i].pCdInfo->m_iClusterId <= 0)
				{
					if (vecSortByFrom[i].pCdInfo != pLastCdInfo)
					{
						sprintf(dimBuf, "%d%s", INVALIDPSSMID + vecSortByFrom[i].pAlign->m_uiPssmId, dimSep0);
						archStr = dimBuf + archStr;
						dimSep0[0] = ARCH_STRING_DELIM;
						lastClstId = INVALIDPSSMID + vecSortByFrom[i].pAlign->m_uiPssmId;	
					}
				}
				else
				{
					if (vecSortByFrom[i].pCdInfo->m_iClusterId != lastClstId)
					{
						sprintf(dimBuf, "%d%s", vecSortByFrom[i].pCdInfo->m_iClusterId, dimSep0);
						archStr = dimBuf + archStr;
						//archStr.append(dimSep0);
						//archStr.append(dimBuf);
						dimSep0[0] = ARCH_STRING_DELIM;
						lastClstId = vecSortByFrom[i].pCdInfo->m_iClusterId;
					}
				}
				
				
				//if (INVALIDCLUSTERID != vecSortByFrom[i].pCdInfo->m_iClusterId && vecSortByFrom[i].pCdInfo->m_iClusterId != lastClstId)
				//{
				//	sprintf(dimBuf, "%d%s", vecSortByFrom[i].pCdInfo->m_iClusterId, dimSep0);
				//	archStr = dimBuf + archStr;
				//	//archStr.append(dimSep0);
				//	//archStr.append(dimBuf);
				//	dimSep0[0] = ARCH_STRING_DELIM;
				//}
				//
				//lastClstId = vecSortByFrom[i].pCdInfo->m_iClusterId;
			}
			// -- if no specific hit, clear spArchStr
			if (!hasSpec) spArchStr.clear();
		}
	}
}

