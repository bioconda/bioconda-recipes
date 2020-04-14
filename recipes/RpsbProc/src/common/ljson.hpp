#if !defined(__LJSON__)
#define __LJSON__

//#include "compactstore.hpp"
#include "ustring.hpp"
#include "datanode.hpp"

#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <cstring>
#include <exception>


namespace LJSON
{
	enum EDataType
	{
		eUndefined = 0,	//when data is not set (empty reference)
		eNull = eUndefined + 1,
		eBoolean = eNull + 1,	//true, false
		eInteger = eBoolean + 1,	//long long
		eReal = eInteger + 1,	//long double
		eString = eReal + 1,	//_uc_string_t
		eArray = eString + 1,
		eObject = eArray + 1
	};
	
	static const int TOTALTYPES = eObject + 1;
	
	enum EJSONError
	{
		eNoError = 0,
		eValueIsUndefined = eNoError + 1,
		eUnsupportedOperation = eValueIsUndefined + 1,	//wrong value type
		eStreamBroken = eUnsupportedOperation + 1,	//unexpected stream finish
		eJSONDataError = eStreamBroken + 1,
		eOutOfArrayBoundary = eJSONDataError + 1,
		ePropNameNotFound = eOutOfArrayBoundary + 1,
		eUnknownError = ePropNameNotFound + 1,
		eEndOfErrors = eUnknownError + 1
	};
	
	extern const char * errMsgs[];

	class JSONExcept: public std::exception
	{
	public:
		JSONExcept(EJSONError code, const std::string &msg, unsigned long long param = 0) throw(): std::exception(), m_msg(msg), m_code(code), m_param(param){};
		~JSONExcept(void) throw(){};
		virtual const char * what() const throw() {return m_msg.c_str();}
		EJSONError type(void) const throw() {return m_code;}
		unsigned long long GetParam(void) const throw() {return m_param;} 
	private:
		std::string m_msg;
		EJSONError m_code;
		unsigned long long m_param;
	};
	class JSVar;
	// -- C++ type for JS values
	typedef bool JSBoolValue;
	typedef long long int JSIntValue;
	typedef long double JSRealValue;
	typedef _uc_string_t JSStringValue;
	typedef std::vector<JSVar> JSArrayValue;
	typedef std::map<_uc_string_t, JSVar> JSObjectValue;
		
	class JSValue: public CDocNodeBase
	{
		friend class JSVar;
	public:

		virtual ~JSValue(void) {};
		virtual EDataType ValueType(void) const = 0;
		
		
	protected:
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos) const = 0;
		virtual void x_Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const = 0;
	};

	
	class JSVar: public CDocNodeRef<JSValue>
	{
		friend std::istream & operator >> (std::istream &is, LJSON::JSVar &src);
		
		// -- default utf8 stream out
		friend std::ostream & operator << (std::ostream &os, const LJSON::JSVar &dst);
	public:
		typedef CDocNodeRef<JSValue> TParent;
		void * operator new (size_t sz);
		void operator delete (void *ptr);
		JSVar(JSValue *val);


		JSVar(EDataType t = eUndefined);
		JSVar(const JSVar &src);
		JSVar(JSBoolValue val);
		
		JSVar(const JSIntValue & val);
		JSVar(long val);
		JSVar(unsigned long val);
		JSVar(int val);
		JSVar(unsigned int val);
		JSVar(short val);
		JSVar(unsigned short val);
		
		JSVar(const JSRealValue & val);
		JSVar(double val);
		
		
		JSVar(const JSStringValue & val);
		JSVar(const std::string & val);
		JSVar(const char * utf8);
		
		JSVar(const JSArrayValue & val);
		JSVar(const JSObjectValue & val);
		
//		const JSVar & operator = (const JSVar &src);
		
		JSBoolValue GetBoolValue(void) const;
		const JSIntValue & GetIntValue(void) const;
		const JSRealValue & GetRealValue(void) const;
		const JSStringValue & GetStringValue(void) const;
		const JSArrayValue & GetArrayValue(void) const;
		const JSObjectValue & GetObjectValue(void) const;
		
		JSArrayValue & SetArrayValue(void);
		JSObjectValue & SetObjectValue(void);
			
		void Print(CUTFOstream &tokenos, CUTFOstream &dataos) const;
		void Print(CUTFOstream &tokenos, CUTFOstream &dataos, int lvl, EDataType p_type = eUndefined) const;
		
		// -- for data accessing
		EDataType ValueType(void) const;
		size_t length(void) const;	//get size of array or object. Other types will throw
		// -- array only, otherwise throw
		
		template <typename T>
		const JSVar & operator [] (T) const;
		
		template <typename T>
		JSVar & operator [] (T);
		
		
		const JSVar & operator [] (const _uc_string_t &) const;
		const JSVar & operator [] (const std::string &) const;
		const JSVar & operator [] (const char *) const;
		const JSVar & operator [] (char *) const;
	
	
		JSVar & operator [] (const _uc_string_t &);
		JSVar & operator [] (const std::string &);
		JSVar & operator [] (const char *);
		JSVar & operator [] (char *);
		
		//const JSVar & operator [] (size_t i) const;
		//JSVar & operator [] (size_t i);
		
		JSVar & push(const JSVar &src);
		// -- object only.
		
		
		//const JSVar & operator [] (const _uc_string_t & key) const;
		//JSVar & operator [] (const _uc_string_t & key);
		
	private:
		//JSBoolValue & SetBoolValue(void);
		JSIntValue & SetIntValue(void);
		JSRealValue & SetRealValue(void);
		JSStringValue & SetStringValue(void);
		//JSArrayValue & SetArrayValue(void);
		//JSObjectValue & SetObjectValue(void);
			
		//void SetBoolValue(JSBoolValue val);
		void SetIntValue(const JSIntValue & val);
		void SetRealValue(const JSRealValue & val);
		void SetStringValue(const JSStringValue & val);
		void SetArrayValue(const JSArrayValue & val);
		void SetObjectValue(const JSObjectValue & val);
		
		//template <typename T>
		//JSVar & operator = (const T&);
	};
	
	std::istream & operator >> (std::istream &is, LJSON::JSVar &dst);
	std::ostream & operator << (std::ostream &os, const LJSON::JSVar &dst);
	class JSONDoc
	{
	public:
		// -- BasicUtils/ustring.hpp
		//static const int E_UTF8 = 8;
		//static const int E_UTF16BE = 16;
		//static const int E_UTF16LE = -16;
		JSONDoc(JSVar root, const _uc_string_t &jsonp = k_ustrEmptyUSTRING, int enc = E_UTF8);
		void Print(std::ostream &os) const;
		void Print(std::ostream &os, int lvl) const;
		
	private:
		JSVar m_root;
		_uc_string_t m_jsonp;
		int m_enc;
	};
	
	extern JSVar null;
	
};


#endif

