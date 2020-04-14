#if !defined(__LXML__)
#define __LXML__

#include "ustring.hpp"
#include "datanode.hpp"
#include <iostream>
#include <list>
#include <map>
#include <string>
#include <cstring>


namespace LXML
{
	
	// -- all _uc_string_t implementation
	class CGXMLNode;
	typedef CDocNodeRef<CGXMLNode> CGXMLRef;
	typedef std::map<_uc_string_t, _uc_string_t> TProps;
	typedef std::list< CGXMLRef > TChildren;
		
	extern const _uc_string_t US_DEFVER10;
	extern const _uc_string_t US_DTDTYPE;
	extern const _uc_string_t US_DTDLANG;
	
	class CProlog
	{
		friend class CGXMLDoc;
	public:
		_uc_string_t name;	//if empty, default as stypesheet
		std::map<_uc_string_t, _uc_string_t> attribs;
			
		CProlog(void): name(k_ustrEmptyUSTRING), attribs() {};
		void Print(std::ostream &os) const;
		void Print(std::ostream &os, int lvl) const;
		void Reset(void) {name.clear(); attribs.clear();}
	private:
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const;
	};
	

	class CDTDDef
	{
		friend class CGXMLDoc;
	public:
		enum EType
		{
			eElement,
			eAttribute,
			eEntity
		} deftype;
		
		_uc_string_t defname;
		_uc_string_t valtype;
		_uc_string_t value;
		_uc_string_t elem;	//for attribs, element it belongs to
		
		bool empty_fixed_external;	//for element, #EMPTY. for attribs, #FIXED, for entities, external 
		bool required_private;	//for attribs, #REQUIRED, for entities: private DTD
		
		CDTDDef(void):deftype(eElement), defname(k_ustrEmptyUSTRING), valtype(k_ustrEmptyUSTRING), value(k_ustrEmptyUSTRING), elem(k_ustrEmptyUSTRING), empty_fixed_external(false), required_private(false) {};
		void Reset(void) {deftype = eElement; defname.clear(); valtype.clear(); value.clear(); elem.clear(); empty_fixed_external = false; required_private = false;}
		void Print(std::ostream &os) const;
		void Print(std::ostream &os, int lvl) const;
	private:
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const;
	};
	
	class CGXMLDoc
	{
	public:
		// -- BasicUtils/ustring.hpp
		//static const int E_UTF8 = 8;
		//static const int E_UTF16BE = 16;
		//static const int E_UTF16LE = -16;
		CGXMLDoc(CGXMLRef root, int enc = E_UTF8);
		template<typename T>
		CGXMLDoc(CDocNodeRef<T> root, int enc = E_UTF8);
		// -- public data, user fill in for convenience
		_uc_string_t XMLVer;
		
		bool IsISOStd;
		bool IsApproved;
		bool Standalone;	//has external reference, will cause document standalone to be "no"
		
		_uc_string_t DTDOwner;
		_uc_string_t DTDType;
		_uc_string_t DTDDescr;
		_uc_string_t DTDLangId;	//language id
		_uc_string_t DTDVer;
		// -- lack any of the above three will be treated as a private DTD
		_uc_string_t DTDURI;
		
		
		void AddProlog(const CProlog & prlg);
		CProlog & AddProlog(void);
		
		void AddDTDDef(const CDTDDef & def);
		CDTDDef & AddDTDDef(void);
		
		
		void Print(std::ostream &os) const;
		void Print(std::ostream &os, int lvl) const;
			
		
		
	private:
		
		CGXMLRef m_root;
		int m_enc;
		
		// -- external style sheet
		//std::list<_uc_string_t> m_doc
		
		std::list<CProlog> m_prologs;	//external stylesheets
		std::list<CDTDDef> m_dtddefs;	//for internal
		
	};

	template<typename T>
	CGXMLDoc::CGXMLDoc(CDocNodeRef<T> root, int enc):
		XMLVer(US_DEFVER10), IsISOStd(false), IsApproved(false), Standalone(false),
		DTDOwner(k_ustrEmptyUSTRING), DTDType(US_DTDTYPE), DTDDescr(k_ustrEmptyUSTRING), DTDLangId(US_DTDLANG), DTDVer(k_ustrEmptyUSTRING), DTDURI(k_ustrEmptyUSTRING),
		m_root(nullptr), m_enc(E_UTF8), m_prologs(), m_dtddefs()
	{
		T *pT = root.GetPointer();
		if (nullptr != pT)
		{
			CGXMLNode *pX = dynamic_cast< CGXMLNode* > (pT);
			if (nullptr == pX)
				throw CSimpleException(__FILE__, __LINE__, "Incompatiple root node type");
			m_root = pX;
		}
			
		if (E_UTF16LE == enc || E_UTF16BE == enc)
		m_enc = enc;
	}
	
	class CGXMLNode: public CDocNodeBase
	{
		friend class CDocNodeRef<CGXMLNode>;
		friend class CGXMLDoc;
	public:
		//CGXMLNode(const std::string &tag);
		// -- if tag is empty, its a comment node. data will be cdata
		template<typename TTAG, typename... TDATA>
		CGXMLNode(TTAG &&tag, TDATA&& ...data);
		
		//CGXMLNode(const _uc_string_t &tag, const _uc_string_t &data = k_ustrEmptyUSTRING);
		//CGXMLNode(_uc_string_t &&tag, const _uc_string_t &data = k_ustrEmptyUSTRING);
		//CGXMLNode(_uc_string_t &&tag, _uc_string_t &&data);
		//CGXMLNode(const _uc_string_t &tag, _uc_string_t &&data);
/*debug*******************************************************
#if defined(_DEBUG)
		virtual ~CGXMLNode(void)
		{
			std::cerr << __FILE__ << ':' << __LINE__ << ": Node \"" << m_tagname << "\" called!" << std::endl;
		}

#endif
// ***********************************************************/

		
		const _uc_string_t & GetTag(void) const {return m_tagname;}
		
		const _uc_string_t & GetText(void) const {return m_text;}
		_uc_string_t & SetText(void) {return m_text;}
		void SetText(const _uc_string_t & txt);
		void SetText(_uc_string_t && txt);
		
		const _uc_string_t & GetCData(void) const {return m_cdata;}
		_uc_string_t & SetCData(void) {return m_cdata;}
		void SetCData(const _uc_string_t & cdata);
		void SetCData(_uc_string_t && cdata);
		
		const _uc_string_t & GetDefaultNS(void) const {return m_defns;}
		_uc_string_t & SetDefaultNS(void) {return m_defns;}
		void SetDefaultNS(const _uc_string_t & defns);
		void SetDefaultNS(_uc_string_t && defns);
		
		const _uc_string_t & GetAttrib(const _uc_string_t &attr_name) const;
		void SetAttrib(const _uc_string_t &attr_name, const _uc_string_t &attr_value);
		void SetAttrib(const _uc_string_t &attr_name, _uc_string_t &&attr_value);
		
		_uc_string_t & SetAttrib(const _uc_string_t &attr_name);
		void RemoveAttrib(const _uc_string_t &attr_name);
		
		// -- define ns. if prefix is empty, refer to default namespace
		void DefNSPfx(const _uc_string_t &pfx, const _uc_string_t &ns);
		void DefNSPfx(const _uc_string_t &pfx, _uc_string_t &&ns);
		void UndefNSPfx(const _uc_string_t &pfx);
		const _uc_string_t & GetNS(const _uc_string_t &pfx) const;
			
		bool AppendChild(CGXMLRef ch);	//will check to make sure no dup in children
		CGXMLRef AppendChild(const _uc_string_t &tag, const _uc_string_t &data = k_ustrEmptyUSTRING);
		
		CGXMLRef AppendComment(const _uc_string_t &comment);
		//CGXMLRef AppendChild(const std::string &tag);
		bool RemoveChild(CGXMLRef ch);
		void RemoveChildren(const _uc_string_t &tag);
		//void RemoveChildren(const std::string &tag);
		//TChildren FindChild(const std::string &tn) const;	//find child by tag name
		std::vector<CGXMLRef> FindChildren(const _uc_string_t &tag) const;	//find child by tag name
		
		void ClearChildren(void);
		const TChildren &GetChildren(void) const {return m_children;}
		
		// -- template version of children operations for derived classes
		template<typename T>
		bool AppendChild(CDocNodeRef<T> ch);	//will check to make sure no dup in children
		
		template<typename T>
		bool RemoveChild(CDocNodeRef<T> ch);
		
		// -- simple UTF-8 print. for xml pieces
		void Print(std::ostream &os) const;
		void Print(std::ostream &os, int lvl) const;
		
	protected:
		
		_uc_string_t m_tagname;
		_uc_string_t m_defns;	//default name space
		
		_uc_string_t m_text;	//text node. PCDATA
		_uc_string_t m_cdata;	//text for CDATA
		
		
		TProps m_attribs;
		// -- specialized attributes
		TProps m_nspfx;	//namespace prefix
			
		TChildren m_children;
	private:
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl) const;
		
		// -- for derivatives to add extra attributes, such as style
		virtual void x_AssembleExtraAttribs(TProps &exprops) const;
		virtual void x_AssemblePCData(_uc_string_t &pcdata) const;
		virtual void x_AssembleCData(_uc_string_t &cdata) const;
	};
	
	// -- template implementation
	template<typename T>
	bool CGXMLNode::AppendChild(CDocNodeRef<T> ch)
	{
		//CDocNodeRef<CGXMLNode> ref(ch.GetPointer());
		return AppendChild(CDocNodeRef<CGXMLNode> (ch.GetPointer()));
	}
	
	template<typename T>
	bool CGXMLNode::RemoveChild(CDocNodeRef<T> ch)
	{
		//CDocNodeRef<CGXMLNode> ref(ch.GetPointer());
		return RemoveChild(CDocNodeRef<CGXMLNode> (ch.GetPointer()));
	}
	
	template<typename TTAG, typename... TDATA>
	CGXMLNode::CGXMLNode(TTAG &&tag, TDATA&& ...data):
		m_tagname(std::forward<TTAG>(tag)), m_defns(k_ustrEmptyUSTRING), m_text(std::forward<TDATA>(data)...), m_cdata(k_ustrEmptyUSTRING), m_attribs(), m_nspfx(), m_children()
	{}
};





#endif
