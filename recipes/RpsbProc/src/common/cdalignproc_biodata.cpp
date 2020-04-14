#include <ncbi_pch.hpp>
#include "cdalignproc_biodata.hpp"
#if defined(__DB_OFFLINE__)
#include "biodata_blast.hpp"
#include "objutils.hpp"
#include "basealgo.hpp"
#include "compactstore.hpp"
#include "ptrmap.hpp"
#else
#include <DataUtils/biodata_blast.hpp>
#include <NcbiBase/objutils.hpp>
#include <BasicUtils/basealgo.hpp>
#include <BasicUtils/compactstore.hpp>
#include <BasicUtils/ptrmap.hpp>
#endif
#include <objects/seqfeat/seqfeat__.hpp>
#include <objects/seqset/seqset__.hpp>

USING_NCBI_SCOPE;
using namespace objects;


void AlignEValueFilter(CSeq_annot::TData::TAlign &aligns, double dEValCutoff)
{
	CSeq_annot::TData::TAlign::iterator iterAlign = aligns.begin(), iterAlignEnd = aligns.end();
		
	while (iterAlignEnd != iterAlign)
	{
		const CSeq_align::TScore& rScoreTab = (*iterAlign)->GetScore();  //vector< CRef< CScore > >
		for (CSeq_align::TScore::const_iterator j = rScoreTab.begin(); j != rScoreTab.end(); ++j)
		{
			const CScore& rScore = **j;  //CScore
			
			if (rScore.IsSetId() && rScore.CanGetId())
			{
				const CScore::TId& rObjectId = rScore.GetId();  //CObject_id
					
				if (CObject_id::e_Str == rObjectId.Which())
				{
					const CObject_id::TStr& rStr = rObjectId.GetStr();    //string
					if (rStr == "e_value")
					{

						if (rScore.GetValue().GetReal() > dEValCutoff)	//delete this align
						{
							CSeq_annot::TData::TAlign::iterator temp_iterAlign = iterAlign;
							++iterAlign;
							aligns.erase(temp_iterAlign);
							goto labelNextAlign;
						}
						break;
					}
				}
			}
		}//for
		
		++iterAlign;
	labelNextAlign:;
	}
}



PssmId_t CNcbiCdAlignProcessor::x_GetPssmId(const CSeq_id &seqid) const
{
	const CSeq_id::TGeneral& rDbTag = seqid.GetGeneral();  //CDbtag
	const CDbtag::TTag& rObjectId = rDbTag.GetTag();  //CObject_id
   
	if (rObjectId.Which() == CObject_id::e_Id)	//correct pssmid
		return rObjectId.GetId();
	return 0;
}



void CNcbiCdAlignProcessor::ProcessCDAlign(const list<CRef<CSeq_align> > &rAligns, vector<TDomSeqAlignment> &dst) const
{
	
	for (list<CRef<CSeq_align> > :: const_iterator iterSrc = rAligns.begin(); iterSrc != rAligns.end(); ++iterSrc)
	{
		TDomSeqAlignment newalign;
		CRef<CSeq_id> hit_id = ParseAlignSegs((*iterSrc)->GetSegs(), newalign);
		
		if (!hit_id.IsNull())
		{
			PssmId_t uiPssmId = x_GetPssmId(*hit_id);
			if (uiPssmId > 0)
			{
				newalign.m_uiPssmId = uiPssmId;
				ParseAlignScores(**iterSrc, newalign);
				dst.emplace_back(move(newalign));
			}
		}
	}
}


//void CNcbiCdAlignProcessor::ProcessCDAlign(const list<CRef<CSeq_align> > &rAligns, vector<TDomSeqAlignment> &dst) const
//{
//	TDomSeqAlignment newalign;
//
//	for (list<CRef<CSeq_align> > :: const_iterator iterSrc = rAligns.begin(); iterSrc != rAligns.end(); ++iterSrc)
//	{
//		const CSeq_align& rSeq_align = **iterSrc;
//	
//		const CSeq_align::TSegs & segs = rSeq_align.GetSegs();
//		
//		vector<TDomSeqAlignment> :: iterator iterNewAlign = dst.end();
//		switch (segs.Which())
//		{
//			case CSeq_align::TSegs::e_Denseg:
//			{
//				const CSeq_align::TSegs::TDenseg& rDense_seg = rSeq_align.GetSegs().GetDenseg();
//				const CSeq_id& rCdSeqId = *(rDense_seg.GetIds()[1]);
//				if (rCdSeqId.Which() == CSeq_id::e_General)	//supposed to be general
//				{
//					PssmId_t uiPssmId = x_GetPssmId(rCdSeqId);
//
//					if (uiPssmId > 0)	//have a usable pssmid
//					{
//						iterNewAlign = dst.insert(iterNewAlign/*dst.end()*/, newalign);
//						iterNewAlign->m_uiPssmId = uiPssmId;
//						//(*iterSrc) = *iterSrc;	//keep the raw data
//						
//						const vector<SeqPos_t> &rStarts = rDense_seg.GetStarts();
//						const vector<SeqLen_t> &rLens = rDense_seg.GetLens();
//
//						//iterNewAlign->m_iFrom = rStarts[0];
//						//iterNewAlign->m_iTo = rStarts[rStarts.size() - 2] + rLens[rLens.size() - 1] - 1;
//						
//						// -- process alignments to easy handling later
//
//						CleanAlignment(rStarts, rLens, iterNewAlign->m_vecMStarts, iterNewAlign->m_vecSStarts, iterNewAlign->m_vecLens);
//
//						size_t segs = iterNewAlign->m_vecLens.size();
//						if (segs > 0)
//						{
//							iterNewAlign->m_iFrom = iterNewAlign->m_vecMStarts[0];
//							iterNewAlign->m_iTo = iterNewAlign->m_vecMStarts[segs - 1] + iterNewAlign->m_vecLens[segs - 1] - 1;
//						}
//						break;
//					}
//				}
//				continue;
//			}
//			case CSeq_align::TSegs::e_Std:	//nuclear acid query
//			{
//				const CSeq_align::TSegs::TStd& rStdSegs = rSeq_align.GetSegs().GetStd();	//list< CRef< CStd_seg > >
//				
//				PssmId_t uiPssmId = 0;	//initialize
//				
//		
//				for (CSeq_align::TSegs::TStd::const_iterator iterStdSeg = rStdSegs.begin(); iterStdSeg != rStdSegs.end(); ++iterStdSeg)
//				{
//					// -- assume dim == 2
//					const CStd_seg::TIds & idsTbl = (*iterStdSeg)->GetIds();	//vector< CRef< CSeq_id > >
//					CStd_seg::TIds::const_iterator iterMstId = idsTbl.begin(), iterSlvId = iterMstId; ++iterSlvId;
//					
//					// -- Get Seq-locs, for efficiency
//					const CStd_seg::TLoc & locsTbl = (*iterStdSeg)->GetLoc();	//vector< CRef< CSeq_loc > >
//					CStd_seg::TLoc::const_iterator iterMstLoc = locsTbl.begin(), iterSlvLoc = iterMstLoc; ++iterSlvLoc;
//					
//					if (0 == uiPssmId)	//create new align
//					{
//						if ((*iterSlvId)->Which() == CSeq_id::e_General)	//supposed to be general
//						{
//							uiPssmId = x_GetPssmId(**iterSlvId);
//							if (uiPssmId > 0)	//got valid pssmid
//							{
//								iterNewAlign = dst.insert(iterNewAlign/*dst.end()*/, newalign);
//								iterNewAlign->m_uiPssmId = uiPssmId;
//								//(*iterSrc) = *iterSrc;	//keep the raw data
//								
//								// -- deal with strand and reading frame
//								// -- assert(!(*iterMstLoc)->IsEmpty());	//this must be the first segment, and both master and slave should not be empty.
//								
//								// -- for plus strand, the master segments are like:
//								// -- 	(0-8)(13-18)(29-40)
//								// -- for minus strand, the master segments are like:
//								// -- 	(29-40)(13-18)(0-8)
//								// -- while slave segments are all normal like (1-21)(11-20)(21-30)
//								
//								//iterNewAlign->m_eStrand = (*iterMstLoc)->GetInt().GetStrand();	//already determined
//								iterNewAlign->m_bIsMinus = (eNa_strand_minus == (*iterMstLoc)->GetInt().GetStrand());	//already determined
//								iterNewAlign->m_eAlignType = TSeqAlignment::ePr2Na;
//								iterNewAlign->m_iFrom = k_INT_MAX;
//
//								iterNewAlign->m_iTo = 0;
//				
//							}
//							else
//								goto labelSkipThisAlignment;
//						}
//					}
//					
//					if ((*iterMstLoc)->IsEmpty() || (*iterSlvLoc)->IsEmpty())	//unmapped, ignore
//						continue;
//					const CSeq_interval &rMstInt = (*iterMstLoc)->GetInt(), &rSlvInt = (*iterSlvLoc)->GetInt();
//					int from = rMstInt.GetFrom(), to = rMstInt.GetTo();
//
//
//					if (from < iterNewAlign->m_iFrom) iterNewAlign->m_iFrom = from;
//					if (to > iterNewAlign->m_iTo) iterNewAlign->m_iTo = to;
//					// -- m_iFrom and m_iTo record the NA coordinates on master
//					//iterNewAlign->m_iTo = rMstInt.GetTo();
//					iterNewAlign->m_vecMStarts.emplace_back(from / READINGFRAME::RF_SIZE);	//convert to protein coord
//
//					SeqPos_t iSlvFrom = rSlvInt.GetFrom();	// slave and lens are in slave scale
//					iterNewAlign->m_vecSStarts.emplace_back(iSlvFrom);
//
//					iterNewAlign->m_vecLens.emplace_back(rSlvInt.GetTo() - iSlvFrom + 1);	//convert back to protein: from/3, (from + len - 1) / 3
//				}
//				
//				// -- reading frame
//				iterNewAlign->m_ReadingFrame = iterNewAlign->m_iFrom % READINGFRAME::RF_SIZE;	//get it from 1 - 3
//				//if (eNa_strand_minus == iterNewAlign->m_eStrand)	//re-coding master to adapt alignment
//				if (iterNewAlign->m_bIsMinus)
//				{
//					//iterNewAlign->m_ReadingFrame = iterNewAlign->m_iTo % RF_SIZE;	//get it from 1 - 3
//					
//					SeqPos_t iAlignRange = (iterNewAlign->m_iTo + 1) / READINGFRAME::RF_SIZE;
//					//int iAlignRange = *iterNewAlign->m_vecMStarts.begin() + *iterNewAlign->m_vecLens.begin() - 1;	//largest aligned residue number in protein coord
//					iterNewAlign->m_ReadingFrame |= (iAlignRange << 2);	//store the range. this is just a record without knowing the length of CD. At this time,  m_ReadingFrame is always positive
//					
//					// -- convert coord system
//					vector<SeqPos_t> :: iterator iterMS = iterNewAlign->m_vecMStarts.begin(), iterMSEnd = iterNewAlign->m_vecMStarts.end();
//					vector<SeqLen_t> :: const_iterator iterL = iterNewAlign->m_vecLens.begin();
//					while (iterMS != iterMSEnd)
//					{
//						*iterMS = iAlignRange - (*iterMS + *iterL);
//						++iterMS;
//						++iterL;
//					}
//				}
//				
//				break;	//break switch -- to 
//			labelSkipThisAlignment:
//				continue;
//				
//			}
//			default: continue;	//skip cycle
//
//		}
//				
//		if ((*iterSrc)->IsSetScore() && (*iterSrc)->CanGetScore())
//		{
//
//			const CSeq_align::TScore& rScoreTab = (*iterSrc)->GetScore();  //vector< CRef< CScore > >
//			for (CSeq_align::TScore::const_iterator j = rScoreTab.begin(); j != rScoreTab.end(); ++j)
//			{
//				const CScore& rScore = **j;  //CScore
//				
//				if (rScore.IsSetId() && rScore.CanGetId())
//				{
//					const CScore::TId& rObjectId = rScore.GetId();  //CObject_id
//						
//					if (CObject_id::e_Str == rObjectId.Which())
//					{
//						const CObject_id::TStr& rStr = rObjectId.GetStr();    //string
//						if (rStr == "score")
//						{
//							if (rScore.IsSetValue() && rScore.CanGetValue())
//							{
//								iterNewAlign->m_iScore = rScore.GetValue().GetInt();
//							}
//						}
//						else if (rStr == "e_value")
//						{
//							if (rScore.IsSetValue() && rScore.CanGetValue())
//							{
//								iterNewAlign->m_dEValue = rScore.GetValue().GetReal();
//							}
//						}
//						else if (rStr == "bit_score")
//						{
//							if (rScore.IsSetValue() && rScore.CanGetValue())
//							{
//								iterNewAlign->m_dBitScore = rScore.GetValue().GetReal();
//							}
//						}
//						else if (rStr == "num_ident")
//						{
//							if (rScore.IsSetValue() && rScore.CanGetValue())
//							{
//								iterNewAlign->m_iNumIdent = rScore.GetValue().GetInt();
//							}
//						}
//					}
//				}
//			}
//		}
//	}
//}




//void CNcbiCdAlignProcessor::ProcessCDQuery(const list<ncbi::CRef<ncbi::objects::CSeq_align> > &rAligns, TDomQuery &dst, vector<PssmId_t> *missed) const
//{
//	ProcessCDAlign(rAligns, dst.m_vecAlignments);
//	vector<PssmId_t> vecMissed;
//	
//	vector<PssmId_t> &missed_pssmids = nullptr == missed ? vecMissed : *missed;
//	
//	if (!dst.m_bIsNa)
//	{
//		Calculate(dst.m_vecAlignments, dst.m_dimSplitAligns[0], missed_pssmids);
//	}
//	else
//	{
//		vector<size_t> rfIndice[READINGFRAME::TOTAL_RFS];
//		CCdAlignProcessor::SortReadingFrames(rfIndice, dst);
//		for (int i = 0; i < READINGFRAME::TOTAL_RFS; ++i)
//		{
//
//			if (!rfIndice[i].empty())
//			{
//				vecMissed.clear();
//
//				Calculate(dst.m_vecAlignments, rfIndice[i], dst.m_dimSplitAligns[i], missed_pssmids);
//
//			}
//		}
//	}
//}


void CNcbiCdAlignProcessor::ProcessCDQuery(const list<ncbi::CRef<ncbi::objects::CSeq_align> > &rAligns, TDomQuery &dst, vector<PssmId_t> *missed) const
{
	
	ProcessCDAlign(rAligns, dst.m_vecAlignments);
	//for (list<CRef<CSeq_align> > :: const_iterator iterSrc = rAligns.begin(); iterSrc != rAligns.end(); ++iterSrc)
	//
	//	const CSeq_align& rSeq_align = **iterSrc;
	//
	//	const CSeq_align::TSegs & segs = rSeq_align.GetSegs();
	//	
	//	TDomSeqAlignment newalign;
	//	
	//	CRef<CSeq_id> hit_id = ParseAlignSegs(segs, newalign);
	//	
	//	if (!hit_id.IsNull())	//invalid aligns
	//	{
	//		PssmId_t uiPssmId = x_GetPssmId(*hit_id);
	//		
	//		if (uiPssmId > 0)
	//		{
	//			newalign.m_uiPssmId = uiPssmId;
	//			ParseAlignScores(**iterSrc, newalign);
	//			dst.m_vecAlignments.emplace_back(move(newalign));
	//		}
	//	}
	//
	
	vector<PssmId_t> vecMissed;
	
	vector<PssmId_t> &missed_pssmids = nullptr == missed ? vecMissed : *missed;
	
	if (!dst.m_bIsNa)
	{
		Calculate(dst.m_vecAlignments, dst.m_dimSplitAligns[0], missed_pssmids);
	}
	else
	{
		vector<size_t> rfIndice[READINGFRAME::TOTAL_RFS];
		CCdAlignProcessor::SortReadingFrames(rfIndice, dst);
		for (int i = 0; i < READINGFRAME::TOTAL_RFS; ++i)
		{

			if (!rfIndice[i].empty())
			{
				vecMissed.clear();

				Calculate(dst.m_vecAlignments, rfIndice[i], dst.m_dimSplitAligns[i], missed_pssmids);

			}
		}
	}
}



// -- TSeqLocInfoVector = vector< TMaskedQueryRegions >
void CNcbiCdAlignProcessor::ProcessBlastResults(list<TDomQuery> &dst, const list<CRef<CSeq_entry> > &qseqs, const TSeqLocInfoVector & masks, const list< CRef<CSeq_align > > &aligns, int gcode, vector<PssmId_t> *missed) const
{
	if (!qseqs.empty())
	{
		list<CRef<CSeq_entry> > :: const_iterator iterSeq = qseqs.begin(), iterSeqEnd = qseqs.end();
		list< CRef<CSeq_align > > :: const_iterator iterAlign = aligns.begin(), iterAlignEnd = aligns.end();
		TSeqLocInfoVector :: const_iterator iterMask = masks.begin(), iterMaskEnd = masks.end();
		
		list< CRef< CSeq_align > > lstAligns;
		
		
		while (iterSeqEnd != iterSeq && iterAlignEnd != iterAlign)
		{

			const CBioseq &seq = (*iterSeq)->GetSeq();	//offline sequence, assume to be seq, no more check
			const CSeq_id* seqid = seq.GetLocalId();
			
			const CSeq_id&  aligned = (*iterAlign)->GetSeq_id(0);
			
			
			if (!seqid->Match(aligned))
			{
				if (!lstAligns.empty())
				{
					list<TDomQuery> :: iterator iterDQ = dst.emplace(dst.end());
					TDomQuery &dstdq = *iterDQ;
					FillSequenceFromBioseq(seq, dstdq);
					dstdq.m_iGenCode = gcode;
					
					if (iterMaskEnd != iterMask)
					{
						size_t totalMasks = iterMask->size();
						if (totalMasks > 0)
						{
							dstdq.m_vecMaskedRegions.reserve(totalMasks);
							for (TMaskedQueryRegions::const_iterator iterReg = iterMask->begin(); iterReg != iterMask->end(); ++iterReg)
							{
								const CSeq_interval &rInt = (*iterReg)->GetInterval();
								dstdq.m_vecMaskedRegions.emplace_back(rInt.GetFrom(), rInt.GetTo(), (*iterReg)->GetFrame());
							}
						}
						++iterMask;
					}
					
					
					ProcessCDQuery(lstAligns, dstdq, missed);
					lstAligns.clear();
				}
				++iterSeq;	//advance sequence
			}
			else	//match -- this sequence
			{
				lstAligns.emplace_back(*iterAlign);
				++iterAlign;
			}
		}
		// -- last sequence
		if (!lstAligns.empty() && iterSeqEnd != iterSeq)
		{
			const CBioseq &seq = (*iterSeq)->GetSeq();	//offline sequence, assume to be seq, no more check
			list<TDomQuery> :: iterator iterDQ = dst.emplace(dst.end());
			TDomQuery &dstdq = *iterDQ;
			FillSequenceFromBioseq(seq, dstdq);
			dstdq.m_iGenCode = gcode;
			
			if (iterMaskEnd != iterMask)
			{
				size_t totalMasks = iterMask->size();
				if (totalMasks > 0)
				{
					dstdq.m_vecMaskedRegions.reserve(totalMasks);
					for (TMaskedQueryRegions::const_iterator iterReg = iterMask->begin(); iterReg != iterMask->end(); ++iterReg)
					{
						const CSeq_interval &rInt = (*iterReg)->GetInterval();
						dstdq.m_vecMaskedRegions.emplace_back(rInt.GetFrom(), rInt.GetTo(), (*iterReg)->GetFrame());
					}
				}
				++iterMask;
			}
			
			ProcessCDQuery(lstAligns, dstdq, missed);
		}
	}
}




