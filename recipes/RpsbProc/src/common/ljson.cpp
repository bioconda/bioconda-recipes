#include <ncbi_pch.hpp>
#include "ljson.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <cstring>
#include <stack>
#include <sstream>
#include <cmath>
#include <limits>
#include <cctype>




//#include <memory.h>
using namespace std;

namespace LJSON
{
	// -- tokens in _uc_string_t
	static const _uc_char_t UC_OBJSTART('{');
	static const _uc_char_t UC_OBJEND('}');
	static const _uc_char_t UC_ARRAYSTART('[');
	static const _uc_char_t UC_ARRAYEND(']');
	static const _uc_char_t UC_JSONPSTART('(');
	static const _uc_string_t US_JSONPEND(")");
	static const _uc_char_t UC_QUOT('"');
	static const _uc_char_t UC_APOS('\'');
	static const _uc_char_t UC_BKSLASH('\\');
	static const _uc_char_t UC_SLASH('/');
	static const _uc_char_t UC_WHITESP(' ');
	static const _uc_char_t UC_COLON(':');
	static const _uc_char_t UC_TAB('\t');
	static const _uc_char_t UC_NEWLINE('\n');
	static const _uc_char_t UC_COMMA(',');
	
	
	static const _uc_string_t US_JSUNDEF("undefined");
	static const _uc_string_t US_JSNULL("null");
	static const _uc_string_t US_JSFALSE("false");
	static const _uc_string_t US_JSTRUE("true");
	static const _uc_string_t US_COMMA(",");
	
	// -- number
	static const _uc_char_t UC_PLUS('+');
	static const _uc_char_t UC_MINUS('-');
	static const _uc_char_t UC_UEXP('E');
	static const _uc_char_t UC_LEXP('e');
	static const _uc_char_t UC_DOT('.');
	static const _uc_char_t UC_UNICODE('u');
	// -- escape
	
	
	
	//static const size_t TOTAL_ENTITIES = 35;
	//POD_STATICMAP PREDEF_ENTITIES[TOTAL_ENTITIES] = 
	TEscapeSeqs MAP_ENTITIES =
	{
		{UC_BKSLASH, {UC_ESCAPE, UC_BKSLASH}},
		{UC_QUOT, {UC_ESCAPE, UC_QUOT}},
		{UC_SLASH, {UC_ESCAPE, UC_SLASH}},
		{0x00, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0')}},
		{0x01, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1')}},
		{0x02, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('2')}},
		{0x03, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('3')}},
		{0x04, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('4')}},
		{0x05, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('5')}},
		{0x06, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('6')}},
		{0x07, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('7')}},
		{0x08, {UC_ESCAPE, _uc_char_t('b')}},
		{0x09, {UC_ESCAPE, _uc_char_t('t')}},
		{0x0a, {UC_ESCAPE, _uc_char_t('n')}},
		{0x0b, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('b')}},
		{0x0c, {UC_ESCAPE, _uc_char_t('f')}},
		{0x0d, {UC_ESCAPE, _uc_char_t('r')}},
		{0x0e, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('e')}},
		{0x0f, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('f')}},
		{0x10, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('0')}},
		{0x11, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('1')}},
		{0x12, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('2')}},
		{0x13, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('3')}},
		{0x14, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('4')}},
		{0x15, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('5')}},
		{0x16, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('6')}},
		{0x17, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('7')}},
		{0x18, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('8')}},
		{0x19, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('9')}},
		{0x1a, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('a')}},
		{0x1b, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('b')}},
		{0x1c, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('c')}},
		{0x1d, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('d')}},
		{0x1e, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('e')}},
		{0x1f, {UC_ESCAPE, _uc_char_t('u'), _uc_char_t('0'), _uc_char_t('0'), _uc_char_t('1'), _uc_char_t('f')}}
	};
	
	//TEscapeSeqs MAP_ENTITIES =
	//{
	//	{UC_BKSLASH, _uc_string_t("\\\\")},
	//	{UC_QUOT, _uc_string_t("\\\"")},
	//	{_uc_char_t('/'), _uc_string_t("\\/")},
	//	// -- control chars are always escaped
	//	{(_uc_char_t)0x00, _uc_string_t("\\u0000")},
	//	{(_uc_char_t)0x01, _uc_string_t("\\u0001")},
	//	{(_uc_char_t)0x02, _uc_string_t("\\u0002")},
	//	{(_uc_char_t)0x03, _uc_string_t("\\u0003")},
	//	{(_uc_char_t)0x04, _uc_string_t("\\u0004")},
	//	{(_uc_char_t)0x05, _uc_string_t("\\u0005")},
	//	{(_uc_char_t)0x06, _uc_string_t("\\u0006")},
	//	{(_uc_char_t)0x07, _uc_string_t("\\u0007")},
	//	//
	//	{(_uc_char_t)0x08, _uc_string_t("\\b")},
	//	//{(_uc_char_t)0x09, _uc_string_t("\\u0009")},
	//	{(_uc_char_t)0x09, _uc_string_t("\\t")},
	//	//{(_uc_char_t)0x0a, _uc_string_t("\\u000a")},
	//	{(_uc_char_t)0x0a, _uc_string_t("\\n")},
	//	{(_uc_char_t)0x0b, _uc_string_t("\\u000b")},
	//	//{(_uc_char_t)0x0c, _uc_string_t("\\u000c")},
	//	{(_uc_char_t)0x0c, _uc_string_t("\\f")},
	//	//{(_uc_char_t)0x0d, _uc_string_t("\\u000d")},
	//	{(_uc_char_t)0x0d, _uc_string_t("\\r")},
	//	{(_uc_char_t)0x0e, _uc_string_t("\\u000e")},
	//	{(_uc_char_t)0x0f, _uc_string_t("\\u000f")},
	//	{(_uc_char_t)0x10, _uc_string_t("\\u0010")},
	//	{(_uc_char_t)0x11, _uc_string_t("\\u0011")},
	//	{(_uc_char_t)0x12, _uc_string_t("\\u0012")},
	//	{(_uc_char_t)0x13, _uc_string_t("\\u0013")},
	//	{(_uc_char_t)0x14, _uc_string_t("\\u0014")},
	//	{(_uc_char_t)0x15, _uc_string_t("\\u0015")},
	//	{(_uc_char_t)0x16, _uc_string_t("\\u0016")},
	//	{(_uc_char_t)0x17, _uc_string_t("\\u0017")},
	//	{(_uc_char_t)0x18, _uc_string_t("\\u0018")},
	//	{(_uc_char_t)0x19, _uc_string_t("\\u0019")},
	//	{(_uc_char_t)0x1a, _uc_string_t("\\u001a")},
	//	{(_uc_char_t)0x1b, _uc_string_t("\\u001b")},
	//	{(_uc_char_t)0x1c, _uc_string_t("\\u001c")},
	//	{(_uc_char_t)0x1d, _uc_string_t("\\u001d")},
	//	{(_uc_char_t)0x1e, _uc_string_t("\\u001e")},
	//	{(_uc_char_t)0x1f, _uc_string_t("\\u001f")}
	//};
	// -- predefined escape sequences
	//TEscapeSeqs MAP_ENTITIES;
	
	const char * errMsgs[eEndOfErrors] =
	{
		"",
		"Undefined variable",
		"Operation unsupported by this type of value",
		"Input stream broken, incomplete data",
		"Parse error: Invalid JSON data",
		"Index beyond array boundary",
		"Property not found",
		"Unknown error"
	};
	
	class CJSNullObj: public JSValue
	{
	public:
		virtual EDataType ValueType(void) const {return eNull;}

	private:
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
	};
	
	class CJSBoolObj: public JSValue
	{
	public:
		typedef JSBoolValue TValueType;
		virtual EDataType ValueType(void) const {return eBoolean;}
		
		CJSBoolObj(TValueType val = false): JSValue(), m_val(val)
		{};
		
		const TValueType &GetValue(void) const {return m_val;}
		TValueType & SetValue(void) {return m_val;}
		
	private:
		
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};
	
	class CJSIntObj: public JSValue
	{
	public:
		typedef JSIntValue TValueType;
		virtual EDataType ValueType(void) const {return eInteger;}
		
		const TValueType &GetValue(void) const {return m_val;}
		
		TValueType & SetValue(void) {return m_val;}
		
		CJSIntObj(TValueType val = 0L): JSValue(), m_val(val) {};
		
		void * operator new (size_t sz);
		void operator delete (void *ptr);
		
	private:
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};
	
	class CJSRealObj: public JSValue
	{
	public:
		typedef JSRealValue TValueType;
		virtual EDataType ValueType(void) const {return eReal;}
		
		CJSRealObj(TValueType val = 0.0L): JSValue(), m_val(val) {};
			
		const TValueType &GetValue(void) const {return m_val;}
		TValueType & SetValue(void) {return m_val;}
		
		void * operator new (size_t sz);
		void operator delete (void *ptr);
		
	private:
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};
	
	class CJSStringObj: public JSValue
	{
	public:
		typedef JSStringValue TValueType;
		virtual EDataType ValueType(void) const {return eString;}
		
		CJSStringObj(const TValueType &val = k_ustrEmptyUSTRING): JSValue(), m_val(val) {};
		const TValueType &GetValue(void) const {return m_val;}
		TValueType & SetValue(void) {return m_val;}
	private:
		
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};
	
	class CJSArrayObj: public JSValue
	{
	public:
		typedef JSArrayValue TValueType;
		virtual EDataType ValueType(void) const {return eArray;}
		
		CJSArrayObj(void): JSValue(), m_val() {};
		CJSArrayObj(const TValueType &val): JSValue(), m_val(val) {};
		
		const TValueType &GetValue(void) const {return m_val;}
		TValueType & SetValue(void) {return m_val;}
	private:
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};
	
	class CJSObjectObj: public JSValue
	{
	public:
		typedef JSObjectValue TValueType;
		virtual EDataType ValueType(void) const {return eObject;}
		
		CJSObjectObj(void): JSValue(), m_val()
		{};
		CJSObjectObj(const TValueType &val): JSValue(), m_val(val)
		{};
		
		const TValueType &GetValue(void) const {return m_val;}
		TValueType & SetValue(void) {return m_val;}
	private:
		
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		TValueType m_val;
	};



	// -- array only, otherwise throw
	template <>
	const LJSON::JSVar & LJSON::JSVar::operator [] (size_t i) const
	{
		if (!IsNull())
		{
			const CJSArrayObj * p = dynamic_cast< const CJSArrayObj * > (GetPointer());
			if (nullptr != p)
			{
				const JSArrayValue &array = p->GetValue();
				size_t ttl = array.size();
				if (i < ttl)
					return array[i];
				throw JSONExcept(eOutOfArrayBoundary, errMsgs[eOutOfArrayBoundary], i);
			}
		}
		throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eUndefined);
	}
	
	template <>
	const LJSON::JSVar & LJSON::JSVar::operator [] (int i) const
	{
		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	const LJSON::JSVar & LJSON::JSVar::operator [] (unsigned int i) const
	{
		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	const LJSON::JSVar & LJSON::JSVar::operator [] (long i) const
	{
		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	LJSON::JSVar & LJSON::JSVar::operator [] (size_t i)
	{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": template<size_t>" << endl;
#endif
// ***********************************************************/

		if (!IsNull())
		{
			CJSArrayObj * p = dynamic_cast< CJSArrayObj * > (GetPointer());
			if (nullptr != p)
			{
				JSArrayValue &array = p->SetValue();
				size_t ttl = array.size();
				
				if (i >= ttl)
					array.insert(array.end(), i - ttl + 1, JSVar());
				return array[i];
			}
		}
		throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eUndefined);
	}
	
	template <>
	LJSON::JSVar & LJSON::JSVar::operator [] (int i)
	{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": template<int>" << endl;
#endif
// ***********************************************************/

		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	LJSON::JSVar & LJSON::JSVar::operator [] (unsigned int i)
	{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": template<unsigned>" << endl;
#endif
// ***********************************************************/

		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	LJSON::JSVar & LJSON::JSVar::operator [] (long int i)
	{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": template<long>" << endl;
#endif
// ***********************************************************/
		return this->LJSON::JSVar::operator [] ((size_t)i);
	}
	
	template <>
	LJSON::JSVar & LJSON::JSVar::operator [] (const char * key)
	{
		_uc_string_t t(key);
		return this->LJSON::JSVar::operator [] (t);
	}

	// -- read ustring lit from CUTFIstream, translate escape sequence as well
	// -- return how many uchars read, including the last UC_QUOT
	//size_t ReadUSTRINGLit(CUTFIstream &is, USTRING_base &dst, _uc_char_t endToken);
	size_t ReadUSTRINGLit(CUTFIstream &is, _uc_string_t &dst, _uc_char_t endToken);
	JSVar ParseNumberLit(const _uc_string_t &buf);
	
	// -- static 
	
	
	JSVar null(new CJSNullObj);
	JSVar jsTrue(new CJSBoolObj(true));
	JSVar jsFalse(new CJSBoolObj(false));
	
};

using namespace LJSON;

//struct TJSONINIT
//{
//	TJSONINIT(void);
//} x_init_obj;
//
//TJSONINIT::TJSONINIT(void)
//{
//	CreateEscMap(PREDEF_ENTITIES, TOTAL_ENTITIES, MAP_ENTITIES);
//}

static CMemPool<sizeof(LJSON::CJSIntObj), 256> __int_pool;
//static std::mutex  __int_pool_mutex;
void * LJSON::CJSIntObj::operator new (size_t sz)
{
	//std::lock_guard<std::mutex> lk(__int_pool_mutex);
	return __int_pool._Op_New_Data();
}

void LJSON::CJSIntObj::operator delete (void *ptr)
{
	//std::lock_guard<std::mutex> lk(__int_pool_mutex);
	__int_pool._Op_Delete_Data(ptr);
}


static CMemPool<sizeof(LJSON::CJSRealObj), 256> __real_pool;
//static std::mutex  __real_pool_mutex;
void * LJSON::CJSRealObj::operator new (size_t sz)
{	
	//std::lock_guard<std::mutex> lk(__real_pool_mutex);
	return __real_pool._Op_New_Data();
}

void LJSON::CJSRealObj::operator delete (void *ptr)
{
	//std::lock_guard<std::mutex> lk(__real_pool_mutex);
	__real_pool._Op_Delete_Data(ptr);
}


static CMemPool<sizeof(LJSON::JSVar), 1024> __var_pool;
//static std::mutex  __var_pool_mutex;
void * LJSON::JSVar::operator new (size_t sz)
{	
	//std::lock_guard<std::mutex> lk(__var_pool_mutex);
	return __var_pool._Op_New_Data();
}

void LJSON::JSVar::operator delete (void *ptr)
{
	//std::lock_guard<std::mutex> lk(__var_pool_mutex);
	__var_pool._Op_Delete_Data(ptr);
}



// -- JSONDoc
LJSON::JSONDoc::JSONDoc(JSVar root, const _uc_string_t &jsonp, int enc):
	m_root(root), m_jsonp(jsonp), m_enc(enc)
{}

void LJSON::JSONDoc::Print(ostream &os) const
{
	CUTFOstream tokenos(os, m_enc), dataos(os, m_enc, &MAP_ENTITIES);
	if (E_UTF8 != m_enc) tokenos.PrintBOM();
	if (!m_jsonp.empty())
	{
		tokenos << m_jsonp << UC_JSONPSTART;
		m_root.Print(tokenos, dataos);
		tokenos << US_JSONPEND;
	}
	else
		m_root.Print(tokenos, dataos);
}

void LJSON::JSONDoc::Print(ostream &os, int lvl) const
{
	_uc_string_t ind(k_ustrEmptyUSTRING);
	ind.append(lvl, UC_TAB);
	
	CUTFOstream tokenos(os, m_enc), dataos(os, m_enc, &MAP_ENTITIES);
	if (E_UTF8 != m_enc) tokenos.PrintBOM();
	
	if (!m_jsonp.empty())
	{
		tokenos << ind << m_jsonp << UC_JSONPSTART << UC_NEWLINE;
		m_root.Print(tokenos, dataos, lvl + 1);
		tokenos << ind << US_JSONPEND;
	}
	else
		m_root.Print(tokenos, dataos, lvl);
}

LJSON::JSVar::JSVar(JSValue *val):
	TParent (val)
{}

LJSON::JSVar::JSVar (EDataType t):
	TParent ()
{
	switch (t)
	{
	default:
		break;
	case eNull:
		
		this->TParent::operator = (LJSON::null);
		break;
	case eBoolean:
		this->TParent::operator = (jsFalse);
		break;
	case eInteger:
		this->TParent::operator = (new CJSIntObj);
		break;
	case eReal:
		this->TParent::operator = (new CJSRealObj);
		break;
	case eString:
		this->TParent::operator = (new CJSStringObj);
		break;
	case eArray:
		this->TParent::operator = (new CJSArrayObj);
		break;
	case eObject:
		this->TParent::operator = (new CJSObjectObj);
		break;
	}
}


LJSON::JSVar::JSVar(const JSVar &src):
	TParent (src)
{}

LJSON::JSVar::JSVar (JSBoolValue val):
	TParent ()
{
	this->TParent::operator = ( val ? jsTrue : jsFalse);
}

LJSON::JSVar::JSVar(const JSIntValue & val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(long val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(unsigned long val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(int val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(unsigned int val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(short val):
	TParent (new CJSIntObj((JSIntValue)val))
{}

LJSON::JSVar::JSVar(unsigned short val):
	TParent (new CJSIntObj((JSIntValue)val))
{}


LJSON::JSVar::JSVar(const JSRealValue & val):
	TParent (new CJSRealObj(val))
{}

LJSON::JSVar::JSVar(double val):
	TParent (new CJSRealObj((JSRealValue)val))
{}

LJSON::JSVar::JSVar (const JSStringValue & val):
	TParent (new CJSStringObj(val))
{}

LJSON::JSVar::JSVar (const std::string & utf8):
	TParent (new CJSStringObj (_uc_string_t(utf8)))
{}


LJSON::JSVar::JSVar (const char * utf8):
	TParent (new CJSStringObj (_uc_string_t(utf8)))
{}

LJSON::JSVar::JSVar(const JSArrayValue & val):
	TParent (new CJSArrayObj(val))
{}

LJSON::JSVar::JSVar(const JSObjectValue & val):
	TParent (new CJSObjectObj(val))
{}






//const JSVar & LJSON::JSVar::operator = (const JSVar &src)
//{
//	TParent::operator = (src);
//	return *this;
//}

JSBoolValue LJSON::JSVar::GetBoolValue(void) const
{
	if (!IsNull())
	{
		const CJSBoolObj * p = dynamic_cast< const CJSBoolObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eBoolean);
}

const JSIntValue & LJSON::JSVar::GetIntValue(void) const
{
	if (!IsNull())
	{
		const CJSIntObj * p = dynamic_cast< const CJSIntObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eInteger);
}

const JSRealValue & LJSON::JSVar::GetRealValue(void) const
{
	if (!IsNull())
	{
		const CJSRealObj * p = dynamic_cast< const CJSRealObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eReal);
}

const JSStringValue & LJSON::JSVar::GetStringValue(void) const
{
	if (!IsNull())
	{
		const CJSStringObj * p = dynamic_cast< const CJSStringObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eString);
}

const JSArrayValue & LJSON::JSVar::GetArrayValue(void) const
{
	if (!IsNull())
	{
		const CJSArrayObj * p = dynamic_cast< const CJSArrayObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eArray);
}

const JSObjectValue & LJSON::JSVar::GetObjectValue(void) const
{
	if (!IsNull())
	{
		const CJSObjectObj * p = dynamic_cast< const CJSObjectObj * > (GetPointer());
		if (nullptr != p)
			return p->GetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eObject);
}


//JSBoolValue & LJSON::JSVar::SetBoolValue(void)
//{
//	if (!IsNull())
//	{
//		CJSBoolObj * p = dynamic_cast< CJSBoolObj * > (m_nodeptr);
//		if (nullptr != p)
//			return p->SetValue();
//	}
//	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eBoolean);
//}

JSIntValue & LJSON::JSVar::SetIntValue(void)
{
	if (!IsNull())
	{
		CJSIntObj * p = dynamic_cast< CJSIntObj * > (GetPointer());
		if (nullptr != p)
			return p->SetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eInteger);
}

JSRealValue & LJSON::JSVar::SetRealValue(void)
{
	if (!IsNull())
	{
		CJSRealObj * p = dynamic_cast< CJSRealObj * > (GetPointer());
		if (nullptr != p)
			return p->SetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eReal);
}

JSStringValue & LJSON::JSVar::SetStringValue(void)
{
	if (!IsNull())
	{
		CJSStringObj * p = dynamic_cast< CJSStringObj * > (GetPointer());
		if (nullptr != p)
			return p->SetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eString);
}

JSArrayValue & LJSON::JSVar::SetArrayValue(void)
{
	if (!IsNull())
	{
		CJSArrayObj * p = dynamic_cast< CJSArrayObj * > (GetPointer());
		if (nullptr != p)
			return p->SetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eArray);
}

JSObjectValue & LJSON::JSVar::SetObjectValue(void)
{
	if (!IsNull())
	{
		CJSObjectObj * p = dynamic_cast< CJSObjectObj * > (GetPointer());
		if (nullptr != p)
			return p->SetValue();
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eObject);
}


//void LJSON::JSVar::SetBoolValue(JSBoolValue val)
//{
//	if (!IsNull())
//	{
//		CJSBoolObj * p = dynamic_cast< CJSBoolObj * > (m_nodeptr);
//		if (nullptr != p)
//		{
//			p->SetValue() = val;
//			return;
//		}
//	}
//	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eBoolean);
//}

void LJSON::JSVar::SetIntValue(const JSIntValue & val)
{
	if (!IsNull())
	{
		CJSIntObj * p = dynamic_cast< CJSIntObj * > (GetPointer());
		if (nullptr != p)
		{
			p->SetValue() = val;
			return;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eInteger);
}

void LJSON::JSVar::SetRealValue(const JSRealValue & val)
{
	if (!IsNull())
	{
		CJSRealObj * p = dynamic_cast< CJSRealObj * > (GetPointer());
		if (nullptr != p)
		{
			p->SetValue() = val;
			return;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eReal);
}

void LJSON::JSVar::SetStringValue(const JSStringValue & val)
{
	if (!IsNull())
	{
		CJSStringObj * p = dynamic_cast< CJSStringObj * > (GetPointer());
		if (nullptr != p)
		{
			p->SetValue() = val;
			return;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eString);
}

void LJSON::JSVar::SetArrayValue(const JSArrayValue & val)
{
	if (!IsNull())
	{
		CJSArrayObj * p = dynamic_cast< CJSArrayObj * > (GetPointer());
		if (nullptr != p)
		{
			p->SetValue() = val;
			return;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eArray);
}

void LJSON::JSVar::SetObjectValue(const JSObjectValue & val)
{
	if (!IsNull())
	{
		CJSObjectObj * p = dynamic_cast< CJSObjectObj * > (GetPointer());
		if (nullptr != p)
		{
			p->SetValue() = val;
			return;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eObject);
}

void LJSON::JSVar::Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	if (IsNull())
		tokenos << US_JSNULL;
	else
		GetPointer()->x_Print(tokenos, dataos);
}

void LJSON::JSVar::Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	if (IsNull())
	{
		switch (p_type)
		{
		case eObject:
			tokenos << UC_WHITESP;
		default:
			tokenos << US_JSNULL;
			break;
		case eArray:	//	array member
			{
				_uc_string_t ind(k_ustrEmptyUSTRING);
				ind.append(lvl, UC_TAB);
				tokenos << UC_NEWLINE << ind << US_JSNULL;
			}
			break;
		}
	}
	else
		GetPointer()->x_Print(tokenos, dataos, lvl, p_type);
}

EDataType LJSON::JSVar::ValueType(void) const
{
	if (IsNull()) return eUndefined;
	return GetPointer()->ValueType();
}


size_t LJSON::JSVar::length(void) const
{
	EDataType dt = eUndefined;
	if (!IsNull())
	{
		dt = GetPointer()->ValueType();
		
		switch (dt)
		{
		case eArray:
			{
				const CJSArrayObj * pValObj = dynamic_cast< const CJSArrayObj* > (GetPointer());
				if (nullptr != pValObj)
				{
					return pValObj->GetValue().size();
				}
			}
			break;
		case eObject:
			{
				const CJSObjectObj * pValObj = dynamic_cast< const CJSObjectObj* > (GetPointer());
				if (nullptr != pValObj)
				{
					return pValObj->GetValue().size();
				}
			}
			break;
		default:;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], dt);
}

LJSON::JSVar & LJSON::JSVar::push(const LJSON::JSVar &src)
{
	if (!IsNull())
	{
		CJSArrayObj * p = dynamic_cast< CJSArrayObj * > (GetPointer());
		if (nullptr != p)
		{
			JSArrayValue &array = p->SetValue();
			array.push_back(src);
			return array.back();
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eUndefined);
}


// -- object only. 
const LJSON::JSVar & LJSON::JSVar::operator [] (const _uc_string_t & key) const
{
	if (!IsNull() || key.empty())
	{
		const CJSObjectObj * p = dynamic_cast< const CJSObjectObj * > (GetPointer());
		if (nullptr != p)
		{
			const JSObjectValue &obj = p->GetValue();
			JSObjectValue::const_iterator iter = obj.find(key);
			if (obj.end() != iter)	//found
				return iter->second;
			throw JSONExcept(ePropNameNotFound, std::string(errMsgs[ePropNameNotFound]) + " -- " + (std::string)key);
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eUndefined);
}

const LJSON::JSVar & LJSON::JSVar::operator [] (const string & key) const
{
	_uc_string_t t(key);
	return this-> LJSON::JSVar::operator [] (t);
}

const LJSON::JSVar & LJSON::JSVar::operator [] (const char * key) const
{
	_uc_string_t t(key);
	return this-> LJSON::JSVar::operator [] (t);
}

const LJSON::JSVar & LJSON::JSVar::operator [] (char * key) const
{
	return this-> LJSON::JSVar::operator [] ((const char*)key);
}
	
	

LJSON::JSVar & LJSON::JSVar::operator [] (const _uc_string_t & key)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": key = " << key << ", m_nodeptr = " << (void*)m_nodeptr << endl;
#endif
// ***********************************************************/

	if (!IsNull() || key.empty())
	{
		CJSObjectObj * p = dynamic_cast< CJSObjectObj * > (GetPointer());
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": p = " << (void*)p << endl;
#endif
// ***********************************************************/

		if (nullptr != p)
		{
			JSObjectValue &obj = p->SetValue();
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": obj.size() = " << obj.size() << endl;
#endif
// ***********************************************************/

			JSObjectValue::iterator iter = obj.find(key);
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": obj.end() == iter is " << (obj.end() == iter) << endl;
#endif
// ***********************************************************/

			if (obj.end() == iter)	//not found
			{
				pair<JSObjectValue::iterator, bool> insertResult = obj.insert(std::pair<_uc_string_t, JSVar> (key, JSVar()));
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": insertResult.second = " << insertResult.second << ", obj.size() = " << obj.size() << endl;
#endif
// ***********************************************************/

				iter = insertResult.first;
			}
			return iter->second;
		}
	}
	throw JSONExcept(eUnsupportedOperation, errMsgs[eUnsupportedOperation], eUndefined);
}

LJSON::JSVar & LJSON::JSVar::operator [] (const string & key)
{
	_uc_string_t t(key);
	return this-> LJSON::JSVar::operator [] (t);
}

LJSON::JSVar & LJSON::JSVar::operator [] (const char * key)
{

	_uc_string_t t(key);
	return this-> LJSON::JSVar::operator [] (t);
}


LJSON::JSVar & LJSON::JSVar::operator [] (char * key)
{
	return this-> LJSON::JSVar::operator [] ((const char*)key);
}


// -- implements of actual value object methods

void LJSON::CJSNullObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	tokenos << US_JSNULL;
}

void LJSON::CJSNullObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	switch (p_type)
	{
	case eObject:
		tokenos << UC_WHITESP;
	default:
		x_Print(tokenos, dataos);
		break;
	case eArray:	//	array member
		{
			_uc_string_t ind(k_ustrEmptyUSTRING);
			ind.append(lvl, UC_TAB);
			tokenos << UC_NEWLINE << ind;
			x_Print(tokenos, dataos);
		}
		break;
	}
}

void LJSON::CJSBoolObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	tokenos << (m_val ? US_JSTRUE : US_JSFALSE);
}

void LJSON::CJSBoolObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	switch (p_type)
	{
	case eObject:
		tokenos << UC_WHITESP;
	default:
		x_Print(tokenos, dataos);
		break;
	case eArray:	//	array member
		{
			_uc_string_t ind(k_ustrEmptyUSTRING);
			ind.append(lvl, UC_TAB);
			tokenos << UC_NEWLINE << ind;
			x_Print(tokenos, dataos);
		}
		break;
	}
}


void LJSON::CJSIntObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	char dimBuf[3 * sizeof(TValueType)];
	sprintf(dimBuf, "%lld", m_val);
	tokenos << _uc_string_t(dimBuf);
}

void LJSON::CJSIntObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	switch (p_type)
	{
	case eObject:
		tokenos << UC_WHITESP;
	default:
		x_Print(tokenos, dataos);
		break;
	case eArray:	//	array member
		{
			_uc_string_t ind(k_ustrEmptyUSTRING);
			ind.append(lvl, UC_TAB);
			tokenos << UC_NEWLINE << ind;
			x_Print(tokenos, dataos);
		}
		break;
	}
}

void LJSON::CJSRealObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	char dimBuf[128];
	sprintf(dimBuf, "%.10Lg", m_val);
	tokenos << _uc_string_t(dimBuf);
}

void LJSON::CJSRealObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	switch (p_type)
	{
	case eObject:
		tokenos << UC_WHITESP;
	default:
		x_Print(tokenos, dataos);
		break;
	case eArray:	//	array member
		{
			_uc_string_t ind(k_ustrEmptyUSTRING);
			ind.append(lvl, UC_TAB);
			tokenos << UC_NEWLINE << ind;
			x_Print(tokenos, dataos);
		}
		break;
	}
}

void LJSON::CJSStringObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	tokenos << UC_QUOT;
	dataos << m_val;
	tokenos << UC_QUOT;
}

void LJSON::CJSStringObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	switch (p_type)
	{
	case eObject:
	tokenos << UC_WHITESP;
	default:
		x_Print(tokenos, dataos);
		break;
	case eArray:	//	array member
		{
			_uc_string_t ind(k_ustrEmptyUSTRING);
			ind.append(lvl, UC_TAB);
			tokenos << UC_NEWLINE << ind;
			x_Print(tokenos, dataos);
		}
		break;
	}
}

void LJSON::CJSArrayObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
	const _uc_string_t *dimSep = &k_ustrEmptyUSTRING;
	tokenos << UC_ARRAYSTART;
	
	for (TValueType :: const_iterator iter = m_val.begin(), iterEnd = m_val.end(); iterEnd != iter; ++iter)
	{
		tokenos << *dimSep;
		iter->Print(tokenos, dataos);
		dimSep = &US_COMMA;
	}
	tokenos << UC_ARRAYEND;
}

void LJSON::CJSArrayObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	_uc_string_t ind(k_ustrEmptyUSTRING);
	ind.append(lvl, UC_TAB);
	
	if (m_val.empty())
	{
		switch (p_type)
		{
		case eObject:
			tokenos << UC_WHITESP;
		default:
			tokenos << UC_ARRAYSTART << UC_ARRAYEND;
			break;
		case eArray:
			tokenos << UC_NEWLINE << ind << UC_ARRAYSTART << UC_ARRAYEND;
			break;
		}
	}
	else
	{
		const _uc_string_t *dimSep = &k_ustrEmptyUSTRING;
		tokenos << UC_NEWLINE << ind << UC_ARRAYSTART;
		for (TValueType :: const_iterator iter = m_val.begin(), iterEnd = m_val.end(); iterEnd != iter; ++iter)
		{
			tokenos << *dimSep;
			iter->Print(tokenos, dataos, lvl + 1, eArray);
			dimSep = &US_COMMA;
		}
		tokenos << UC_NEWLINE << ind << UC_ARRAYEND;
	}
}


void LJSON::CJSObjectObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering void LJSON::CJSObjectObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const, m_val.size() = " << m_val.size() << endl;
#endif
// ***********************************************************/

	const _uc_string_t *dimSep = &k_ustrEmptyUSTRING;
	tokenos << UC_OBJSTART;
	
	for (TValueType :: const_iterator iter = m_val.begin(), iterEnd = m_val.end(); iterEnd != iter; ++iter)
	{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": iter->first = " << iter->first << endl;
#endif
// ***********************************************************/

		tokenos << *dimSep << UC_QUOT;
		dataos << iter->first;	//key
		tokenos << UC_QUOT << UC_COLON;
		iter->second.Print(tokenos, dataos);
		
		dimSep = &US_COMMA;
	}
	tokenos << UC_OBJEND;
}

void LJSON::CJSObjectObj::x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type) const
{
	_uc_string_t ind(k_ustrEmptyUSTRING);
	ind.append(lvl, UC_TAB);
	
	if (m_val.empty())
	{
		switch (p_type)
		{
		case eObject:
			tokenos << UC_WHITESP;
		default:
			tokenos << UC_OBJSTART << UC_OBJEND;
			break;
		case eArray:
			tokenos << UC_NEWLINE << ind << UC_OBJSTART << UC_OBJEND;
			break;
		}
	}
	else
	{
		const _uc_string_t *dimSep = &k_ustrEmptyUSTRING;
		tokenos << UC_NEWLINE << ind << UC_OBJSTART;
		for (TValueType :: const_iterator iter = m_val.begin(), iterEnd = m_val.end(); iterEnd != iter; ++iter)
		{
			tokenos << *dimSep << UC_NEWLINE << ind << UC_TAB << UC_QUOT;
			dataos << iter->first;
			tokenos << UC_QUOT << UC_COLON << UC_WHITESP;
			
			iter->second.Print(tokenos, dataos, lvl + 1, eObject);
			dimSep = &US_COMMA;
		}
		tokenos << UC_NEWLINE << ind << UC_OBJEND;
	}
}

// -- will not clear dst, just append
// -- endToken should be '"' or '\''
//size_t LJSON::ReadUSTRINGLit(CUTFIstream &is, USTRING_base &dst, _uc_char_t endToken)
size_t LJSON::ReadUSTRINGLit(CUTFIstream &is, _uc_string_t &dst, _uc_char_t endToken)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering ReadUSTRINGLit, endToken = " << (char)endToken << endl;
#endif
// ***********************************************************/

	static const size_t UNICHARS = 5;
	size_t uc_count = 0;
	_uc_char_t uc = 0;
	
	bool bInEscape = false;
	size_t UniIdx = UNICHARS;
	char dimUniBuf[UNICHARS + 1] = {0, 0, 0, 0, 0};
	
	
	while(is.ReadUC(uc))
	{
		++uc_count;
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": UCAHR read = " << uc_count << ", current uc = ";
if (uc >= 0x20 && uc <= 127) cerr << (char)uc;
else cerr << hex << uc << dec;
cerr << endl;
#endif
// ***********************************************************/

		switch (uc)
		{
		case UC_BKSLASH:	//backslash, escape sequence
			if (bInEscape)
			{
				if (UniIdx >= UNICHARS)	//not in unicode
				{
					dst.push_back(uc);
					bInEscape = false;
				}
				else	//in partial unicode, treat as invalid unicode sequence and push everything as individual chars
				{
					dst.push_back(UC_UNICODE);
					for (size_t i = 0; i < UniIdx; ++i)
						dst.push_back(dimUniBuf[i]);
					UniIdx = UNICHARS;	//turn unicode off
					// -- suppose the previous \u has been treated as u, bInEscape should be off, then this \\ will turn it back on, so keep bInEscape as true
				}
			}
			else
				bInEscape = true;
			break;
		case UC_UNICODE:	//u
			if (bInEscape)
			{
				if (UniIdx >= UNICHARS)	//not in unicode)
					UniIdx = 0;	//turn on unicode 
				else	//in unicode mode, u is an invalid char. So invalidate the unicode sequence and treat all chars as normal chars
				{
					dst.push_back(UC_UNICODE);
					for (size_t i = 0; i < UniIdx; ++i)
						dst.push_back(dimUniBuf[i]);
					UniIdx = UNICHARS;	//turn unicode off
					dst.push_back(UC_UNICODE);
					bInEscape = false;
					// -- suppose the previous \u has been treated as u, bInEscape should be off, then this \\ will turn it back on, so keep bInEscape as true
				}
			}
			else
				dst.push_back(uc);	//normal char
			break;
		//case endToken:	//" or ', end of string
		//	if (bInEscape)
		//	{
		//		if (UniIdx < UNICHARS)	//in unicode, invalidate it
		//		{
		//			dst.push_back(UC_UNICODE);
		//			for (size_t i = 0; i < UniIdx; ++i)
		//				dst.push_back(dimUniBuf[i]);
		//			// -- done here
		//			goto labelDone; 
		//		}
		//		else	//normal char
		//		{
		//			dst.push_back(uc);	//normal char
		//			bInEscape = false;
		//		}
		//	}
		//	else
		//		goto labelDone;
		//	break;
		
		default:
			if (bInEscape)
			{
				if (UniIdx < UNICHARS)	//unicode, only accept hex digits
				{
					if ((uc >= '0' && uc <= '9') || (uc >= 'a' && uc <= 'f') || (uc >= 'A' && uc <= 'F'))	//valid
					{
						dimUniBuf[UniIdx++] = (char)uc;
						if (UniIdx == UNICHARS)	//sequence complete
						{
							uc = 0;
							sscanf(dimUniBuf, "%4x", &uc);
							dst.push_back(uc);
							bInEscape = false;
						}
					}
					else	//invalid unicode char
					{
						dst.push_back(UC_UNICODE);
						for (size_t i = 0; i < UniIdx; ++i)
							dst.push_back(dimUniBuf[i]);
						UniIdx = UNICHARS;	//turn unicode off
						
						if (uc == endToken)	//end
							goto labelDone;
						dst.push_back(uc);
						bInEscape = false;
					}
				}
				else	//not in unicode
				{
					switch (uc)
					{
					case 'b':	//backspace
						dst.push_back(0x8);
						break;
					case 'f':	//formfead
						dst.push_back(0xc);
						break;
					case 'n':	//newline
						dst.push_back(UC_NEWLINE);
						break;
					case 'r':	//Carriage return
						dst.push_back(0xd);
						break;
					case 't':	//tab
						dst.push_back(UC_TAB);
						break;
					default:
						dst.push_back(uc);
						break;
					}
					
					bInEscape = false;
				}
			}
			else	//end
			{
				if (uc == endToken)
					goto labelDone;
				dst.push_back(uc);
			}
		}
	}
	
	// -- unexpected end of stream
	throw JSONExcept(eStreamBroken, errMsgs[eStreamBroken], uc_count);
	
labelDone:	
	return uc_count;
}

JSVar LJSON::ParseNumberLit(const _uc_string_t &lit)
{
	size_t len = lit.size(), idx = 0, signpos = string::npos, dotpos = string::npos, epos = string::npos, esignpos = string::npos;
	bool hasValue = false, hasNZValue = false, hasExp = false, hasNZExp = false;
	
	string strBuf;
	strBuf.reserve(len);
	
	stringstream ss;
	_uc_char_t uc = 0;
	while (idx < len)
	{
		uc = lit[idx];
		switch (uc)
		{
		case UC_MINUS:
		case UC_PLUS:
			if (0 == idx)
				signpos = 0;
			else if (epos == idx - 1)	//only valid position
				esignpos = idx;
			else
			{
				ss << "Sign only valid at the beginning of numbers";
				goto labelMalformat;
			}
			break;
		case UC_UEXP:
		case UC_LEXP:
			//if (string::npos == epos && hasMantissa && dotpos != idx - 1)
			//	epos = idx;
			if (string::npos != epos)
			{
				ss << "Extra exponent token";
				goto labelMalformat;
			}
			else if (!hasValue)
			{
				ss << "Exponent token without mantissa part";
				goto labelMalformat;
			}
			else if (dotpos == idx - 1)
			{
				ss << "Exponent token with incomplete mantissa part";
				goto labelMalformat;
			}
			else
				epos = idx;
			break;
		case UC_DOT:
			if (string::npos != epos)
			{
				ss << "Exponent part must be an integer";
				goto labelMalformat;
			}
			else if (string::npos != dotpos)
			{
				ss << "Extra decimal point";
				goto labelMalformat;
			}
			else
				dotpos = idx;
			
			break;
		case 0x30:	//'0', leading zero problem
			if (string::npos != epos)	//exponent part
			{
				if (hasExp && !hasNZExp)
				{
					ss << "Excessive leading zero in exponent part";
					goto labelMalformat;
				}
				hasExp = true;
			}
			else if (string::npos != dotpos)	//value part, has dot
			{
				hasValue = true;
			}
			else if (!hasValue)
				hasValue = true;
			else if (!hasNZValue)
			{
				ss << "Excessive leading zero";
				goto labelMalformat;
			}

			break;
				
		default:
			if (uc >= 0x31L && uc <= 0x39L)	//1 - 9
			{
				if (string::npos == epos)
				{
					hasNZValue = true;
					hasValue = true;
				}
				else
				{
					hasExp = true;
					hasNZExp = true;
				}
			}
			else
			{
				ss << "Invalid character U+" << hex << uc << dec << " in number literal";
				goto labelMalformat;
			}
			break;
		}
		strBuf.push_back((char)uc);
		++idx;
	}
	
	if (!hasValue)
	{
		ss << "Invalid number literal";
		goto labelMalformat;
	}
	else if (string::npos != epos && !hasExp)
	{
		ss << "Missing exponent part";
		goto labelMalformat;
	}
	else if (string::npos == dotpos && string::npos == epos)	//integer
	{
		JSIntValue val = 0;
		sscanf(strBuf.c_str(), "%lld", &val);
		return JSVar(val);
	}
	else
	{
		JSRealValue val = 0;
		sscanf(strBuf.c_str(), "%Lg", &val);
		return JSVar(val);
	}
	
	// -- should not happen
	return JSVar();
labelMalformat:
	throw JSONExcept(eJSONDataError, ss.str() + " - " + strBuf, uc);	
}

istream & LJSON::operator >> (istream &is, LJSON::JSVar &dst)
{
	
	enum EStatus
	{
		eValueStart,	//must start a value, can't be value-ending tokens
		eValue,	//reading a value. can accept value-ending tokens
		eValueEnd,	//must read a value-ending token. 
		eNameStart,	//must start a property name (of object).Wait for the " token to start a name string
		eNameEnd	//property name ended (after receiving the closing ". must wait for ':' token.
	} eStatus = eValueStart;
	
	stringstream ss;	//for message
	
	stack<JSVar> stkContainers;	//parent container for current values
	
	_uc_string_t name(k_ustrEmptyUSTRING), buf(k_ustrEmptyUSTRING);
	
	_uc_char_t uc = 0;
	size_t c_counter = 0;
	
	is >> noskipws;
	CUTFIstream srcstrm(is);
	
	while (srcstrm.ReadUC(uc))
	{
		++c_counter;
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": c =' " << c << "', buf = \"" << buf << "\", eStatus = " << eStatus << ", buf = " << buf << ", c_counter = " << c_counter << endl;
#endif
// ***********************************************************/
		
		switch (eStatus)
		{
		case eValueStart:
			if (uc <= 0x20) continue;

			switch (uc)
			{
			case UC_OBJSTART:	//start of 
				{
					JSVar newVal(eObject);
					if (!stkContainers.empty())	//has parent
					{
						JSVar p = stkContainers.top();
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
					}
					stkContainers.push(newVal);
					eStatus = eNameStart;	//waiting for name
				}
				break;
			case UC_ARRAYSTART:	//start of array
				{
					JSVar newVal(eArray);
					if (!stkContainers.empty())	//has parent
					{
						JSVar p = stkContainers.top();
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
					}
					stkContainers.push(newVal);
					eStatus = eValue;	//waiting for name
				}
				break;
			case UC_QUOT:	//start of string
			case UC_APOS:	//start of string
				{
					JSVar newVal(eString);
					try
					{
						c_counter += ReadUSTRINGLit(srcstrm, newVal.SetStringValue(), uc);
					}
					catch (JSONExcept e)
					{
						c_counter += e.GetParam();
						size_t bytes = srcstrm.GetCurrIstreamPos();
						ss << __FILE__ << ':' << __LINE__ << ": " << e.what() << " at position " << bytes << ", " << c_counter << " unicode characters read";
						
						//throw JSONExcept(e.ValueType(), ss.str(), bytes);
						goto labelJSONError;
					}
					catch (...)
					{
						size_t bytes = srcstrm.GetCurrIstreamPos();
						ss << __FILE__ << ':' << __LINE__ << ": Unspecified streaming error at position " << bytes;
						//throw JSONExcept(eUnknownError, ss.str(), bytes);
						goto labelJSONError;
					}
					
					if (!stkContainers.empty())	//has parent
					{
						JSVar p = stkContainers.top();
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
						eStatus = eValueEnd;	
					}
					else	//we are done here
					{
						dst = newVal;
						goto labelDone;	//done
					}
					//waiting for name
				}
				break;
			case UC_DOT:
			case UC_PLUS:
			case UC_MINUS:
				buf.push_back(uc);
				eStatus = eValue;
				break;
			default:
				if (('0' <= uc && '9' >= uc) || ('a' <= uc && 'z' >= uc) || ('A' <= uc && 'Z' >= uc))	//is alpha num
				{
					buf.push_back(uc);
					eStatus = eValue;
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Invalid unicode character U+" << hex << uc << dec << " at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				break;
			}
			break;
		case eValue:
			switch (uc)
			{
			case UC_QUOT:	//start of string
			case UC_APOS:	//start of string
				if (buf.empty())	//no other value literal collected yet
				{
					JSVar newVal(eString);
					try
					{
						c_counter += ReadUSTRINGLit(srcstrm, newVal.SetStringValue(), uc);
					}
					catch (JSONExcept e)
					{
						c_counter += e.GetParam();
						size_t bytes = srcstrm.GetCurrIstreamPos();
						ss << e.what() << " at position " << bytes << ", " << c_counter << " unicode characters read";
						
						//throw JSONExcept(e.ValueType(), ss.str(), bytes);
						goto labelJSONError;
					}
					catch (...)
					{
						size_t bytes = srcstrm.GetCurrIstreamPos();
						ss << __FILE__ << ':' << __LINE__ << ": Unspecified streaming error at position " << bytes;
						//throw JSONExcept(eUnknownError, ss.str(), bytes);
						goto labelJSONError;
					}
					
					if (!stkContainers.empty())	//has parent
					{
						JSVar p = stkContainers.top();
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
						eStatus = eValueEnd;	
					}
					else	//should not happen
					{
						dst = newVal;
						goto labelDone;	//done
					}
					//waiting for name
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Invalid token U+" << hex << uc << dec << " at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				break;
			// -- value end token
			case UC_COMMA:
				if (buf.empty() || stkContainers.empty())
				{
					ss << __FILE__ << ':' << __LINE__ << ": Invalid token U+" << hex << uc << dec << " at position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
					goto labelJSONError;
				}
				else
				{
					JSVar val;
					if (US_JSNULL == buf)
						val = eNull;
					else if (US_JSTRUE == buf)
						val = true;
					else if (US_JSFALSE == buf)
						val = false;
					else
					{
						try
						{
							val = ParseNumberLit(buf);
						}
						catch (JSONExcept e)
						{
							ss << __FILE__ << ':' << __LINE__ << ": " << e.what();
							
							//throw JSONExcept(e.ValueType(), ss.str(), bytes);
							goto labelJSONError;
						}
						catch (...)
						{
							ss << __FILE__ << ':' << __LINE__ << ": " << "Unknown number parsing error";
							//throw JSONExcept(eUnknownError, ss.str(), bytes);
							goto labelJSONError;
						}
					
						if (eUndefined == val.ValueType())
						{
							ss << __FILE__ << ':' << __LINE__ << ": Invalid value literal at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
							goto labelJSONError;
						}
					}
					
					JSVar p = stkContainers.top();
					if (eArray == p.ValueType())
					{
						p.push(val);
						eStatus = eValueStart;
					}
					else
					{
						p[name] = val;
						name.clear();
						eStatus = eNameStart;
					}
				}
				buf.clear();
				//eStatus = eValueStart;
				break;
			case UC_ARRAYEND:
				if (!stkContainers.empty())
				{
					JSVar p = stkContainers.top();
					if (eArray == p.ValueType())
					{
						if (!buf.empty())
						{
							JSVar val;
							if (US_JSNULL == buf)
								val = eNull;
							else if (US_JSTRUE == buf)
								val = true;
							else if (US_JSFALSE == buf)
								val = false;
							else
							{
								try
								{
									val = ParseNumberLit(buf);
								}
								catch (JSONExcept e)
								{
									ss << __FILE__ << ':' << __LINE__ << ": " << e.what();
									
									//throw JSONExcept(e.ValueType(), ss.str(), bytes);
									goto labelJSONError;
								}
								catch (...)
								{
									ss << __FILE__ << ':' << __LINE__ << ": Unknown number parsing error";
									//throw JSONExcept(eUnknownError, ss.str(), bytes);
									goto labelJSONError;
								}
							
								if (eUndefined == val.ValueType())
								{
									ss << __FILE__ << ':' << __LINE__ << ": Invalid value literal at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
									goto labelJSONError;
								}
							}
					
							p.push(val);
							buf.clear();
						}
						
						stkContainers.pop();
						if (stkContainers.empty())
						{
							dst = p;	//done
							goto labelDone;
						}
						
					}
					else
					{
						ss << __FILE__ << ':' << __LINE__ << ": Array closing token detected, but object closing token is expected";
						goto labelJSONError;
					}
						
				}
				else	//should not happen
				{
					ss << __FILE__ << ':' << __LINE__ << ": Extra array closing token";
					goto labelJSONError;
				}
				
				eStatus = eValueEnd;
					
				break;
			case UC_OBJEND:	//'}'
				if (!stkContainers.empty())
				{
					JSVar p = stkContainers.top();
					if (eObject == p.ValueType())
					{
						if (!buf.empty())
						{
							JSVar val;
							if (US_JSNULL == buf)
								val = eNull;
							else if (US_JSTRUE == buf)
								val = true;
							else if (US_JSFALSE == buf)
								val = false;
							else
							{
								try
								{
									val = ParseNumberLit(buf);
								}
								catch (JSONExcept e)
								{
									ss << __FILE__ << ':' << __LINE__ << ": " << e.what();
									
									//throw JSONExcept(e.ValueType(), ss.str(), bytes);
									goto labelJSONError;
								}
								catch (...)
								{
									ss << __FILE__ << ':' << __LINE__ << ": Unknown number parsing error";
									//throw JSONExcept(eUnknownError, ss.str(), bytes);
									goto labelJSONError;
								}
							
								if (eUndefined == val.ValueType())
								{
									ss << __FILE__ << ':' << __LINE__ << ": Invalid value literal at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
									goto labelJSONError;
								}
							}
							
							p[name] = val;
							buf.clear();
							name.clear();
						}
						
						stkContainers.pop();
						if (stkContainers.empty())
						{
							dst = p;	//done
							goto labelDone;
						}
					}
					else
					{
						ss << __FILE__ << ':' << __LINE__ << ": Object closing token detected, but array closing token is expected";
						goto labelJSONError;
					}
						
				}
				else	//should not happen
				{
					ss << __FILE__ << ':' << __LINE__ << ": Extra object closing token";
					goto labelJSONError;
				}
				eStatus = eValueEnd;
				break;
			case UC_OBJSTART:	//only allow when buf is empty
				if (buf.empty())
				{
					JSVar newVal(eObject);
					if (!stkContainers.empty())
					{
						JSVar p = stkContainers.top();
						
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
					}
					stkContainers.push(newVal);
					eStatus = eNameStart;
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Unexpected token U+" << hex << uc << dec << " found at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				break;
			case UC_ARRAYSTART:	//only allow when buf is empty
				if (buf.empty())
				{
					JSVar newVal(eArray);
					if (!stkContainers.empty())
					{
						JSVar p = stkContainers.top();
						
						if (eArray == p.ValueType())
							p.push(newVal);
						else
						{
							p[name] = newVal;
							name.clear();
						}
					}
					stkContainers.push(newVal);
					//eStatus = eValue;	// -- unchanged
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Unexpected token U+" << hex << uc << dec << " found at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				break;
			// -- continue to collecting value literal. 
			case UC_DOT:
			case UC_PLUS:
			case UC_MINUS:
				buf.push_back(uc);
				break;
			
			default:
				if ((uc >= '0' && uc <= '9') || (uc >= 'a' && uc <= 'z') || (uc >= 'A' && uc <= 'Z'))
					buf.push_back(uc);
				else if (uc <= 0x20L)
				{
					if (buf.empty())
						continue;
					else	//treat space as a value stop token
					{
						JSVar val;
						if (US_JSNULL == buf)
							val = eNull;
						else if (US_JSTRUE == buf)
							val = true;
						else if (US_JSFALSE == buf)
							val = false;
						else
						{
							try
							{
								val = ParseNumberLit(buf);
							}
							catch (JSONExcept e)
							{
								ss << __FILE__ << ':' << __LINE__ << ": " << e.what();
								
								//throw JSONExcept(e.ValueType(), ss.str(), bytes);
								goto labelJSONError;
							}
							catch (...)
							{
								ss << __FILE__ << ':' << __LINE__ << ": Unknown number parsing error";
								//throw JSONExcept(eUnknownError, ss.str(), bytes);
								goto labelJSONError;
							}
						
							if (eUndefined == val.ValueType())
							{
								ss << __FILE__ << ':' << __LINE__ << ": Invalid value literal at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
								goto labelJSONError;
							}
						}
						
						if (stkContainers.empty())
						{
							dst = val;	//all done
							goto labelDone;
						}
						else
						{
							JSVar p = stkContainers.top();
							if (eArray == p.ValueType())
								p.push(val);
							else
							{
								p[name] = val;
								name.clear();
							}
						}
						buf.clear();
						eStatus = eValueEnd;
					}
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Invalid character U+" << hex << uc << dec << " at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				break;
			}
			break;
		case eValueEnd:
			if (uc <= 0x20L) continue;
			switch (uc)
			{
			case UC_ARRAYEND:
				if (!stkContainers.empty())
				{
					JSVar p = stkContainers.top();
					if (eArray != p.ValueType())
					{
						ss << __FILE__ << ':' << __LINE__ << ": Array closing token detected, but object closing token is expected";
						goto labelJSONError;
					}
					stkContainers.pop();
					if (stkContainers.empty())
					{
						dst = p;	//done
						goto labelDone;
					}
				}
				else	//should not happen
				{
					ss << __FILE__ << ':' << __LINE__ << ": Extra array closing token";
					goto labelJSONError;
				}
				break;
			case UC_OBJEND:
				if (!stkContainers.empty())
				{
					JSVar p = stkContainers.top();
					if (eObject != p.ValueType())
					{
						ss << __FILE__ << ':' << __LINE__ << ": Object closing token detected, but array closing token is expected";
						goto labelJSONError;
					}
					stkContainers.pop();
					if (stkContainers.empty())
					{
						dst = p;	//done
						goto labelDone;
					}
				}
				else	//should not happen
				{
					ss << __FILE__ << ':' << __LINE__ << ": Extra array closing token";
					goto labelJSONError;
				}
				break;
			case UC_COMMA:
				if (!stkContainers.empty())
				{
					if (eObject == stkContainers.top().ValueType())
						eStatus = eNameStart;
					else
						eStatus = eValueStart;
						
				}
				else	//should not happen
				{
					ss << __FILE__ << ':' << __LINE__ << ": Comma token after last value";
					goto labelJSONError;
				}
				break;
			default:
				ss << __FILE__ << ':' << __LINE__ << ": Invalid character U+" << hex << uc << dec << " detected at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
				goto labelJSONError;
				
			}
			break;
		case eNameStart:
			if (uc <= 0x20) continue;
			if (UC_QUOT == uc || UC_APOS == uc)	//valid
			{
				try
				{
					c_counter += ReadUSTRINGLit(srcstrm, name, uc);
				}
				catch (JSONExcept e)
				{
					c_counter += e.GetParam();
					size_t bytes = srcstrm.GetCurrIstreamPos();
					ss << __FILE__ << ':' << __LINE__ << ": " << e.what() << " at stream position " << bytes << ", " << c_counter << " unicode characters read";
					
					//throw JSONExcept(e.ValueType(), ss.str(), bytes);
					goto labelJSONError;
				}
				catch (...)
				{
					size_t bytes = srcstrm.GetCurrIstreamPos();
					ss << __FILE__ << ':' << __LINE__ << ": Unspecified streaming error at position " << bytes;
					//throw JSONExcept(eUnknownError, ss.str(), bytes);
					goto labelJSONError;
				}
				
				if (name.empty())
				{
					ss << __FILE__ << ':' << __LINE__ << ": Property name cannot be empty, string expected at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
					goto labelJSONError;
				}
				
				eStatus = eNameEnd;
			}
			else if (UC_OBJEND == uc)	//empty object allowed
			{
				if (!stkContainers.empty())
				{
					JSVar p = stkContainers.top();
					if (p.ValueType() != eObject)
					{
						ss << __FILE__ << ':' << __LINE__ << ": Object closing token at position " << c_counter - 1 << ", but array closing token is expected";
						goto labelJSONError;
					}
					stkContainers.pop();
					if (stkContainers.empty())
					{
						dst = p;
						goto labelDone;
					}
						
					eStatus = eValueEnd;
				}
				else
				{
					ss << __FILE__ << ':' << __LINE__ << ": Extra object closing token at position " << c_counter - 1;
					goto labelJSONError;
				}
			}
			else
			{
				ss << __FILE__ << ':' << __LINE__ << ": String literal expected for property name at position " << c_counter - 1;
				goto labelJSONError;
			}
			break;
		case eNameEnd:	//only valid token is ':'
			if (uc <= 0x20L) continue;
			if (UC_COLON != uc)
			{
				ss << __FILE__ << ':' << __LINE__ << ": Colon token expected at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
				goto labelJSONError;
			}
			eStatus = eValueStart;
			break;
		}
	}
	
	// -- if here, container stack must be empty.
	if (!stkContainers.empty())
	{
		ss << __FILE__ << ':' << __LINE__ << ": Colon token expected at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos();
		goto labelJSONError;
	}
	else	//stkContainers.empty()
	{
		if (!buf.empty())
		{
			JSVar val;
			if (US_JSNULL == buf)
				val = eNull;
			else if (US_JSTRUE == buf)
				val = true;
			else if (US_JSFALSE == buf)
				val = false;
			else
			{
				try
				{
					val = ParseNumberLit(buf);
				}
				catch (JSONExcept e)
				{
					ss << __FILE__ << ':' << __LINE__ << ": " << e.what();
					
					//throw JSONExcept(e.ValueType(), ss.str(), bytes);
					goto labelJSONError;
				}
				catch (...)
				{
					ss << __FILE__ << ':' << __LINE__ << ": Unknown number parsing error";
					//throw JSONExcept(eUnknownError, ss.str(), bytes);
					goto labelJSONError;
				}
			
				if (eUndefined == val.ValueType())
				{
					ss << __FILE__ << ':' << __LINE__ << ": Invalid value literal at unicode position " << c_counter - 1 << ", stream position " << srcstrm.GetCurrIstreamPos() << ", value expected";
					goto labelJSONError;
				}
			}
			
			dst = val;
			//return val;
		}
	}
	
labelDone:	
	return is;
	
	//throw JSONExcept(eStreamBroken, "Unexpected stream end");
	
labelJSONError:
	throw JSONExcept(eJSONDataError, ss.str(), c_counter);
	
	
}

ostream & LJSON::operator << (ostream &os, const LJSON::JSVar &src)
{
	CUTFOstream tokenos(os, E_UTF8), dataos(os, E_UTF8, &MAP_ENTITIES);
	src.Print(tokenos, dataos);
	return os;
}


