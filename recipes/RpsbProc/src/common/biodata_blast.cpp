#include <ncbi_pch.hpp>
#include "biodata_blast.hpp"
#include <objects/blast/Blast4_mask.hpp>

USING_NCBI_SCOPE;
using namespace objects;


CRef<CSeq_id> ParseAlignSegs(const CSeq_align::TSegs &c_segs, TSeqAlignment &dst)
{
	CRef<CSeq_id> hit_id(nullptr);
	
	dst.Reset();
	CSeq_align::TSegs::E_Choice segs_type = c_segs.Which();

	dst.m_iFrom = k_INT_MAX;
	dst.m_iTo = 0;
	ENa_strand qstrand = eNa_strand_other;
	
	switch (segs_type)
	{
	
	case CSeq_align::TSegs::e_Denseg:	//dense seg is always pr::pr

		{
			const CDense_seg &denseg = c_segs.GetDenseg();
			const auto &ids = denseg.GetIds();
			if (!ids.empty())
			{
				hit_id = SerialClone(*(ids[1]));
				CleanAlignment(denseg.GetStarts(), denseg.GetLens(), dst.m_vecMStarts, dst.m_vecSStarts, dst.m_vecLens);

				
				size_t segs = dst.m_vecLens.size();

				if (segs > 0)
				{
					dst.m_iFrom = dst.m_vecMStarts[0];
					dst.m_iTo = dst.m_vecMStarts[segs - 1] + dst.m_vecLens[segs - 1] - 1;
				}
			}
		}
		break;
	
	case CSeq_align::TSegs::e_Std:
		{
			
			const CSeq_align::TSegs::TStd &stdsegs = c_segs.GetStd();
				
			if (!stdsegs.empty())
			{
				CSeq_align::TSegs::TStd::const_iterator iterStdSeg = stdsegs.begin(), iterStdSegEnd = stdsegs.end();
				
				const CStd_seg::TIds & idsTbl = (*iterStdSeg)->GetIds();	//vector< CRef< CSeq_id > >
				CStd_seg::TIds::const_iterator iter_hit_id = idsTbl.begin();
				++iter_hit_id;
				hit_id = SerialClone(**iter_hit_id);
			
				for (; iterStdSegEnd != iterStdSeg; ++iterStdSeg)
				{
					const CStd_seg::TLoc &seqlocs = (*iterStdSeg)->GetLoc();	//vector< CRef< CSeq_loc > >
					
					if (seqlocs[0]->IsNull() || seqlocs[1]->IsNull()) continue;	//unmapped. ignore
					
					CSeq_loc::E_Choice qloc_type = seqlocs[0]->Which(), hloc_type = seqlocs[1]->Which();
					if (CSeq_loc::e_Empty == qloc_type || CSeq_loc::e_Empty == hloc_type) continue;
					
					bool error = false;
					// -- query
					switch (qloc_type)
					{
					case CSeq_loc::e_Int:	//interval
						{
							const CSeq_interval &intv = seqlocs[0]->GetInt();
							SeqPos_t f = intv.GetFrom(), t = intv.GetTo();
							if (f < dst.m_iFrom) dst.m_iFrom = f;
							if (t > dst.m_iTo) dst.m_iTo = t;
							dst.m_vecMStarts.push_back(f);
							
							if (intv.CanGetStrand())
								qstrand = intv.GetStrand();
						}
						break;
					case CSeq_loc::e_Pnt:	//seq point
						{
							const CSeq_point &pnt = seqlocs[0]->GetPnt();
							SeqPos_t p = pnt.GetPoint();
							if (p < dst.m_iFrom) dst.m_iFrom = p;
							if (p > dst.m_iTo) dst.m_iTo = p;
							dst.m_vecMStarts.push_back(p);
							
							if (pnt.CanGetStrand())
								qstrand = pnt.GetStrand();
								
						}
						break;
					default:
						error = true;
						break;
					}
					if (!error)
					{

						// -- target, assume always protein
						switch (hloc_type)
						{
						case CSeq_loc::e_Int:	//interval
							{
								const CSeq_interval &intv = seqlocs[1]->GetInt();
								SeqPos_t f = intv.GetFrom(), t = intv.GetTo();
								
								dst.m_vecSStarts.push_back(f);
								dst.m_vecLens.push_back(t - f + 1);
								
									
							}
							break;
						case CSeq_loc::e_Pnt:	//seq point

							{
								const CSeq_point &pnt = seqlocs[1]->GetPnt();
								SeqPos_t p = pnt.GetPoint();
								
								dst.m_vecSStarts.push_back(p);
								dst.m_vecLens.push_back(1);
									
							}
							break;
						default:
							error = true;
							break;
						}
					}
				}
			
			}
		}
		break;
	case CSeq_align::TSegs::e_Packed:
		{
			const CPacked_seg &pkdseg = c_segs.GetPacked();	//packed segs are just like denseg
			const auto &ids = pkdseg.GetIds();
			if (!ids.empty())
			{
				hit_id = SerialClone(*(ids[1]));
				CleanAlignment(pkdseg.GetStarts(), pkdseg.GetLens(), dst.m_vecMStarts, dst.m_vecSStarts, dst.m_vecLens);
				
				size_t segs = dst.m_vecLens.empty();
				if (segs > 0)
				{
					dst.m_iFrom = dst.m_vecMStarts[0];
					dst.m_iTo = dst.m_vecMStarts[segs - 1] + dst.m_vecLens[segs - 1] - 1;
				}
				if (pkdseg.CanGetStrands())
				{
					const CPacked_seg::TStrands &strands = pkdseg.GetStrands();
					if (!strands.empty())
						qstrand = strands[0];
					
				}
			}
		}
		break;
	default:
		break;
	}
	
	/******************************************************************************************
	*	Even with minus strand query, the master coordinates are still in the plus chain positions.
	*	Therefore without the actual length, we cannot determine the reading frame coordinates on 
	*	minus strand. Thus, the previous "alignedLength" is still the best way to keep information.
	*	Also the "pseudo-protein" method allows the alignments to be used to map coordinates, without
	*	having to know the actual length of the query sequence.
	******************************************************************************************/
	if (!hit_id.IsNull() && eNa_strand_other != qstrand)	//na and pr
	{
		dst.m_eAlignType = TSeqAlignment::ePr2Na;
		dst.m_ReadingFrame = (dst.m_iFrom % READINGFRAME::RF_SIZE);	//always be the plus side rf
		
		if (eNa_strand_minus == qstrand || eNa_strand_both_rev == qstrand)
		{
			dst.m_bIsMinus = true;
			SeqLen_t alignedLen = (dst.m_iTo + 1) / READINGFRAME::RF_SIZE;
			dst.m_ReadingFrame |= (alignedLen << 2);	//keep this for align computation
			/**************************************************************************************
			*	Use alignedLen, we are constructint an "effective" peptide just for "chain mapping" use.
			*	It only contains aligned part of the real protein, and thus always at "effective"
			*	reading frame -1. Thus the aligned na length = (m_ReadingFrame >> 2) * 3 + m_ReadingFrame & READINGFRAME::RF_SIZE;
			*	When the length of nucleotide sequence is available, the real readingframe index 
			*	can be obtained from the plus side reading frame index by calling 
			*	static TFRAMEINDEX READINGFRAME::PlusRFIdx2MinusRFIdx(TFRAMEINDEX prfidx, SeqLen_t na_len);
			*	and the read aa residue coordinates can be obtained for any na plus strand coordinates
			*	by calling
			*	static SeqPos_t PlusNA2Pr(SeqPos_t na, TFRAMEINDEX rfidx, SeqLen_t na_len);
			**************************************************************************************/
			vector<SeqPos_t> :: iterator iterMS = dst.m_vecMStarts.begin(), iterMSEnd = dst.m_vecMStarts.end();
			vector<SeqLen_t> :: const_iterator iterL = dst.m_vecLens.begin();
			while (iterMS != iterMSEnd)
			{
				*iterMS = alignedLen - (*iterMS / READINGFRAME::RF_SIZE + *iterL);
				++iterMS;
				++iterL;
			}
		}
		else
		{
			for (vector<SeqPos_t> :: iterator iterMS = dst.m_vecMStarts.begin(), iterMSEnd = dst.m_vecMStarts.end(); iterMS != iterMSEnd; ++iterMS)
				*iterMS /= READINGFRAME::RF_SIZE;
		}
			
	}
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Parsed Alignments:" << endl;
for (size_t i = 0; i < dst.m_vecLens.size(); ++i)
{
	cerr << '[' << dst.m_vecMStarts[i] << ',' << dst.m_vecSStarts[i] << ',' << dst.m_vecLens[i] << ']';
}
cerr << "dst.m_ReadingFrame = " << dst.m_ReadingFrame << endl;
#endif
// **************************************************/
	return hit_id;
}

void ParseAlignScores(const CSeq_align &align, TSeqAlignment &dst)
{
	if (align.IsSetScore() && align.CanGetScore())
	{
		const CSeq_align::TScore& rScoreTab = align.GetScore();  //vector< CRef< CScore > >
		for (CSeq_align::TScore::const_iterator j = rScoreTab.begin(); j != rScoreTab.end(); ++j)
		{
			const CScore& rScore = **j;  //CScore
			
			if (rScore.IsSetId() && rScore.CanGetId())
			{
				const CScore::TId& rObjectId = rScore.GetId();  //CObject_id
					
				if (CObject_id::e_Str == rObjectId.Which())
				{
					const CObject_id::TStr& rStr = rObjectId.GetStr();    //string
					if (rStr == "score")
					{
						if (rScore.IsSetValue() && rScore.CanGetValue())
						{
							dst.m_iScore = rScore.GetValue().GetInt();
						}
					}
					else if (rStr == "e_value")
					{
						if (rScore.IsSetValue() && rScore.CanGetValue())
						{
							dst.m_dEValue = rScore.GetValue().GetReal();
						}
					}
					else if (rStr == "bit_score")
					{
						if (rScore.IsSetValue() && rScore.CanGetValue())
						{
							dst.m_dBitScore = rScore.GetValue().GetReal();
						}
					}
					else if (rStr == "num_ident")
					{
						if (rScore.IsSetValue() && rScore.CanGetValue())
						{
							dst.m_iNumIdent = rScore.GetValue().GetInt();
						}
					}
				}
			}
		}
	}
}

void ConvertBlastMaskListToSeqLocInfoVector(const TBlast4MaskList &bmlist, TSeqLocInfoVector &dst)
{

	TBlast4MaskList::const_iterator iterBM = bmlist.begin(), iterBMEnd = bmlist.end();
	
	const CSeq_id *pLastId = nullptr;
	TSeqLocInfoVector::iterator iterDstMaskedRegions = dst.end();
	while (iterBMEnd != iterBM)
	{
		const CBlast4_mask::TLocations &locs = (*iterBM)->GetLocations();	//list< CRef< CSeq_loc > > 

		if (!locs.empty())	//should always be true, expect only one
		{
			int rf = (*iterBM)->GetFrame();
			if (rf > 0)
				rf = READINGFRAME::Idx2Id(rf - 1);	//CSeqLocInfo::ETranslationFrame uses 0, 1, 2, 3, -1, -2, -3
			const CSeq_loc& loc = **locs.begin();
			const CSeq_id *thisId = loc.GetId();	//should not be null
		
			if (nullptr == pLastId || !thisId->Match(*pLastId))
			{

				// -- create a new TMaskedQueryRegions
				iterDstMaskedRegions = dst.emplace(dst.end());
				pLastId = thisId;
			}
			
			const list< CRef< CSeq_interval > > & ints = loc.GetPacked_int().Get();

			for (auto v : ints)
				iterDstMaskedRegions->emplace_back(new CSeqLocInfo(v.GetNCPointer(), rf));
		}
		
		++iterBM;
		
	}
}

//void CalculateBiasedRegions(const CBioseq& bioseq, vector<TSequence::__SegMask> &dst)
//{
//	static CSegMasker seg_masker;
//	
//	CSegMasker::TMaskList *pMaskList = nullptr;
//	
//	try
//	{
//		CSeqVector seqVec(bioseq);
//		
//		pMaskList = seg_masker(seqVec);
//		if (nullptr != pMaskList)
//		{
//			size_t totalSegs = 0;
//			
//			CSegSet segs;	//just for merge algorithm
//			for (CSegMasker::TMaskList::const_iterator iterSeg = pMaskList->begin(); iterSeg != pMaskList->end(); ++iterSeg)	//calculated segs could be overlapping, so do the merge.
//			{
//				segs.AddSeg(iterSeg->first, iterSeg->second);
//				++totalSegs;
//			}
//			
//			dst.reserve(totalSegs);
//			const CSegSet::TSegs& mSegs = segs.GetSegs();
//			
//			for (CSegSet::TSegs::const_iterator iterSeg = mSegs.begin(); iterSeg != mSegs.end(); ++iterSeg)
//			{
//				TSequence::__SegMask aSeg;
//				aSeg.from = iterSeg->from;
//				aSeg.to = iterSeg->to;
//				dst.push_back(aSeg);
//			}
//		}
//	}
//	catch (...)
//	{
//		;
//	}
//	delete pMaskList;
//}
