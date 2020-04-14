#include <ncbi_pch.hpp>
#include "lxml.hpp"

using namespace std;

namespace LXML
{
	// -- tokens in _uc_string_t
	const _uc_char_t UC_OPENTAG('<');
	const _uc_char_t UC_TAGEND('>');
	const _uc_string_t US_CLOSETAG("</");
	const _uc_string_t US_TAGENDSH(" />");	//short hand tag end
	// -- doc
	const _uc_string_t US_PRLSTART("<?xml");
	const _uc_string_t US_PRLEND("?>");
	const _uc_string_t US_XMLNS("xmlns=");
	const _uc_string_t US_XMLNSPRF("xmlns:");
	const _uc_string_t US_VERSION("version=");
	const _uc_string_t US_ENCODE("encoding=");
	const _uc_string_t US_STANDALONE("standalone=");
	const _uc_string_t US_YES("yes");
	const _uc_string_t US_NO("no");
	const _uc_string_t US_STYLESHEET("-stylesheet");
	const _uc_string_t US_DEFVER10("1.0");
	const _uc_string_t US_ENCUTF8("utf-8");
	const _uc_string_t US_ENCUTF16("utf-16");
	const _uc_string_t US_CDATAOPEN("<![CDATA[");
	const _uc_string_t US_CDATACLOSE("]]>");
	const _uc_string_t US_COMMENTOPEN("<!--");
	const _uc_string_t US_COMMENTCLOSE("-->");
	const _uc_string_t US_DTDOPEN("<!DOCTYPE ");
	const _uc_string_t US_DTDELEM("<!ELEMENT ");
	const _uc_string_t US_DTDATTR("<!ATTLIST ");
	const _uc_string_t US_DTDENTITY("<!ENTITY ");
	const _uc_string_t US_DTDCONTENTEMPTY("#EMPTY");
	const _uc_string_t US_DTDCONTENTANY("#ANY");
	const _uc_string_t US_DTDVALFIXED("#FIXED");
	const _uc_string_t US_DTDVALIMPLIED("#IMPLIED");
	const _uc_string_t US_DTDVALREQUIRED("#REQUIRED");
	
	const _uc_string_t US_DTDPRIVATE("SYSTEM");
	const _uc_string_t US_DTDPUBLIC("PUBLIC");
	const _uc_string_t US_DTDTYPE("DTD");
	const _uc_string_t US_DTDLANG("EN");
	
	
	//const size_t TOTAL_ENTITIES = 5;
	//POD_STATICMAP PREDEF_ENTITIES[TOTAL_ENTITIES] = 
	//{
	//	{UC_OPENTAG, _uc_string_t("&lt;")},
	//	{UC_TAGEND, _uc_string_t("&gt;")},
	//	{UC_AMPS, _uc_string_t("&amp;")},
	//	{UC_QUOT, _uc_string_t("&quot;")},
	//	{UC_APOS, _uc_string_t("&apos;")}
	//};
	// -- predefined escape sequences
	//TEscapeSeqs MAP_ENTITIES;
	
	TEscapeSeqs MAP_ENTITIES =
	{
		{UC_OPENTAG, {UC_AMPS, _uc_char_t('l'), _uc_char_t('t'), UC_SEMICOLON}},
		{UC_TAGEND, {UC_AMPS, _uc_char_t('g'), _uc_char_t('t'), UC_SEMICOLON}},
		{UC_AMPS, {UC_AMPS, _uc_char_t('a'), _uc_char_t('m'), _uc_char_t('p'), UC_SEMICOLON}},
		{UC_QUOT, {UC_AMPS, _uc_char_t('q'), _uc_char_t('u'), _uc_char_t('o'), _uc_char_t('t'), UC_SEMICOLON}},
		{UC_APOS, {UC_AMPS, _uc_char_t('a'), _uc_char_t('p'), _uc_char_t('o'), _uc_char_t('s'), UC_SEMICOLON}}
	};
};

using namespace LXML;

//struct TXMLINIT
//{
//	TXMLINIT(void);
//} x_ini_obj;
//
//TXMLINIT::TXMLINIT(void)
//{
//	CreateEscMap(PREDEF_ENTITIES, TOTAL_ENTITIES, MAP_ENTITIES);
//}

void LXML::CProlog::Print(ostream &os) const
{
	CUTFOstream tok_stream(os, E_UTF8), data_stream(os, E_UTF8, &MAP_ENTITIES);
	x_Print(tok_stream, data_stream);
}

void LXML::CProlog::Print(ostream &os, int lvl) const
{
	CUTFOstream tok_stream(os, E_UTF8), data_stream(os, E_UTF8, &MAP_ENTITIES);
	x_Print(tok_stream, data_stream, lvl);
}

void LXML::CProlog::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	if (!attribs.empty())
	{
		tokenos << US_PRLSTART;
		if (name.empty())
			tokenos << US_STYLESHEET;
		else
		{
			_uc_char_t UC_DASH('-');
			if (UC_DASH != name[0])
				tokenos << UC_DASH;
			tokenos << name;
		}
		
		//tokenos << UC_WHITESP;
		
		for (map<_uc_string_t, _uc_string_t> :: const_iterator iter = attribs.begin(), iterEnd = attribs.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP;
			dataos << iter->first;
			tokenos << UC_EQUAL;
			tokenos << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
		
		tokenos << US_PRLEND;
	}
	else if (!name.empty())	//no attributes, treat as comment, name as the comment content
	{
		tokenos << US_COMMENTOPEN;
		dataos << name;
		tokenos << US_COMMENTCLOSE;
	}
}

void LXML::CProlog::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const
{
	if (lvl > 0)
	{
		_uc_string_t indts(k_ustrEmptyUSTRING);
		indts.insert(indts.end(), lvl, UC_TAB);
		tokenos << indts;
	}
	x_Print(tokenos, dataos);
	tokenos << UC_NL;
}

void LXML::CDTDDef::Print(ostream &os) const
{
	CUTFOstream tok_stream(os, E_UTF8), data_stream(os, E_UTF8, &MAP_ENTITIES);
	x_Print(tok_stream, data_stream);
}

void LXML::CDTDDef::Print(ostream &os, int lvl) const
{
	CUTFOstream tok_stream(os, E_UTF8), data_stream(os, E_UTF8, &MAP_ENTITIES);
	x_Print(tok_stream, data_stream, lvl);
}
void LXML::CDTDDef::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	if (!defname.empty())
	{
		switch (deftype)
		{
		case eElement:
			tokenos << US_DTDELEM;
			dataos << defname;
			tokenos << UC_WHITESP;
			if (empty_fixed_external)
				tokenos << US_DTDCONTENTEMPTY;
			else if (!value.empty())
				tokenos << _uc_char_t('(') << value << _uc_char_t(')');
			else	//not empty, no specific values
				tokenos << US_DTDCONTENTANY;
			tokenos << UC_TAGEND;
			break;
		case eAttribute:
			if (!elem.empty() && !valtype.empty())
			{
				tokenos << US_DTDATTR;
				dataos << defname;
				tokenos << UC_WHITESP;
				dataos << elem;
				tokenos << UC_WHITESP;
				dataos << valtype;
				tokenos << UC_WHITESP;
				
				if (!value.empty())
				{
					if (empty_fixed_external)
						tokenos << US_DTDVALFIXED << UC_WHITESP;
					tokenos << UC_QUOT;
					dataos << value;
					tokenos << UC_QUOT;
					if (required_private)
						tokenos << UC_WHITESP << US_DTDVALREQUIRED;
				}
				else if (required_private)	//no value, ignore m_fixed
					tokenos << US_DTDVALREQUIRED;
				else
					tokenos << US_DTDVALIMPLIED;
				tokenos << UC_TAGEND;
			}
			break;
		case eEntity:
			if (!value.empty())
			{
				tokenos << US_DTDENTITY;
				dataos << defname;
				tokenos << UC_WHITESP;
				
				if (empty_fixed_external)	//m_value is the string
				{	
					if (required_private)
						tokenos << US_DTDPRIVATE;
					else
						tokenos << US_DTDPUBLIC;
						
					tokenos << UC_WHITESP;
				}
				tokenos << UC_QUOT;
				dataos << value;
				tokenos << UC_QUOT;
				
				tokenos << UC_TAGEND;
			}
			break;
		}
	}
	else if (!value.empty())	//no name, treat as comment, value as content
	{
		tokenos << US_COMMENTOPEN;
		dataos << value;
		tokenos << US_COMMENTCLOSE;
	}
		
}

void LXML::CDTDDef::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const
{
	if (lvl > 0)
	{
		_uc_string_t indts(k_ustrEmptyUSTRING);
		indts.insert(indts.end(), lvl, UC_TAB);
		tokenos << indts;
	}
	x_Print(tokenos, dataos);
	tokenos << UC_NL;
}
	
	



LXML::CGXMLDoc::CGXMLDoc(CGXMLRef root, int enc):
	XMLVer(LXML::US_DEFVER10), IsISOStd(false), IsApproved(false), Standalone(false),
	DTDOwner(k_ustrEmptyUSTRING), DTDType(US_DTDTYPE), DTDDescr(k_ustrEmptyUSTRING), DTDLangId(US_DTDLANG), DTDVer(k_ustrEmptyUSTRING), DTDURI(k_ustrEmptyUSTRING),
	m_root(root), m_enc(E_UTF8), m_prologs(), m_dtddefs()
{
	if (E_UTF16LE == enc || E_UTF16BE == enc)
		m_enc = enc;
}

void LXML::CGXMLDoc::AddProlog(const LXML::CProlog & prlg)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": lref: prlg.empty() = " << prlg.empty() << endl;
#endif
// ***********************************************************/

	m_prologs.push_back(prlg);
}

LXML::CProlog &  LXML::CGXMLDoc::AddProlog(void)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": rref: prlg.empty() = " << prlg.empty() << endl;
#endif
// ***********************************************************/

	list<CProlog> ::iterator iter = m_prologs.insert(m_prologs.end(), CProlog());
	return *iter;
}

void LXML::CGXMLDoc::AddDTDDef(const CDTDDef & def)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": lref: prlg.empty() = " << prlg.empty() << endl;
#endif
// ***********************************************************/


	m_dtddefs.push_back(def);
		
}

LXML::CDTDDef & LXML::CGXMLDoc::AddDTDDef(void)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": rref: prlg.empty() = " << prlg.empty() << endl;
#endif
// ***********************************************************/

	list<CDTDDef> ::iterator iter = m_dtddefs.insert(m_dtddefs.end(), CDTDDef());
	return *iter;
}



void LXML::CGXMLDoc::Print(ostream &os) const
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": unformatted print" << endl;
#endif
// ***********************************************************/

	// -- only print if m_root is not null
	if (!m_root.IsNull())
	{
		_uc_string_t _dblslash("//");
		CUTFOstream tok_stream(os, m_enc), data_stream(os, m_enc, &MAP_ENTITIES);
		
		const _uc_string_t *pEnc = &US_ENCUTF8;
		if (E_UTF8 != m_enc)
		{
			tok_stream.PrintBOM();
			pEnc = &US_ENCUTF16;
		}
		tok_stream << US_PRLSTART << UC_WHITESP << US_VERSION << UC_QUOT << XMLVer;
		
		tok_stream << UC_QUOT << UC_WHITESP << US_ENCODE << UC_QUOT << *pEnc << UC_QUOT << UC_WHITESP << US_STANDALONE << UC_QUOT;
		
		
		if (Standalone) tok_stream << US_YES;
		else tok_stream << US_NO;
		
			
		tok_stream << UC_QUOT << US_PRLEND;	//end of first line
		
		// -- now putout dtd
		const _uc_string_t & root_tag = m_root->GetTag();
		
		if (!root_tag.empty())
		{
			if (!DTDURI.empty())	//external
			{
				tok_stream << US_DTDOPEN << root_tag;
				
				if (DTDOwner.empty() || DTDDescr.empty())	//as private
				{
					tok_stream << UC_WHITESP << US_DTDPRIVATE;
				}
				else
				{
					tok_stream << UC_WHITESP << US_DTDPUBLIC << UC_WHITESP << UC_QUOT;
					if (IsISOStd)
						tok_stream << _uc_string_t("ISO");
					else if (IsApproved)
						tok_stream << _uc_char_t('+');
					else
						tok_stream << _uc_char_t('-');
					
					tok_stream << _dblslash << DTDOwner << _dblslash << DTDType << UC_WHITESP << DTDDescr;
					
					if (!DTDLangId.empty())
						tok_stream << _dblslash << DTDLangId;
					if (!DTDVer.empty())
						tok_stream << _dblslash << DTDVer;
						
					tok_stream << UC_QUOT;
				}
				
				tok_stream << UC_WHITESP << UC_QUOT << DTDURI << UC_QUOT;
				
				
				if (m_dtddefs.empty())
				{
					tok_stream << UC_TAGEND;
					goto labelDTDDone;
				}
			}
			else if (!m_dtddefs.empty())
				tok_stream << US_DTDOPEN << root_tag << UC_WHITESP;
			else goto labelDTDDone;
			
			
			tok_stream << UC_WHITESP << _uc_char_t('[') << UC_WHITESP;
			
			for (list<LXML::CDTDDef> :: const_iterator iter = m_dtddefs.begin(), iterEnd = m_dtddefs.end(); iterEnd != iter; ++iter)
			{
				iter->x_Print(tok_stream, data_stream);
				tok_stream << UC_WHITESP;
			}
			
			tok_stream << _uc_char_t(']') << UC_TAGEND;
		}
	labelDTDDone:
//		tok_stream << UC_DTD;
		
		// -- stylesheet
		//<?xml-stylesheet type="text/css" href="cd_catalog.css"?>
		for (list<LXML::CProlog> :: const_iterator iter = m_prologs.begin(); iter != m_prologs.end(); ++iter)
		{
			tok_stream << UC_WHITESP;
			iter->x_Print(tok_stream, data_stream);
		}
			
		m_root->x_Print(tok_stream, data_stream);
	}
}

void LXML::CGXMLDoc::Print(ostream &os, int lvl) const
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Formatted print" << endl;
#endif
// ***********************************************************/

	// -- only print if m_root is not null
	if (!m_root.IsNull())
	{
		_uc_string_t idnts(k_ustrEmptyUSTRING);
		if (lvl > 0) idnts.insert(idnts.end(), lvl, UC_TAB);
		_uc_string_t _dblslash("//");

		CUTFOstream tok_stream(os, m_enc), data_stream(os, m_enc, &MAP_ENTITIES);
		
		const _uc_string_t *pEnc = &US_ENCUTF8;
		if (E_UTF8 != m_enc)
		{
			tok_stream.PrintBOM();
			pEnc = &US_ENCUTF16;
		}
		tok_stream << idnts << US_PRLSTART << UC_WHITESP << US_VERSION << UC_QUOT << XMLVer;
		
		tok_stream << UC_QUOT << UC_WHITESP << US_ENCODE << UC_QUOT << *pEnc << UC_QUOT << UC_WHITESP << US_STANDALONE << UC_QUOT;
		if (Standalone) tok_stream << US_YES;
		else tok_stream << US_NO;
			
		tok_stream << UC_QUOT << US_PRLEND << UC_NL;	//end of first line
		
		// -- now putout dtd
		const _uc_string_t & root_tag = m_root->GetTag();
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": root_tag = " << root_tag << endl;
cerr << __FILE__ << ':' << __LINE__ << ": m_dtddefs.size() = " << m_dtddefs.size() << endl;
#endif
// ***********************************************************/
		
		if (!root_tag.empty())
		{

			if (!DTDURI.empty())	//external
			{
				tok_stream << idnts << US_DTDOPEN << root_tag;
				
				if (DTDOwner.empty() || DTDDescr.empty())	//as private
				{
					tok_stream << UC_WHITESP << US_DTDPRIVATE;
				}
				else
				{
					tok_stream << UC_WHITESP << US_DTDPUBLIC << UC_WHITESP << UC_QUOT;
					if (IsISOStd)
						tok_stream << _uc_string_t("ISO");
					else if (IsApproved)
						tok_stream << _uc_char_t('+');
					else
						tok_stream << _uc_char_t('-');
					
					tok_stream << _dblslash << DTDOwner << _dblslash << DTDType << UC_WHITESP << DTDDescr;
					
					if (!DTDLangId.empty())
						tok_stream << _dblslash << DTDLangId;
					if (!DTDVer.empty())
						tok_stream << _dblslash << DTDVer;
						
					tok_stream << UC_QUOT;
				}
				
				tok_stream << UC_WHITESP << UC_QUOT << DTDURI << UC_QUOT;
				
				
				if (m_dtddefs.empty())
				{
					tok_stream << UC_TAGEND << UC_NL;
					goto labelDTDDone;
				}
			}
			else if (!m_dtddefs.empty())
				tok_stream << US_DTDOPEN << root_tag << UC_WHITESP;
			else goto labelDTDDone;
			
			
			tok_stream << UC_WHITESP << _uc_char_t('[') << UC_NL;
			
			for (list<LXML::CDTDDef> :: const_iterator iter = m_dtddefs.begin(), iterEnd = m_dtddefs.end(); iterEnd != iter; ++iter)
			{
				iter->x_Print(tok_stream, data_stream, lvl + 1);
			}
			
			tok_stream << idnts << _uc_char_t(']') << UC_TAGEND << UC_NL;
		}
	labelDTDDone:
//		tok_stream << UC_DTD;
		
		// -- stylesheet
		//<?xml-stylesheet type="text/css" href="cd_catalog.css"?>
		for (list<LXML::CProlog> :: const_iterator iter = m_prologs.begin(); iter != m_prologs.end(); ++iter)
			iter->x_Print(tok_stream, data_stream, lvl);
			
		m_root->x_Print(tok_stream, data_stream, lvl);
	}
	
}

//LXML::CGXMLNode::CGXMLNode(const _uc_string_t &tag, const _uc_string_t &data):
//	m_tagname(tag), m_defns(k_ustrEmptyUSTRING), m_text(data), m_cdata(k_ustrEmptyUSTRING), m_attribs(), m_nspfx(), m_children()
//{
//	//if (tag.empty())	//treat as comment
//	//{
//	//	m_tagname.clear();
//	//	m_cdata = data;
//	//	m_text.clear();
//	//	return;
//	//}
//		//throw CException(CDiagCompileInfo(__FILE__, __LINE__, "CGXMLNode::CGXMLNode"), nullptr, CException::eUnknown, "Tag name cannot be empty");
//}
//
//LXML::CGXMLNode::CGXMLNode(_uc_string_t &&tag, const _uc_string_t &data):
//	m_tagname(move(tag)), m_defns(k_ustrEmptyUSTRING), m_text(data), m_cdata(k_ustrEmptyUSTRING), m_attribs(), m_nspfx(), m_children()
//{}
//	
//LXML::CGXMLNode::CGXMLNode(_uc_string_t &&tag, _uc_string_t &&data):
//	m_tagname(move(tag)), m_defns(k_ustrEmptyUSTRING), m_text(move(data)), m_cdata(k_ustrEmptyUSTRING), m_attribs(), m_nspfx(), m_children()
//{}
//
//LXML::CGXMLNode::CGXMLNode(const _uc_string_t &tag, _uc_string_t &&data):
//	m_tagname(tag), m_defns(k_ustrEmptyUSTRING), m_text(move(data)), m_cdata(k_ustrEmptyUSTRING), m_attribs(), m_nspfx(), m_children()
//{}




void LXML::CGXMLNode::SetText(const _uc_string_t & txt)
{
	m_text = txt;
}

void LXML::CGXMLNode::SetText(_uc_string_t && txt)
{
	m_text = move(txt);
}

void LXML::CGXMLNode::SetCData(const _uc_string_t & cdata)
{
	m_cdata = cdata;
}

void LXML::CGXMLNode::SetCData(_uc_string_t && cdata)
{
	m_cdata = move(cdata);
}

void LXML::CGXMLNode::SetDefaultNS(const _uc_string_t & defns)
{
	m_defns = defns;
}

void LXML::CGXMLNode::SetDefaultNS(_uc_string_t && defns)
{
	m_defns = move(defns);
}

const _uc_string_t & LXML::CGXMLNode::GetAttrib(const _uc_string_t &attr_name) const
{
	if (!attr_name.empty())
	{
		TProps::const_iterator iter = m_attribs.find(attr_name);
		if (m_attribs.end() != iter)
			return iter->second;
	}
	return k_ustrEmptyUSTRING;
}


void LXML::CGXMLNode::SetAttrib(const _uc_string_t &attr_name, const _uc_string_t &attr_value)
{
	if (attr_name.empty())
		throw CSimpleException(__FILE__, __LINE__, "Attribute name is empty");
	m_attribs[attr_name] = attr_value;
}

void LXML::CGXMLNode::SetAttrib(const _uc_string_t &attr_name, _uc_string_t &&attr_value)
{
	if (attr_name.empty())
		throw CSimpleException(__FILE__, __LINE__, "Attribute name is empty");
	m_attribs[attr_name] = move(attr_value);
}

_uc_string_t & LXML::CGXMLNode::SetAttrib(const _uc_string_t &attr_name)
{
	if (attr_name.empty())
		throw CSimpleException(__FILE__, __LINE__, "Attribute name is empty");
	return m_attribs[attr_name];
}

void LXML::CGXMLNode::RemoveAttrib(const _uc_string_t &attr_name)
{
	if (!attr_name.empty())
	{
		TProps::iterator iter = m_attribs.find(attr_name);
		if (m_attribs.end() != iter)
			m_attribs.erase(iter);
	}
}

void LXML::CGXMLNode::DefNSPfx(const _uc_string_t &pfx, const _uc_string_t &ns)
{
	if (!pfx.empty() && !ns.empty())
		m_nspfx[pfx] = ns;
}

void LXML::CGXMLNode::DefNSPfx(const _uc_string_t &pfx, _uc_string_t &&ns)
{
	if (!pfx.empty() && !ns.empty())
		m_nspfx[pfx] = move(ns);
}

void LXML::CGXMLNode::UndefNSPfx(const _uc_string_t &pfx)
{
	if (!pfx.empty())
	{
		TProps::iterator iter = m_nspfx.find(pfx);
		if (m_nspfx.end() != iter)
			m_nspfx.erase(iter);
	}
}

const _uc_string_t & LXML::CGXMLNode::GetNS(const _uc_string_t &pfx) const
{
	if (!pfx.empty())
	{
		TProps::const_iterator iter = m_nspfx.find(pfx);
		if (m_nspfx.end() != iter)
			return iter->second;
	}
	return k_ustrEmptyUSTRING;
}

bool LXML::CGXMLNode::AppendChild(CGXMLRef ch)
{
	for (TChildren::const_iterator iter = m_children.begin(), iterEnd = m_children.end(); iterEnd != iter; ++iter)
	{
		if ((*iter) == ch)
			return false;
	}
	m_children.push_back(ch);
	return true;
}

CGXMLRef LXML::CGXMLNode::AppendChild(const _uc_string_t &tag, const _uc_string_t &data)
{
	CGXMLRef ch(new CGXMLNode(tag, data));
	m_children.push_back(ch);
	return ch;
}

CGXMLRef LXML::CGXMLNode::AppendComment(const _uc_string_t &comment)
{
	CGXMLRef ch(new CGXMLNode(k_ustrEmptyUSTRING, comment));
	m_children.push_back(ch);
	return ch;
}

bool LXML::CGXMLNode::RemoveChild(CGXMLRef ch)
{
	for (TChildren::iterator iter = m_children.begin(), iterEnd = m_children.end(); iterEnd != iter; ++iter)
	{
		if ((*iter) == ch)
		{
			m_children.erase(iter);
			return false;
		}
	}
	return false;
}


void LXML::CGXMLNode::RemoveChildren(const _uc_string_t &tag)
{
	TChildren::iterator iter = m_children.begin(), iterEnd = m_children.end();
	
	while (iterEnd != iter)
	{
		if (tag == (*iter)->GetTag())
		{
			TChildren::iterator iterErase = iter;
			++iter;
			m_children.erase(iterErase);
		}
		else
			++iter;
	}
}

vector<CGXMLRef> LXML::CGXMLNode::FindChildren(const _uc_string_t &tag) const
{
	vector<CGXMLRef> result;
	for (TChildren::const_iterator iter = m_children.begin(), iterEnd = m_children.end(); iterEnd != iter; ++iter)
		if (tag == (*iter)->GetTag())
			result.push_back(*iter);
	return result;
}

void LXML::CGXMLNode::ClearChildren(void)
{
	m_children.clear();
}

void LXML::CGXMLNode::Print(ostream &os) const
{
	CUTFOstream token_os(os, E_UTF8), data_os(os, E_UTF8, &MAP_ENTITIES);
	x_Print(token_os, data_os);
}

void LXML::CGXMLNode::Print(ostream &os, int lvl) const
{
	CUTFOstream token_os(os, E_UTF8), data_os(os, E_UTF8, &MAP_ENTITIES);
	x_Print(token_os, data_os, lvl);
}


void LXML::CGXMLNode::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{

	int content = 0;
	_uc_string_t cdata(k_ustrEmptyUSTRING);
	if (m_tagname.empty())	//treat as a comment node, only print TEXT
	{
		if (!m_text.empty())
		{
			tokenos << US_COMMENTOPEN;
			tokenos << m_text;
			content = 1;
		}
		
		//x_AssemblePCData(cdata);
		//
		//if (!cdata.empty())
		//{
		//	if (0 == content)
		//	{
		//		tokenos << US_COMMENTOPEN;
		//		content = 1;
		//	}
		//	tokenos << cdata;
		//}
		//
		//if (content > 0)
		//	tokenos << US_COMMENTCLOSE;
		
		
		return;	
		
	}
	
	
	tokenos << UC_OPENTAG;
	dataos << m_tagname;
	
	if (!m_defns.empty())
	{
		tokenos << UC_WHITESP << US_XMLNS << UC_QUOT;
		dataos << m_defns;
		tokenos << UC_QUOT;
	}
	
	if (!m_nspfx.empty())
	{
		for (TProps::const_iterator iter = m_nspfx.begin(), iterEnd = m_nspfx.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP << US_XMLNSPRF;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	if (!m_attribs.empty())
	{
		for (TProps::const_iterator iter = m_attribs.begin(), iterEnd = m_attribs.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	// -- get extra properties from derived classes
	// -- typically style=
	TProps exprops;
	x_AssembleExtraAttribs(exprops);
	
	if (!exprops.empty())
	{
		for (TProps::const_iterator iter = exprops.begin(), iterEnd = exprops.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	
	
	if (!m_children.empty())
	{
		tokenos << UC_TAGEND;	//end tag
		content = 2;
		for (TChildren::const_iterator iter = m_children.begin(), iterEnd = m_children.end(); iterEnd != iter; ++iter)
			(*iter)->x_Print(tokenos, dataos);
	}
	
	if (!m_cdata.empty())
	{
		if (0 == content)	//no children, need end of tag
		{
			tokenos << UC_TAGEND;	//end tag
			//content = 2;
		}
		// -- CDATA should not escape
		tokenos << US_CDATAOPEN << m_cdata;
		content = 3;	//as cdata section
	}
	
	// -- CDATA
	
	x_AssembleCData(cdata);
	
	if (!cdata.empty())
	{
		switch (content)
		{
		case 0:	//no children, no m_cdata
			tokenos << UC_TAGEND;	//end tag
		case 2:
			tokenos << US_CDATAOPEN;
		case 3:
			tokenos << cdata;
		}
		tokenos << US_CDATACLOSE;
		content = 3;
	}
	else if (3 == content)	//close cdata
	{
		tokenos << US_CDATACLOSE;
	}
	
	cdata.clear();
	
	
	if (!m_text.empty())
	{
		if (0 == content)	//means no children printed
		{
			tokenos << UC_TAGEND;	//end tag
			content = 1;
		}
		tokenos << m_text;
	}
	
	// -- extra pcdata
	x_AssemblePCData(cdata);
	
	if (!cdata.empty())	//use this
	{
		switch (content)
		{
		case 0:	//nothing, need end tag
			tokenos << UC_TAGEND;	//end tag
			content = 1;
		default:
			
			tokenos << cdata;
			break;
		}
	}
	if (0 == content)	//empty tag, using shorthand close
		tokenos << US_TAGENDSH;
	else
	{
		tokenos << US_CLOSETAG;
		dataos << m_tagname;
		tokenos << UC_TAGEND;
	}

}

void LXML::CGXMLNode::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const
{
	_uc_string_t idnts(k_ustrEmptyUSTRING);
	if (lvl > 0) idnts.insert(idnts.end(), lvl, UC_TAB);
	int content = 0;
	_uc_string_t cdata(k_ustrEmptyUSTRING);
	if (m_tagname.empty())	//treat as a comment node, only print CDATA
	{
		if (!m_cdata.empty())
		{
			tokenos << idnts << US_COMMENTOPEN << UC_NL;
			tokenos << idnts << UC_TAB << m_cdata << UC_NL;
			content = 1;
		}
		
		x_AssembleCData(cdata);
		
		if (!cdata.empty())
		{
			if (0 == content)
			{
				tokenos << idnts << US_COMMENTOPEN << UC_NL;
				content = 1;
			}
			tokenos << idnts << UC_TAB << cdata << UC_NL;
		}
		
		if (content > 0)
			tokenos << idnts << US_COMMENTCLOSE << UC_NL;
		
		return;	
	}

	tokenos << idnts;
	tokenos << UC_OPENTAG;
	dataos << m_tagname;
	
	if (!m_defns.empty())
	{
		tokenos << UC_WHITESP << US_XMLNS << UC_QUOT;
		dataos << m_defns;
		tokenos << UC_QUOT;
	}
	
	if (!m_nspfx.empty())
	{
		for (TProps::const_iterator iter = m_nspfx.begin(), iterEnd = m_nspfx.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP << US_XMLNSPRF;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	if (!m_attribs.empty())
	{
		for (TProps::const_iterator iter = m_attribs.begin(), iterEnd = m_attribs.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	// -- get extra properties from derived classes
	// -- typically style=
	TProps exprops;
	x_AssembleExtraAttribs(exprops);
	
	if (!exprops.empty())
	{
		for (TProps::const_iterator iter = exprops.begin(), iterEnd = exprops.end(); iterEnd != iter; ++iter)
		{
			tokenos << UC_WHITESP;
			dataos << iter->first;
			tokenos << UC_EQUAL << UC_QUOT;
			dataos << iter->second;
			tokenos << UC_QUOT;
		}
	}
	
	// -- children first
	

	if (!m_children.empty())
	{
		tokenos << UC_TAGEND << UC_NL;	//end tag
		content = 2;	//has children
		for (TChildren::const_iterator iter = m_children.begin(), iterEnd = m_children.end(); iterEnd != iter; ++iter)
		{
			(*iter)->x_Print(tokenos, dataos, lvl + 1);
			tokenos << UC_NL;
		}
	}
	
	if (!m_cdata.empty())
	{
		if (0 == content)	//no children, need end of tag
		{
			tokenos << UC_TAGEND << UC_NL;	//end tag
			//content = 2;
		}
		// -- CDATA should not escape
		tokenos << idnts << UC_TAB << US_CDATAOPEN << UC_NL << idnts << UC_TAB << UC_TAB << m_cdata << UC_NL;
		content = 3;	//as cdata section
	}
	
	// -- CDATA
	x_AssembleCData(cdata);
	
	if (!cdata.empty())
	{
		switch (content)
		{
		case 0:	//no children, no m_cdata
			tokenos << UC_TAGEND << UC_NL;	//end tag
		case 2:
			tokenos << idnts << UC_TAB << US_CDATAOPEN << UC_NL;
		case 3:
			tokenos << idnts << UC_TAB << UC_TAB << cdata << UC_NL;
		}
		tokenos << idnts << UC_TAB << US_CDATACLOSE << UC_NL;
		content = 3;
	}
	else if (3 == content)	//close cdata
	{
		tokenos << idnts << UC_TAB << US_CDATACLOSE << UC_NL;
	}
	
	cdata.clear();
	
	if (!m_text.empty())
	{
		if (0 == content)	//means no children printed. Print texxt and close tag in one line
		{
			tokenos << UC_TAGEND;	//end tag
			tokenos << m_text;
			content = 1;
		}
		else	// not empty, already have a newline
		{
			tokenos << idnts << UC_TAB;	//end tag
			tokenos << m_text;
			tokenos << UC_NL;
		}
	}
	
	
	x_AssemblePCData(cdata);
	
	if (!cdata.empty())	//use this
	{
		switch (content)
		{
		case 0:	//nothing, need end tag
			tokenos << UC_TAGEND;	//end tag
		case 1:	//has text, just follow it and treat as inline	
			dataos << cdata;
			content = 1;
			break;
		default:
			tokenos << idnts << UC_TAB;
			dataos << cdata;
			tokenos << UC_NL;
			break;
		}
	}
	
	switch (content)
	{
	case 0:
		tokenos << US_TAGENDSH;
		break;
	case 1:	//inline close
		tokenos << US_CLOSETAG;
		dataos << m_tagname;
		tokenos << UC_TAGEND;
		break;
	default:	//has newline
		tokenos << idnts << US_CLOSETAG;
		dataos << m_tagname;
		tokenos << UC_TAGEND;
		
	}
	
}

void LXML::CGXMLNode::x_AssembleExtraAttribs(TProps &exprops) const
{}
void LXML::CGXMLNode::x_AssemblePCData(_uc_string_t &exprops) const
{}
void LXML::CGXMLNode::x_AssembleCData(_uc_string_t &exprops) const
{}
