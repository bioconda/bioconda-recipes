#include <ncbi_pch.hpp>
#include "offl_cd_align_proc.hpp"
//#include "basicutils.hpp"
//#if defined(__BLAST_XML2__)
//#include <objects/blastxml2/blastxml2__.hpp>
//#else
//#include <objects/blastxml/blastxml__.hpp>
//#endif
#include <objects/seq/seq__.hpp>
#include <objects/seqset/seqset__.hpp>
#include <corelib/ncbistr.hpp>
#include <corelib/ncbifile.hpp>

USING_NCBI_SCOPE;
using namespace objects;

void _TOfflDomQuery::NACommit(void)
{
	m_bIsNa = true;
	//m_iMolType = CSeq_inst::eMol_na;
	SeqLen_t aaLen = m_uiSeqLen / 3;
	
	m_dimTranslated[0].clear();
	m_dimTranslated[0].append(aaLen, '-');
	
	m_dimTranslated[3] = m_dimTranslated[0];
	
	aaLen = (m_uiSeqLen - 1) / 3;
	
	m_dimTranslated[1].clear();
	m_dimTranslated[1].append(aaLen, '-');
	
	m_dimTranslated[4] = m_dimTranslated[1];
	
	aaLen = (m_uiSeqLen - 2) / 3;
	
	m_dimTranslated[2].clear();
	m_dimTranslated[2].append(aaLen, '-');
	m_dimTranslated[5] = m_dimTranslated[2];
}

void _TOfflDomQuery::PRCommit(void)
{
	m_bIsNa = false;
	//m_iMolType = CSeq_inst::eMol_aa;
	m_dimTranslated[0].clear();
	m_dimTranslated[0].append(m_uiSeqLen, '-');
}

void _TOfflDomQuery::ParseAlignStrings(const string &qseq, const string &hseq, SeqPos_t qf, SeqPos_t hf, SeqPos_t start, SeqLen_t n, SeqLen_t qofs, TDomSeqAlignment &dst, READINGFRAME::TFRAMEINDEX rfidx)
{
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering ParseAlignStrings:" << endl;
cerr << "rfidx = " << rfidx << ", start = " << start << ", n = " << n << ", qf = " << qf << ", hf = " << hf << endl;
cerr << qseq << endl;
cerr << hseq << endl;
cerr << "============================================================================================" << endl;
#endif
// **************************************************/
	SeqLen_t segLen = 0;
	bool bEffSeg = true;

	while (start < n)
	{

		if (bEffSeg)	//initially, both chains are in effect
		{
			if ('-' != qseq[start] && '-' != hseq[start])
				++segLen;
			else
			{

				bEffSeg = false;
				
				dst.m_vecMStarts.push_back(qf - qofs);
				dst.m_vecSStarts.push_back(hf);
				dst.m_vecLens.push_back(segLen);
				
				// -- write in master sequence data
				m_dimTranslated[rfidx].replace(qf, segLen, qseq, start - segLen, segLen);
				
				qf += segLen;
				hf += segLen;
				segLen = 0;
				if ('-' == qseq[start])
					--qf;
				else
				{
					--hf;
					//write in one more residue
					m_dimTranslated[rfidx][qf] = qseq[start];
				}
			}
		}
		else	//not in effective seg
		{
			//!bEffSeg
			bool segStart = true;
			if ('-' != qseq[start])
			{
				++qf;
				m_dimTranslated[rfidx][qf] = qseq[start];
			}
			else
				segStart = false;
				
			if ('-' != hseq[start])
				++hf;
			else
				segStart = false;
				
			if ((bEffSeg = segStart)) ++segLen;
			
		}
			
		++start;
	}//while
	// -- last segment
	if (bEffSeg && segLen > 0)
	{

		dst.m_vecMStarts.push_back(qf - qofs);
		dst.m_vecSStarts.push_back(hf);
		dst.m_vecLens.push_back(segLen);
		
		m_dimTranslated[rfidx].replace(qf, segLen, qseq, start - segLen, segLen);
	}
/*DEBUG**********************************************/
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Parsed Alignments:" << endl;
for (size_t i = 0; i < dst.m_vecLens.size(); ++i)
{
	cerr << '[' << dst.m_vecMStarts[i] << ',' << dst.m_vecSStarts[i] << ',' << dst.m_vecLens[i] << ']';
}
cerr << "dst.m_ReadingFrame = " << dst.m_ReadingFrame << endl;
cerr << "m_dimTranslated[" << rfidx << "] = " << m_dimTranslated[rfidx] << endl;
#endif
// **************************************************/
}


void COfflCdAlignProcessor::ParseBlastOutput(_TOfflDomQuery &dst, const CIteration &blastout, vector<PssmId_t> &missed, double evcut) const
{
	dst.m_vecAlignments.clear();
	
	if (blastout.CanGetQuery_ID())
		dst.m_strCleanedInput = dst.m_strAccession = blastout.GetQuery_ID();
	
	if (blastout.CanGetQuery_def())
		dst.m_strTitle = blastout.GetQuery_def();	//length of original sequence, could be na
	
	if (blastout.CanGetQuery_len())
		dst.m_uiSeqLen = blastout.GetQuery_len();	//length of original sequence, could be na
		
	
	if (blastout.CanGetMessage())
		dst.m_strMessage = blastout.GetMessage();	//length of original sequence, could be na
		
	if (blastout.CanGetHits())
	{
		const CIteration::THits &hits = blastout.GetHits();	//list< CRef< CHit > >
		if (!hits.empty())
		{
			dst.m_vecAlignments.reserve(hits.size() * 3);	//estimated
			
			TDomSeqAlignment alnVal;
			
			for (CIteration::THits::const_iterator iterHit = hits.begin(), iterHitEnd = hits.end(); iterHitEnd != iterHit; ++iterHit)
			{
				PssmId_t pssmid = (unsigned int)atoi((*iterHit)->GetAccession().c_str());
				
				SeqLen_t cdLen = (*iterHit)->GetLen();
				const CHit::THsps &hsps = (*iterHit)->GetHsps();	//list< CRef< CHsp > > THsps
				for (CHit::THsps::const_iterator iterHsp = hsps.begin(), iterHspEnd = hsps.end(); iterHspEnd != iterHsp; ++iterHsp)
				{
					double eval = (*iterHsp)->GetEvalue();
					if (eval > evcut) continue;
					
					dst.m_vecAlignments.push_back(alnVal);
					TDomSeqAlignment &currAlign = *dst.m_vecAlignments.rbegin();
					
					currAlign.m_uiPssmId = pssmid;
					currAlign.m_uiAlignedLen = (*iterHsp)->GetAlign_len();
					currAlign.m_iScore = (int)((*iterHsp)->GetScore() + 0.5);
					currAlign.m_dEValue = eval;
					currAlign.m_dBitScore = (*iterHsp)->GetBit_score();
					currAlign.m_iNumIdent = (*iterHsp)->GetIdentity();
					currAlign.m_dSeqIdentity = (double)currAlign.m_iNumIdent / (double)cdLen * 100.0;
					//currAlign.m_ReadingFrame = (*iterHsp)->GetQuery_frame();
					
					currAlign.m_iFrom = (*iterHsp)->GetQuery_from() - COORDSBASE;
					currAlign.m_iTo = (*iterHsp)->GetQuery_to() - COORDSBASE;
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": currAlign.m_iFrom = " << currAlign.m_iFrom << ", currAlign.m_iTo = " << currAlign.m_iTo << endl;
#endif
// **************************************************/					
					int rf = (*iterHsp)->GetQuery_frame();
					
					
					if (rf > 0)	//NA committed
					{
						currAlign.m_ReadingFrame = READINGFRAME::PlusId2PlusRFIdx(rf, dst.m_uiSeqLen);
						if (dst.m_dimTranslated[0].empty())	//not filled yet
							dst.NACommit();
					}
					else if (rf < 0)	//NA determined.
					{
						currAlign.m_ReadingFrame = READINGFRAME::MinusId2PlusRFIdx(rf, dst.m_uiSeqLen) | ((currAlign.m_iTo / 3) << 2);
						if (dst.m_dimTranslated[0].empty())	//not filled yet
							dst.NACommit();
					}
					else if (dst.m_dimTranslated[0].empty())	//not filled yet
						dst.PRCommit();
						
					
					
					// -- start to parse sequence
					const string &qseq = (*iterHsp)->GetQseq(), hseq = (*iterHsp)->GetHseq();
					SeqLen_t alnLen = qseq.size();
					SeqPos_t alnResIdx = 0;	//assume qseq.size() == hseq.size()
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": qseq = " << qseq << ", hseq = " << hseq << ", alnLen = " << alnLen << endl;
#endif
// **************************************************/
					// -- incase of blast problem...
					// -- trim unaligned regions from beginning
					while (alnResIdx < alnLen && ('-' == qseq[alnResIdx] || '-' == hseq[alnResIdx])) ++alnResIdx;
					
					// -- see if NA
					if (dst.m_dimTranslated[0].empty())	//not filled yet
					{
						SeqLen_t aaRes = 0;
						SeqPos_t t0 = alnResIdx;
						
						while (t0 < alnLen)
						{
							if ('-' == qseq[t0])
								++t0;
							else
							{
								size_t t1 = qseq.find('-', t0);
								if (string::npos == t1)	//
									t1 = alnLen;
								aaRes += t1 - t0;
								t0 = t1 + 1;
							}
						}
						if (aaRes == currAlign.m_iTo - currAlign.m_iFrom + 1)
							dst.PRCommit();
						else if (aaRes * 3 == currAlign.m_iTo - currAlign.m_iFrom + 1)
							dst.NACommit();
					}
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": dst.m_bIsNa = " << dst.m_bIsNa << endl;
#endif
// **************************************************/
					//if (dst.m_iMolType == CSeq_inst::eMol_aa)
					if (!dst.m_bIsNa)
					{
						currAlign.m_ReadingFrame = 0;	//0 is invalid for real reading frames, but a sign for protein sequence
						currAlign.m_eAlignType = TSeqAlignment::eNormal;
						//currAlign.m_eStrand = eNa_strand_unknown;
						currAlign.m_bIsMinus = false;
						SeqPos_t qfrom = currAlign.m_iFrom, hfrom = (*iterHsp)->GetHit_from() - COORDSBASE;
						
						dst.ParseAlignStrings(qseq, hseq, qfrom, hfrom, alnResIdx, alnLen, 0, currAlign, 0);
						dst.m_strSeqData = dst.m_dimTranslated[0];
					}
					else// if (dst.m_iMolType == CSeq_inst::eMol_na)	//na
					{
						
						
						currAlign.m_eAlignType = TSeqAlignment::ePr2Na;
						SeqLen_t alignedLen = currAlign.m_ReadingFrame >> 2;
						
						
						// -- calculate 
						int rfidx = currAlign.m_ReadingFrame & READINGFRAME::RF_SIZE;
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": rfidx = " << rfidx << endl;
#endif
// **************************************************/						
						if (0 == alignedLen)	//plus
						{
							//currAlign.m_eStrand = eNa_strand_plus;
							currAlign.m_bIsMinus = false;
							//currAlign.m_ReadingFrame -= 1;	//from 1, 2, 3 to 0, 1 ,2
							
							SeqPos_t qfrom = READINGFRAME::PlusNA2PlusPr(currAlign.m_iFrom, currAlign.m_ReadingFrame, dst.m_uiSeqLen),
								hfrom = (*iterHsp)->GetHit_from() - COORDSBASE;
							
							//SeqPos_t qfrom = currAlign.NAPlus2Pr(currAlign.m_iFrom), 

/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Before ParseAlignStrings, dst.m_dimTranslated[" << rfidx << "] = " << dst.m_dimTranslated[rfidx] << endl;
#endif
// **************************************************/
							dst.ParseAlignStrings(qseq, hseq, qfrom, hfrom, alnResIdx, alnLen, 0, currAlign, rfidx);
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": After ParseAlignStrings, dst.m_dimTranslated[" << rfidx << "] = " << dst.m_dimTranslated[rfidx] << endl;
#endif
// **************************************************/

						}	//plus strand
						else	//minus strand
						{
							rfidx = READINGFRAME::PlusRFIdx2MinusRFIdx(rfidx, dst.m_uiSeqLen);
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": rfidx = " << rfidx << endl;
#endif
// **************************************************/							
							//currAlign.m_eStrand = eNa_strand_minus;
							currAlign.m_bIsMinus = true;
							// -- squeeze m_uiSeqLen in currAlign.m_ReadingFrame, rf -1, -2, -3 -> 0, 1, 2
							//currAlign.m_ReadingFrame = (-currAlign.m_ReadingFrame - 1) | (m_uiSeqLen << 2);
							int qfrom = READINGFRAME::PlusNA2MinusPr(currAlign.m_iTo, rfidx, dst.m_uiSeqLen),
								hfrom = (*iterHsp)->GetHit_from() - COORDSBASE;
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": qfrom = " << qfrom << ", hfrom = " << hfrom << endl;
#endif
// **************************************************/
							dst.ParseAlignStrings(qseq, hseq, qfrom, hfrom, alnResIdx, alnLen, dst.m_dimTranslated[rfidx].size() - alignedLen, currAlign, rfidx);

						}
					}
					//else
					//	throw CSimpleException(__FILE__, __LINE__, "Unable to determine sequence type (protein or nucleotide)");
				}
			}
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": dst.m_vecAlignments.size() = " << dst.m_vecAlignments.size() << endl;
#endif
// **************************************************/			
			// -- calculate
			if (!dst.m_vecAlignments.empty())
			{
				size_t ttlAligns = dst.m_vecAlignments.size();
				//if (CSeq_inst::eMol_aa == dst.m_iMolType)	//protein
				if (!dst.m_bIsNa)	//protein
				{
					vector<size_t> ttlIndice;
					ttlIndice.reserve(ttlAligns);
					for (size_t i = 0; i < ttlAligns; ++i)
						ttlIndice.push_back(i);
					Calculate(dst.m_vecAlignments, ttlIndice, dst.m_dimSplitAligns[0], missed);
				}
				else
				{
					vector<size_t> rfIndice[READINGFRAME::TOTAL_RFS];
					for (size_t i = 0; i < READINGFRAME::TOTAL_RFS; ++i)
						rfIndice[i].reserve(ttlAligns);
						
					SortReadingFrames(rfIndice, dst);
					
					for (size_t i = 0; i < READINGFRAME::TOTAL_RFS; ++i)
						Calculate(dst.m_vecAlignments, rfIndice[i], dst.m_dimSplitAligns[i], missed);
				}
			}
		}
	}
}

void COfflCdAlignProcessor::ParseBlastArchive(list<_TOfflDomQuery> &dst, const CBioseq_set &qseqs, const CSeq_align_set &align, double evcut) const
{
	const CBioseq_set::TSeq_set &seqset = qseqs.GetSeq_set();	//list< CRef< CSeq_entry > >
	
	if (!seqset.empty())
	{
		const CSeq_align_set::Tdata &alignset = align.Get();	//list< CRef< CSeq_align > >
			
		CBioseq_set::TSeq_set::const_iterator iterSeq = seqset.begin(), iterSeqEnd = seqset.end();
		CSeq_align_set::Tdata::const_iterator iterAlign = alignset.begin(), iterAlignEnd = alignset.end();

		
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
					list<_TOfflDomQuery> :: iterator iterDQ = dst.emplace(dst.end());
					_TOfflDomQuery &dstdq = *iterDQ;
					FillSequenceFromBioseq(seq, dstdq);

					if (dstdq.m_bIsNa)
						TranslateAll(dstdq.m_strSeqData, dstdq.m_iGenCode, dstdq.m_dimTranslated);
					else
						dstdq.m_dimTranslated[0] = dstdq.m_strSeqData;

					
					ProcessCDQuery(lstAligns, dstdq);

					lstAligns.clear();
				}
				
				++iterSeq;	//advance sequence
			}
			else	//match -- this sequence
			{

				double eval = 0.0;
				if ((*iterAlign)->GetNamedScore(CSeq_align::eScore_EValue, eval) && eval <= evcut)
					lstAligns.emplace_back(*iterAlign);

				++iterAlign;
			}
		}
	}
}
