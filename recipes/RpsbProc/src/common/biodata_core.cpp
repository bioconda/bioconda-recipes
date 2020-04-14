#include <ncbi_pch.hpp>
#include "biodata_core.hpp"

#if defined(__DB_OFFLINE__)
#include "basealgo.hpp"
#else
#include <BasicUtils/basealgo.hpp>
#endif

#include <objects/general/general__.hpp>
#include <objects/seq/seqport_util.hpp>
#include <objects/seqfeat/seqfeat__.hpp>
#include <objmgr/util/sequence.hpp>

USING_NCBI_SCOPE;
using namespace objects;


CRef<CSeq_id> CreateMD5SeqId(const string &seqdata)
{
	CRef<CSeq_id> refUniqueId(new CSeq_id);
	refUniqueId->SetLocal().SetStr(CreateMD5SeqIdStr(seqdata));
	return refUniqueId;
}

bool IsMD5SeqId(const CObject_id &lclid)
{
	return (lclid.Which() == CObject_id::e_Str && 0 == lclid.GetStr().find(k_lpszEaaMD5));
}

string ExtractMD5FromMD5SeqId(const CSeq_id& seqid)
{
	string idstr;
	seqid.GetLabel(&idstr, CSeq_id::eContent);
	size_t pos = idstr.rfind('_');
	
	if (string::npos == pos)
		return GetEmptyString();
	return idstr.substr(pos + 1);
}

void PackSeqIds(const CBioseq::TId &ids, string &dst)
{
	dst.clear();
	if (!ids.empty())
	{
		stringstream ss;
		CBioseq::TId::const_iterator iterId = ids.begin(), iterIdEnd = ids.end();
		while (iterIdEnd != iterId)
		{
			ObjStreamOut<CSeq_id> (ss, **iterId, eSerial_AsnBinary);
			++iterId;	
		}
		string userids = ss.str();
		size_t ttlChars = userids.size();
		if (ttlChars > 0)
		{
			char *pB64Str = B64Encode(userids.data(), ttlChars);	//ttlChars will be changed to size of pB64Str;
			dst = pB64Str;
			delete []pB64Str;
		}
	}
}

void UnpackSeqIds(const string &packed, CBioseq::TId &ids)
{
	size_t plen = packed.size();

	BYTE * result = B64Decode(packed.data(), plen);

	string unpacked;
	unpacked.append(reinterpret_cast< char* > (result), plen);
	
	stringstream ss(unpacked, ios::in);
	ids.clear();
	while (ss.good())
	{
		CRef<CSeq_id> ref(new CSeq_id);
		try
		{
			ObjStreamIn<CSeq_id> (ss, *ref, eSerial_AsnBinary);
			ids.emplace_back(ref);
		}
		catch (...)
		{
			break;
		}
	}
}

string GetAccessionFromSeqId(const CSeq_id& seqid)
{
	switch(seqid.Which())
	{
		case CSeq_id::e_Gi:
			return NcbiEmptyString;
		case CSeq_id::e_Pdb:
		{
			const CPDB_seq_id& rPdbId = seqid.GetPdb();
			string strMol = rPdbId.GetMol().Get();
			strMol.push_back(char(rPdbId.GetChain()));
			return strMol;
		}
		default:
			return seqid.GetSeqIdString();
	}
}



// -- use CSeqTranslator:
//https://intranet.ncbi.nlm.nih.gov/ieb/ToolBox/CPP_DOC/lxr/source/include/objmgr/util/sequence.hpp#L941
void TranslateAll(const string &NASeq, int gcode, string dimAaData[])
{
	for (int i = 0; i < READINGFRAME::TOTAL_RFS; ++i) dimAaData[i].clear();

	size_t seqLen = NASeq.size();
	if (seqLen > 0)	//at least one
	{
		string trans(NASeq), cmpNa(GetComplementSeq(NASeq));
		CGenetic_code gc;
		CRef<CGenetic_code::C_E> ce(new CGenetic_code::C_E);
		ce->SetId(gcode);
		gc.Set().push_back(ce);
		//CmplConvert(NASeq, cmpNa);
		// -- positive strand, rfidx 0 -2 (rf 1 - 3)
		for (int i = 0; i < READINGFRAME::RF_SIZE; ++i)
		{
			CSeqTranslator::Translate(trans, dimAaData[i], CSeqTranslator::fIs5PrimePartial/* | CSeqTranslator::fIs3PrimePartial*/, &gc);
			for (size_t j = 0, jEnd = dimAaData[i].size(); j < jEnd; ++j)
				if ('*' == dimAaData[i][j]) dimAaData[i][j] = 'X';

			trans.erase(trans.begin());
		}
		
		//rfidx 3 -5 (rf -1 - -3)
		for (int i = READINGFRAME::RF_SIZE; i < READINGFRAME::TOTAL_RFS; ++i)
		{
			CSeqTranslator::Translate(cmpNa, dimAaData[i], CSeqTranslator::fIs5PrimePartial/* | CSeqTranslator::fIs3PrimePartial*/, &gc);
			for (size_t j = 0, jEnd = dimAaData[i].size(); j < jEnd; ++j)
				if ('*' == dimAaData[i][j]) dimAaData[i][j] = 'X';

			cmpNa.erase(cmpNa.begin());
		}
	}
}


int SeqDataTo1LtrSeq(const CSeq_data &rSeqData, string &dst)
{
	dst.clear();
	int iDataType = rSeqData.Which();
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering SeqDataTo1LtrSeq, iDataType = " << iDataType << endl;
#endif
// **************************************************/
	switch (iDataType)
	{
	case CSeq_data::e_Ncbieaa:

		dst = rSeqData.GetNcbieaa().Get();

		iDataType = 0;
		break;
	case CSeq_data::e_Ncbi8aa:
	case CSeq_data::e_Ncbipaa:
	case CSeq_data::e_Iupacaa:
	case CSeq_data::e_Ncbistdaa:	//all other aa format
		{
			CSeq_data objEaaData;
			CSeqportUtil::Convert(rSeqData, &objEaaData, CSeq_data::e_Ncbieaa);
			dst = objEaaData.GetNcbieaa().Get();
		}
		iDataType = 0;
		break;
	case CSeq_data::e_Iupacna:
		dst = rSeqData.GetIupacna().Get();


		iDataType = 1;
		break;
	case CSeq_data::e_Ncbi2na:
	case CSeq_data::e_Ncbi4na:
	case CSeq_data::e_Ncbi8na:
	case CSeq_data::e_Ncbipna:
		{
			CSeq_data objIupacData;
			CSeqportUtil::Convert(rSeqData, &objIupacData, CSeq_data::e_Iupacna);


			dst = objIupacData.GetIupacna().Get();
/*DEBUG**********************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": dst.size() = " << dst.size() << endl;
#endif
// **************************************************/
		}
		iDataType = 1;
		break;
	default:
		iDataType = -1;
	}
	return iDataType;
}

string Get1LetterSeqData(const CSeq_inst& rSeqInst)
{
	string dst;
	if (rSeqInst.IsSetSeq_data() && rSeqInst.CanGetSeq_data())
	{
		SeqDataTo1LtrSeq(rSeqInst.GetSeq_data(), dst);
	}
	else if (rSeqInst.IsSetExt() && rSeqInst.CanGetExt())
	{
		const CSeq_ext &rSeqExt = rSeqInst.GetExt();
		
		switch (rSeqExt.Which())
		{
		case CSeq_ext::e_not_set:
		case CSeq_ext::e_Seg:
		case CSeq_ext::e_Ref:
		case CSeq_ext::e_Map:
			break;
		case CSeq_ext::e_Delta:
			{
				const CDelta_ext::Tdata &rDeltaExt_data = rSeqExt.GetDelta().Get();	//typedef list< CRef< CDelta_seq > > Tdata;
				int litType = -1;
				for (CDelta_ext::Tdata::const_iterator iter = rDeltaExt_data.begin(), iterEnd = rDeltaExt_data.end(); iterEnd != iter; ++iter)
				{
					switch ((*iter)->Which())
					{
					case CDelta_seq::e_Literal:
						{
							const CSeq_literal &rSeqLit = (*iter)->GetLiteral();
							if (rSeqLit.IsSetSeq_data() && rSeqLit.CanGetSeq_data())
							{
								string tmp(k_strEmptyString);
								int stype = SeqDataTo1LtrSeq(rSeqLit.GetSeq_data(), tmp);
								if (stype >= 0)	//valid
								{
									if (litType < 0) litType = stype;
									
									if (litType == stype)	//same aa or na
										dst.append(tmp);
								}
							}								
						}
						break;
					}
				}
			}
		}
	}
	
	// -- somehow the CSeqportUtil::Convert may append an extra residue to the result (bug?), so check 
	SeqLen_t ori_len = rSeqInst.GetLength(), end_len = dst.size();
	if (ori_len < end_len)
	{
		dst.erase(ori_len);
	}
	return dst;
}


bool IsProtein(const CSeq_inst& rSeqInst)
{
	return (rSeqInst.CanGetMol() && rSeqInst.GetMol() == CSeq_inst::eMol_aa);
}




GI_t GetGiFromBioseq(const CBioseq& rBioseq)
{
	string strGi = CSeq_id::GetStringDescr(rBioseq, CSeq_id::eFormat_ForceGI);
	size_t pos = strGi.find('|');	//find the first '|'
	if (string::npos != pos)
		strGi = strGi.substr(pos + 1, strGi.size() - pos - 1);
	try
	{
		return NStr::StringToNumeric<GI_t>(strGi);
	}
	catch (...)
	{;}
	return 0;
}


string GetBestAccFromBioseq(const CBioseq& rBioseq)
{
	string strAcc = CSeq_id::GetStringDescr(rBioseq, CSeq_id::eFormat_BestWithoutVersion);
	size_t pos = strAcc.find('|');	//find the first '|'
	if (string::npos == pos) return strAcc;
	return strAcc.substr(pos + 1, strAcc.size() - pos - 1);
}

SeqLen_t GetSeqLengthFromBioseq(const CSeq_inst& rSeqInst)
{
	if (rSeqInst.IsSetLength() && rSeqInst.CanGetLength())
		return (SeqLen_t)rSeqInst.GetLength();
	return (SeqLen_t)Get1LetterSeqData(rSeqInst).size();
}

const string& GetDescrTitleFromBioseq(const CBioseq& rBioseq)
{
	if (rBioseq.IsSetDescr() && rBioseq.CanGetDescr())
	{
		const CSeq_descr& rDescr = rBioseq.GetDescr();
		if (rDescr.IsSet() && rDescr.CanGet())
		{
			const CSeq_descr::Tdata& rSeqDescTab = rDescr.Get(); 
			CSeq_descr::Tdata::const_iterator i;
			for (i = rSeqDescTab.begin(); i != rSeqDescTab.end(); ++i)
			{
				const CSeqdesc& rSeqDesc = **i;  //CSeqdesc

				CSeqdesc::E_Choice c = rSeqDesc.Which();
				if (CSeqdesc::e_Title == c)
				{
					return rSeqDesc.GetTitle();
				}
			}
		}
	}
	
	if (rBioseq.IsSetAnnot() && rBioseq.CanGetAnnot())
	{
		const CBioseq::TAnnot &rAnnots = rBioseq.GetAnnot();	//list< CRef< CSeq_annot > > TAnnot
		for (CBioseq::TAnnot::const_iterator iter = rAnnots.begin(), iterEnd = rAnnots.end(); iterEnd != iter; ++iter)
		{
			const CSeq_annot::TData &annotData = (*iter)->GetData();
			if (annotData.IsFtable())
			{
				const CSeq_annot::TData::TFtable &ftable = annotData.GetFtable();	//list< CRef< CSeq_feat > > TFtable
				
				for (CSeq_annot::TData::TFtable::const_iterator iterF = ftable.begin(), iterFEnd = ftable.end(); iterFEnd != iterF; ++iterF)
				{
					if ((*iterF)->IsSetData() && (*iterF)->CanGetData())
					{
						const CSeq_feat::TData &featData = (*iterF)->GetData();
						
						if (rBioseq.IsNa())
						{
							if (CSeqFeatData::e_Gene == featData.Which())
							{
								const CGene_ref &geneRef = featData.GetGene();
								if (geneRef.IsSetDesc() && geneRef.CanGetDesc())
									return geneRef.GetDesc();
							}
						}
						else
						{
							if (CSeqFeatData::e_Prot == featData.Which())
							{
								const CProt_ref &protRef =  featData.GetProt();
								if (protRef.IsSetName() && protRef.CanGetName())
								{
									const CProt_ref::TName &pnames = protRef.GetName();	//list< string > TName
									if (!pnames.empty())
									{
										return *pnames.begin();
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	return NcbiEmptyString;
}

string GetEaaData(const CBioseq& rBioseq)
{
	const CSeq_inst &rInst = rBioseq.GetInst();
	if (rInst.IsSetSeq_data() && rInst.CanGetSeq_data())
	{
		const CSeq_data& rData = rInst.GetSeq_data();
		if (rData.Which() == CSeq_data::e_Ncbieaa)
		{
			return rData.GetNcbieaa().Get();
		}
		else if (!rBioseq.IsNa())
		{
			string strNcbiEaaData(NcbiEmptyString);
			//CSeq_data *pEaaData = new CSeq_data();
			CSeq_data objEaaData;
			CSeqportUtil::Convert(rData, &objEaaData, CSeq_data::e_Ncbieaa);
			return objEaaData.GetNcbieaa().Get();
			//strNcbiEaaData = pEaaData->GetNcbieaa().Get();
			//delete pEaaData;
			//return strNcbiEaaData;
		}
	}
	return NcbiEmptyString;
}

string GetFastaDeflineFromBioseq(const CBioseq& rBioseq)
{
	return CSeq_id::GetStringDescr(rBioseq, CSeq_id::eFormat_FastA);
}

string GetFirstDescrTitleFromBioseq(const CBioseq& rBioseq)
{
	const string &rFullTitle = GetDescrTitleFromBioseq(rBioseq);
	if (NcbiEmptyString == rFullTitle) return rFullTitle;
	size_t ulFirstGT = rFullTitle.find('>');
	if (string::npos == ulFirstGT)	//not found, return the whole thing
		return rFullTitle;
	else
		return rFullTitle.substr(0, ulFirstGT);
}


string GetMatchTitleFromBioseq(const CBioseq& rBioseq, const string& rPattern)
{
	const string &rFullTitle = GetDescrTitleFromBioseq(rBioseq);
	if (NcbiEmptyString == rFullTitle || NcbiEmptyString == rPattern) return rFullTitle;	//empty
	
	size_t ulPatPos = rFullTitle.find(rPattern);
	if (string::npos == ulPatPos) return NcbiEmptyString;
	size_t ulGTPos = rFullTitle.find('>');
	
	while (string::npos != ulGTPos)
	{
		size_t ulNextGTPos = rFullTitle.find('>', ulGTPos + 1);
		if (string::npos == ulNextGTPos)
		{
			return rFullTitle.substr(ulGTPos + 1);
		}
		else if (ulNextGTPos > ulPatPos)	//found
		{
			return rFullTitle.substr(ulGTPos + 1, ulNextGTPos - ulGTPos - 1);
		}
		else
		{
			ulGTPos = ulNextGTPos;
		}
	}

	return NcbiEmptyString;
}

void AddAutoMD5SeqIdToBioseq(CBioseq& rBioseq)
{
	
	CBioseq::TId& rIds = rBioseq.SetId();
	// -- test, avoid duplicate
	CBioseq::TId::iterator iter = rIds.begin();
	while (rIds.end() != iter)
	{
		if ((*iter)->Which() == CSeq_id::e_Local)
		{
			const CObject_id& rObjId = (*iter)->GetLocal();

			if (rObjId.IsStr())
			{
				const string &rLocalStrId = rObjId.GetStr();
				if (rLocalStrId.substr(0, k_AutoMD5IdSize) == k_lpszEaaMD5)	//already has it, return
					return;
				
				if (rLocalStrId.substr(0, k_BlastLocalIdSize) == k_lpszBlastDefLocalId)	//remove temperary id
				{
					CBioseq::TId::iterator tempIter = iter;
					++iter;
					rIds.erase(tempIter);
					continue;
				}
			}
		}
		++iter;
	}
	
	if (rBioseq.IsSetInst() && rBioseq.CanGetInst())
		rIds.emplace_front(CreateMD5SeqId(Get1LetterSeqData(rBioseq.GetInst())));
}

int IsLocalSequence(const CBioseq& rBioseq)
{
	const CBioseq::TId & rIds = rBioseq.GetId();
	for (CBioseq::TId::const_iterator iter = rIds.begin(); iter != rIds.end(); ++iter)
	{
		if ((*iter)->Which() == CSeq_id::e_Local)
		{
			const CObject_id& rObjId = (*iter)->GetLocal();
			if (rObjId.IsStr())
			{
				const string & rIdStr = rObjId.GetStr();
				if (rIdStr.substr(0, strlen(k_lpszEaaMD5)) == k_lpszEaaMD5) return 2;	//local and from cd-search
				if (rIdStr == k_lpszQueryId)	//uniformed, artificial local id, ignore
					continue;
			
			
				return 1;	//local but not from cdsearch
			}
		}
	}
	return 0;	//not local
}


void ObtainUserDeflineFromBioseq(const CBioseq &bioseq, string &dst)
{
	if (bioseq.CanGetDescr())
	{
		const CSeq_descr::Tdata & rDescrLst = bioseq.GetDescr().Get();	//list< CRef< CSeqdesc > >
		for (CSeq_descr::Tdata::const_iterator iterSeqDesc = rDescrLst.begin(); iterSeqDesc != rDescrLst.end(); ++iterSeqDesc)
		{
			if ((*iterSeqDesc)->Which() == CSeqdesc::e_User)
			{
				const CUser_object & rUsrDescr = (*iterSeqDesc)->GetUser();
				if (rUsrDescr.CanGetType())
				{
					const CObject_id& typeId = rUsrDescr.GetType();
					if (typeId.Which() == CObject_id::e_Str && NStr::EqualCase(typeId.GetStr(), "CFastaReader"))
					{
						const CUser_object::TData & usrDescrData = rUsrDescr.GetData();	//vector< CRef< CUser_field > >
						
						for (CUser_object::TData::const_iterator iterUsrField = usrDescrData.begin(); iterUsrField != usrDescrData.end(); ++iterUsrField)
						{
							const CObject_id& label = (*iterUsrField)->GetLabel();
							if (label.Which() == CObject_id::e_Str && NStr::EqualCase(label.GetStr(), "DefLine"))
							{
								const CUser_field::TData& fieldValue = (*iterUsrField)->GetData();
								const string& fieldStrVal = fieldValue.GetStr();
								if (!fieldStrVal.empty())
									dst += fieldStrVal;	//no longer cut off '>' char so that multiple defline can be recognized
							}
						}
					}
				}
			}
		}
	}
}




void TruncateDeflineInSeqAnnot(CSeq_annot& rTarget, size_t uiCutOff)
{
	if (rTarget.IsSetData() && rTarget.CanGetData())	//actually, data is mandatory
	{
		CSeq_annot::TData& rAnnotData = rTarget.SetData();
		if (rAnnotData.IsFtable())
		{
			CSeq_annot::TData::TFtable& rFTable = rAnnotData.SetFtable();
			for (CSeq_annot::TData::TFtable::iterator iter = rFTable.begin(); iter != rFTable.end(); ++iter)
			{
				if ((*iter)->CanGetExt())
				{
					const CObject_id& rObjType = (*iter)->GetExt().GetType();
					if (CObject_id::e_Str == rObjType.Which() && "cddScoreData" == rObjType.GetStr())
					{
						(*iter)->SetComment(TruncateDefline((*iter)->GetComment(), uiCutOff));
					}
				}
			}
		}
	}
}

void RemoveIncompleteFeaturesInSeqAnnot(CSeq_annot& rTarget, double dCompletenessCutOff)
{
	if (rTarget.IsSetData() && rTarget.CanGetData())	//actually, data is mandatory
	{
		CSeq_annot::TData& rAnnotData = rTarget.SetData();
		if (rAnnotData.IsFtable())
		{
			CSeq_annot::TData::TFtable& rFTable = rAnnotData.SetFtable();
			CSeq_annot::TData::TFtable::iterator iter = rFTable.begin();
			
			
			while (iter != rFTable.end())
			{
				if ((*iter)->CanGetExt())
				{
					const CUser_object &rFeatExt = (*iter)->GetExt();
					const CObject_id& rObjType = rFeatExt.GetType();
					if (CObject_id::e_Str == rObjType.Which() && "cddSiteScoreData" == rObjType.GetStr())
					{
						const CUser_object::TData &rFields = rFeatExt.GetData();	//vector< CRef< CUser_field > >
						
						for (CUser_object::TData::const_iterator iterField = rFields.begin(); iterField != rFields.end(); ++iterField)
						{
							if ((*iterField)->GetLabel().GetStr() == "completeness")
							{
								double dCompleteness = (*iterField)->GetData().GetReal();
								if (dCompleteness < dCompletenessCutOff)
								{
									CSeq_annot::TData::TFtable::iterator temp = iter;
									++iter;
									rFTable.erase(temp);
									goto labelNextFeat;
								}
							}
						}
					}
				}
				++iter;
			labelNextFeat:
				;
			}
		}
	}
}

void PaulAlignReplaceQueryLocal(string &rPaulOutput, const string &rAutoId, const string &rLocalId)
{
	// -- static
	static const char *preTag = "<pre>";
	static const size_t preTagSize = strlen(preTag);
	static const char *anchorStartTag = "<a ";
	static const char *anchorEndTag = "</a>";
	static const size_t anchorEndTagSize = strlen(anchorEndTag);
	static const char *fontTag = "<font color=";
	static const size_t fontTagSize = strlen(fontTag);
	static const char endTag = '>';
	//static const char *qAnchorTagConst = "<a href=\"https://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&doptcmdl=GenPept&db=Protein&term=";
	static const char *qAnchorTagConst = "://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&doptcmdl=GenPept&db=Protein&term=";
	
	if (!rPaulOutput.empty())
	{
		string qAnchorTag = qAnchorTagConst + rAutoId;
		size_t pre_tag_pos = rPaulOutput.find(preTag, 0);
		
		size_t q_anchor_pos = rPaulOutput.find(qAnchorTag, pre_tag_pos + preTagSize);
		//size_t qAnchorTagSize = qAnchorTag.size();
		
		//borrow newIdSize
		size_t newIdSize = rPaulOutput.rfind(anchorStartTag, q_anchor_pos);
		qAnchorTag = rPaulOutput.substr(newIdSize, q_anchor_pos - newIdSize) + qAnchorTag;
		size_t qAnchorTagSize = qAnchorTag.size();
		q_anchor_pos = newIdSize;
		
		newIdSize = rLocalId.size();
		size_t autoIdLen = rAutoId.size();

		
		size_t q_anchor_end = rPaulOutput.find(anchorEndTag, q_anchor_pos + qAnchorTagSize) + anchorEndTagSize;
		size_t cd_idspace_pos = rPaulOutput.find(anchorEndTag, q_anchor_end) + anchorEndTagSize;
		size_t cd_id_space = rPaulOutput.find(fontTag, cd_idspace_pos) - cd_idspace_pos;
		if (autoIdLen == newIdSize)	//no need to change
		{
			while (string::npos != q_anchor_pos)
			{
				size_t len = rPaulOutput.find(anchorEndTag, q_anchor_pos) + anchorEndTagSize - q_anchor_pos;
				rPaulOutput.replace(q_anchor_pos, len, rLocalId);
				q_anchor_pos = rPaulOutput.find(qAnchorTag, q_anchor_pos + newIdSize);
			}
		}
		else if (autoIdLen > newIdSize)
		{
			size_t remove = autoIdLen - newIdSize;
			size_t comp = 0;
			
			if (remove > cd_id_space - 1)
			{
				comp = remove - (cd_id_space - 1);
				remove = cd_id_space - 1;
			}
			
			string compNewId = rLocalId;
			size_t compNewIdSize = newIdSize;
			if (comp > 0)
			{
				compNewId.append(comp, ' ');
				compNewIdSize += comp;
			}
			
			// -- start replace
			while (string::npos != pre_tag_pos)
			{
				// -- ruler space
				size_t ruler_space_pos = rPaulOutput.find(fontTag, pre_tag_pos + preTagSize);
				ruler_space_pos = rPaulOutput.find(endTag, ruler_space_pos + fontTagSize) + 1;
				if (' ' == rPaulOutput[ruler_space_pos]) rPaulOutput.replace(ruler_space_pos, remove, k_strEmptyString);
				
				ruler_space_pos = rPaulOutput.find(fontTag, ruler_space_pos);
				ruler_space_pos = rPaulOutput.find(endTag, ruler_space_pos + fontTagSize) + 1;
				rPaulOutput.replace(ruler_space_pos, remove, k_strEmptyString);
				
				q_anchor_pos = rPaulOutput.find(qAnchorTag, ruler_space_pos);
				size_t q_anchor_size = rPaulOutput.find(anchorEndTag, q_anchor_pos + qAnchorTagSize) + anchorEndTagSize - q_anchor_pos;
				
				rPaulOutput.replace(q_anchor_pos, q_anchor_size, compNewId);
				
				cd_idspace_pos = rPaulOutput.find(anchorEndTag, q_anchor_pos + compNewIdSize) + anchorEndTagSize;
				rPaulOutput.replace(cd_idspace_pos, remove, k_strEmptyString);
				pre_tag_pos = rPaulOutput.find(preTag, cd_idspace_pos);
				
			}
		}
		else	//autoIdLen < newIdSize)
		{
			size_t overwrite = newIdSize - autoIdLen;
			size_t q_id_space = rPaulOutput.find(fontTag, q_anchor_end) - q_anchor_end;	//q_anchor_end == id-space_start
			size_t insert = 0;
			
			if (overwrite > q_id_space - 1)
			{
				insert = overwrite - (q_id_space - 1);
				overwrite = q_id_space - 1;
			}

			while (string::npos != pre_tag_pos)
			{
				// -- ruler space
				size_t ruler_space_pos = rPaulOutput.find(fontTag, pre_tag_pos + preTagSize);
				ruler_space_pos = rPaulOutput.find(endTag, ruler_space_pos + fontTagSize) + 1;
				rPaulOutput.insert(ruler_space_pos, insert, ' ');
				
				ruler_space_pos = rPaulOutput.find(fontTag, ruler_space_pos);
				ruler_space_pos = rPaulOutput.find(endTag, ruler_space_pos + fontTagSize) + 1;
				rPaulOutput.insert(ruler_space_pos, insert, ' ');

				
				q_anchor_pos = rPaulOutput.find(qAnchorTag, ruler_space_pos);


				size_t q_anchor_size = rPaulOutput.find(anchorEndTag, q_anchor_pos + qAnchorTagSize) + anchorEndTagSize - q_anchor_pos;
				q_anchor_size += overwrite;
				rPaulOutput.replace(q_anchor_pos, q_anchor_size, rLocalId);

				
				cd_idspace_pos = rPaulOutput.find(anchorEndTag, q_anchor_pos + newIdSize) + anchorEndTagSize;
				
				rPaulOutput.insert(cd_idspace_pos, insert, ' ');

				pre_tag_pos = rPaulOutput.find(preTag, cd_idspace_pos);
			}
		}
	}
}

void PaulAlignRemoveStatus(string &rPaulOutput)
{
	static const char * const startTag = " onMouseOut=\"window.status=''\"";
	static const char * const endTag = "return true\"";
	static const size_t endTagLen = strlen(endTag);
	
	size_t tagPos = rPaulOutput.find(startTag, 0);
	while (string::npos != tagPos)
	{
		size_t tagEnd = rPaulOutput.find(endTag, tagPos);
		rPaulOutput.erase(tagPos, tagEnd + endTagLen - tagPos);
		tagPos = rPaulOutput.find(startTag, tagPos);
	}
}

CRef<CSeq_id> ObtainAutoMD5SeqIdFromBioseq(const CBioseq &bioseq)
{
	const CBioseq::TId & rBioseqId = bioseq.GetId();
	
	for (CBioseq::TId::const_iterator iter = rBioseqId.begin(); iter != rBioseqId.end(); ++iter)
	{
		if (CSeq_id::e_Local == (*iter)->Which())
		{
			if (IsMD5SeqId((*iter)->GetLocal()))
				return *iter;
		}
	}
	
	return CRef<CSeq_id> (nullptr);
					
}


CRef<CSeq_annot> __CreateTaggedSeqAnnot(const char * const pTag, const char * pVersion)
{
	CRef<CSeq_annot> refResultObj(new CSeq_annot());
	
	// -- description
	CRef<CAnnot_descr> refDescrs(new CAnnot_descr);
	CRef<CAnnotdesc> refOneDesc(new CAnnotdesc);
	if (nullptr == pTag)
		refOneDesc->SetName(k_lpszCdSearchAnnotTag);
	else
		refOneDesc->SetName(pTag);
	refDescrs->Set().push_back(refOneDesc);
	
	if (nullptr != pVersion)
	{
		CRef<CAnnotdesc> refVersionDescr(new CAnnotdesc);
		refVersionDescr->SetUser().SetType().SetStr("CddInfo");
		vector< CRef< CUser_field > > &rUserFields = refVersionDescr->SetUser().SetData();
		
		CRef<CUser_field> refVersion(new CUser_field);
		refVersion->SetLabel().SetStr("version");
		
		const char * pCharCur = pVersion;
		
		while (*pCharCur)
		{
			if (isdigit(*pCharCur))
			{
				refVersion->SetData().SetStr(pCharCur);
				rUserFields.push_back(refVersion);
				refDescrs->Set().push_back(refVersionDescr);
				break;
			}
			++pCharCur;
		}
	}
	
	refOneDesc = new CAnnotdesc;
	CDate *pCurrentDate = new CDate(CTime(CTime::eCurrent));
	refOneDesc->SetCreate_date(*pCurrentDate);
	refDescrs->Set().push_back(refOneDesc);
	
	refResultObj->SetDesc(*refDescrs);
	return refResultObj;
}


void FillDomainFromBioseq(const CBioseq &rConsensus, TDomain &d)
{
	if (rConsensus.IsSetInst() && rConsensus.CanGetInst())
	{
		const CSeq_inst & seqInst = rConsensus.GetInst();
		d.m_strConsensus = Get1LetterSeqData(seqInst);
		
		if (seqInst.IsSetLength() && seqInst.CanGetLength())
			d.m_uiLength = seqInst.GetLength();
		else
			d.m_uiLength = d.m_strConsensus.size();
	}
	
	//m_strFastaDefline = GetFastaDeflineFromBioseq(rConsensus);
	if (d.m_strAccession.empty())d. m_strAccession = GetBestAccFromBioseq(rConsensus);
	size_t colonpos = d.m_strAccession.find(':');
	if (string::npos != colonpos)
		d.m_strAccession.erase(0, colonpos + 1);
	
	const CSeq_id * domId = rConsensus.GetNonLocalId();
	
	if (nullptr != domId && CSeq_id::e_General == domId->Which())
	{
		const CSeq_id::TGeneral& rDbTag = domId->GetGeneral();  //CDbtag
		if (rDbTag.IsSetDb())
			d.m_strSource = rDbTag.GetDb();
		if (d.m_strAccession.empty())
		{
			const CDbtag::TTag& rObjectId = rDbTag.GetTag();  //CObject_id
			if (CDbtag::TTag::e_Str == rObjectId.Which())
				d.m_strAccession = rObjectId.GetStr();
		}
	}
	
	const string& rBioseqTitle = GetDescrTitleFromBioseq(rConsensus);
	if (!rBioseqTitle.empty())
	{
		size_t pos0 = 0, pos1 = rBioseqTitle.find(','), pos2 = string::npos;
			
		if (string::npos != pos1)
			pos2 = rBioseqTitle.find(',', pos1 + 1);
	
		if (string::npos != pos2)	//regular title, has accession and shortname
		{
			while (rBioseqTitle[pos0] <= 0x20) ++pos0;
			
			
			if (d.m_strAccession.empty())
				d.m_strAccession = rBioseqTitle.substr(pos0, pos1);
			
			pos0 = pos1 + 1;
			while (rBioseqTitle[pos0] <= 0x20) ++pos0;
			
			if (d.m_strShortName.empty())
				d.m_strShortName = rBioseqTitle.substr(pos0, pos2 - pos0);
			
			pos0 = pos2 + 1;
			pos1 = rBioseqTitle.size();
			
			while (pos0 < pos1 && rBioseqTitle[pos0] <= 0x20) ++pos0;
			if (d.m_strDefline.empty())
				d.m_strDefline = rBioseqTitle.substr(pos0);
		}
		else
		{
			if (d.m_strDefline.empty())
			{
				d.m_strDefline = rBioseqTitle;
			}
		}
		
		d.m_bIsStructDom = (0 == d.m_strAccession.compare(0, strlen(STRUCTSIG), STRUCTSIG));
		d.m_bCurated = (d.m_bIsStructDom || 0 == d.m_strAccession.compare(0, strlen(CURATEDSIG), CURATEDSIG));
		
	}
}

void FillSegSetFromSeqLoc(const CSeq_loc & rSeqLoc, CSegSet &d)
{
	d.Clear();
	switch (rSeqLoc.Which())
	{
		case CSeq_loc::e_Mix:
		{
			const CSeq_loc_mix::Tdata &locdata = rSeqLoc.GetMix().Get();
			for (CSeq_loc_mix::Tdata::const_iterator iter = locdata.begin(); iter != locdata.end(); ++iter)
			{
				switch ((**iter).Which())
				{
					case CSeq_loc::e_Int:
					{
						const CSeq_interval& rInt = (**iter).GetInt();
						d.AddSeg(rInt.GetFrom(), rInt.GetTo());
					}
					break;
					case CSeq_loc::e_Pnt:
					{
						int res = (**iter).GetPnt().GetPoint();
						d.AddSeg(res, res);
					}
					break;
					default:
					{
						continue;
					}
				}
			}
		}
		break;
		case CSeq_loc::e_Packed_int:
		{
			const CPacked_seqint::Tdata &locdata = rSeqLoc.GetPacked_int().Get();
			for (CPacked_seqint::Tdata::const_iterator iter = locdata.begin(); iter != locdata.end(); ++iter)
			{
				d.AddSeg((*iter)->GetFrom(), (*iter)->GetTo());
			}
		}
		break;
		case CSeq_loc::e_Int:
		{
			const CSeq_interval &locdata = rSeqLoc.GetInt();
			d.AddSeg(locdata.GetFrom(), locdata.GetTo());
		}
		break;
		case CSeq_loc::e_Packed_pnt:
		{
			const CPacked_seqpnt::TPoints & rPoints = rSeqLoc.GetPacked_pnt().GetPoints();
			for (CPacked_seqpnt::TPoints::const_iterator iter = rPoints.begin(); iter != rPoints.end(); ++iter)
			{
				d.AddSeg(*iter, *iter);
			}
		}
		break;
		default:
		{
			;
		}
	}
}


void FillSequenceFromBioseq(const CBioseq &bioseq, TSequence &dst)
{
	if (bioseq.IsSetInst() && bioseq.CanGetInst())
	{
		dst.m_iValid = TSequence::e_Current;	//by default
		const CSeq_inst & seqInst = bioseq.GetInst();
		dst.m_strSeqData = Get1LetterSeqData(seqInst);

		
		if (seqInst.IsSetMol() && seqInst.CanGetMol())
			dst.m_bIsNa = (CSeq_inst::eMol_aa != seqInst.GetMol());
			//dst.m_iMolType = seqInst.GetMol();
		
		if (seqInst.IsSetLength() && seqInst.CanGetLength())
			dst.m_uiSeqLen = seqInst.GetLength();
		else
			dst.m_uiSeqLen = dst.m_strSeqData.size();
	}
	else
	{
		dst.m_iValid = TSequence::e_Invalid;	//by default
		return;
	}
	
	dst.m_strTitle = GetDescrTitleFromBioseq(bioseq);
	if (0 == dst.m_iTaxId) dst.m_iTaxId = bioseq.GetTaxId();
	
	const CBioseq::TId &ids = bioseq.GetId();
	string localId;
	CBioseq::TId::const_iterator iter = ids.begin(), iterEnd = ids.end();
	while (iterEnd != iter)
	{


		switch ((*iter)->Which())
		{
		case CSeq_id::e_Gi:
			if (0 == dst.m_iGi) dst.m_iGi = (*iter)->GetGi();
			break;
		case CSeq_id::e_Local:	//local sequence: reset gi and ncbiid, accession should already been set
			dst.m_iValid = TSequence::e_IsLocal;
			(*iter)->GetLabel(&localId, CSeq_id::eContent);
			break;
			
		default:	//accession
			if (dst.m_strAccession.empty())	//first accession
			{
				(*iter)->GetLabel(&dst.m_strAccession, CSeq_id::eContent);
				
				if (dst.m_Src.empty())
					dst.m_Src = CSeq_id::SelectionName((*iter)->Which());
			}
			break;
		}
		if (!dst.m_strNcbiId.empty()) dst.m_strNcbiId.push_back('|');
		(*iter)->GetLabel(&dst.m_strNcbiId, CSeq_id::eBoth);
		
		++iter;
	}

	//if (TSequence::e_IsLocal == dst.m_iValid)
	PackSeqIds(ids, dst.m_B64PackedIds);

	if (TSequence::e_IsLocal == dst.m_iValid)	//replace accession with label
	{
		// -- check original fasta defline from reader
		dst.m_OriDefline.clear();


		ObtainUserDeflineFromBioseq(bioseq, dst.m_OriDefline);

		if (dst.m_strAccession.empty() && !localId.empty())
			dst.m_strAccession = move(localId);
		//dst.m_iGi = 0;
		//dst.m_strAccession.clear();
	}


}


CRef<CBioseq> CreateBioseqFromSequence(const TSequence &src)
{
	if (src.m_iValid == TSequence::e_Invalid)
		return CRef<CBioseq> (nullptr);
	
	CRef<CBioseq> refBioseq(new CBioseq);
	CSeq_inst &seqInst = refBioseq->SetInst();
	seqInst.SetLength(src.m_uiSeqLen);
	seqInst.SetMol(src.m_bIsNa ? CSeq_inst::eMol_na : CSeq_inst::eMol_aa);
	seqInst.SetRepr(CSeq_inst::eRepr_raw);
	if (!src.m_strSeqData.empty())
	{
		CSeq_data &seqData = seqInst.SetSeq_data();
		if (src.m_bIsNa)
			seqData.SetIupacna() = CIUPACna(src.m_strSeqData);
		else
			seqData.SetNcbieaa() = CNCBIeaa(src.m_strSeqData);
	}
	
	if (!src.m_strTitle.empty())
	{
		CSeq_descr::Tdata& rSeqDescTab = refBioseq->SetDescr().Set();
		CRef<CSeqdesc> refDescr(new CSeqdesc);
		refDescr->SetTitle(src.m_strTitle);
		rSeqDescTab.emplace_back(refDescr);
	}
	
	if (src.m_iTaxId > 0)
	{
		CSeq_descr::Tdata& rSeqDescTab = refBioseq->SetDescr().Set();
		CRef<CSeqdesc> refDescr(new CSeqdesc);
		refDescr->SetOrg().SetTaxId(src.m_iTaxId);
		rSeqDescTab.emplace_back(refDescr);
	}
	
	CBioseq::TId &ids = refBioseq->SetId();
	
	if (!src.m_B64PackedIds.empty())
		UnpackSeqIds(src.m_B64PackedIds, ids);
	else
	{
		if (src.m_iGi > 0)
		{
			CRef<CSeq_id> refGiId(new CSeq_id(CSeq_id::e_Gi, src.m_iGi));
			ids.emplace_front(refGiId);
		}
		
		CRef<CSeq_id> refSeqId(nullptr);
		if (!src.m_strAccession.empty())
		{
			try
			{
				refSeqId = new CSeq_id(src.m_strAccession, CSeq_id::fParse_AnyRaw);
			}
			catch(...)
			{;}
			
			if (!refSeqId.IsNull())
				ids.emplace_back(refSeqId);
		}
		
		if (refSeqId.IsNull() && !src.m_strNcbiId.empty())
		{
			try
			{
				refSeqId = new CSeq_id(src.m_strNcbiId, CSeq_id::fParse_AnyRaw);
			}
			catch(...)
			{;}
			
			if (!refSeqId.IsNull())
				ids.emplace_back(refSeqId);
		}
	}
	
	return refBioseq;
}

void FillPdbIdFromPdbSeqId(const ncbi::objects::CPDB_seq_id &pdbseqid, CPdbId &dst)
{
	if (!pdbseqid.IsSetMol() || !pdbseqid.CanGetMol())
		return;
	
	string mol = pdbseqid.GetMol();
	
	if (pdbseqid.IsSetChain_id() && pdbseqid.CanGetChain_id())
	{
		mol.push_back(CPdbId::DELIM_CHAR);
		mol.append(pdbseqid.GetChain_id());
	}
#if !defined(_STRUCTURE_USE_LONG_PDB_CHAINS_)
	else if (pdbseqid.IsSetChain() && pdbseqid.CanGetChain())
	{
		char c = (char)pdbseqid.GetChain();
		mol.push_back(CPdbId::DELIM_CHAR);
		mol.push_back(c);
		
		dst.ParsePdbAcxn(mol);
	}
#endif
}

CRef<CSeq_id> ConstructPdbSeqId(const CPdbId &src)
{
	CRef<CSeq_id> retval(new CSeq_id);
	CPDB_seq_id & pdbid = retval->SetPdb();
	pdbid.SetMol(CPDB_mol_id(string(src.GetMol())));
#if defined(_STRUCTURE_USE_LONG_PDB_CHAINS_)
	pdbid.SetChain_id_unified((src.GetChainId()));
#else
	pdbid.SetChain(src.GetChain());
#endif
	return retval;
}


void SetSeqLocMixFromSegSet(const CSegSet &sset, const CSeq_id& rUseId, CSeq_loc_mix& container)
{
	CSeq_loc_mix::Tdata& rLocTab = container.Set();
	rLocTab.clear();
	if (sset.IsEmpty()) return;
	
	const CSegSet::TSegs & segs = sset.GetSegs();
	
	CSegSet::TSegs::const_iterator iter = segs.begin();
	CRef<CSeq_loc> refNewLoc(new CSeq_loc);
		
	if (iter->from == iter->to)	//point
	{
		refNewLoc->SetPnt().SetPoint(iter->from);
		refNewLoc->SetPnt().SetId(*SerialClone<CSeq_id>(rUseId));
	}
	else	//interval
	{
		refNewLoc->SetInt().SetFrom(iter->from);
		refNewLoc->SetInt().SetTo(iter->to);
		refNewLoc->SetInt().SetId(*SerialClone<CSeq_id>(rUseId));
	}
	rLocTab.push_back(refNewLoc);  
	
	++iter;
	
	while (iter != segs.end())
	{
		refNewLoc = new CSeq_loc;
		refNewLoc->SetNull();	//add a null
		rLocTab.push_back(refNewLoc);
		refNewLoc = new CSeq_loc;
		if (iter->from == iter->to)	//point
		{
			refNewLoc->SetPnt().SetPoint(iter->from);
			refNewLoc->SetPnt().SetId(*SerialClone<CSeq_id>(rUseId));
		}
		else	//interval
		{
			refNewLoc->SetInt().SetFrom(iter->from);
			refNewLoc->SetInt().SetTo(iter->to);
			refNewLoc->SetInt().SetId(*SerialClone<CSeq_id>(rUseId));
		}
		rLocTab.push_back(refNewLoc);
		
		++iter;
	}
}

