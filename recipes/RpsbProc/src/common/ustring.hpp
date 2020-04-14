#if !defined(__USTRING__)
#define __USTRING__

//#include "basicutils.hpp"
#include "normbase.hpp"
#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <cstring>
#include <exception>

typedef UINT32 _uc_char_t;

constexpr const _uc_char_t UC_NULL = 0;
constexpr const _uc_char_t UC_NL = 0xaL;
constexpr const _uc_char_t UC_CR = 0xdL;
constexpr const _uc_char_t UC_QUOT = '"';
constexpr const _uc_char_t UC_APOS = '\'';
constexpr const _uc_char_t UC_WHITESP = ' ';
constexpr const _uc_char_t UC_COLON = ':';
constexpr const _uc_char_t UC_SEMICOLON = ';';
constexpr const _uc_char_t UC_EQUAL = '=';
constexpr const _uc_char_t UC_AMPS = '&';
constexpr const _uc_char_t UC_TAB = '\t';
constexpr const _uc_char_t UC_ESCAPE = '\\';
constexpr const _uc_char_t UC_A = 'A';
constexpr const _uc_char_t UC_F = 'F';
constexpr const _uc_char_t UC_Z = 'Z';
constexpr const _uc_char_t UC_a = 'a';
constexpr const _uc_char_t UC_f = 'f';
constexpr const _uc_char_t UC_z = 'z';
constexpr const _uc_char_t UC_0 = '0';
constexpr const _uc_char_t UC_8 = '8';
constexpr const _uc_char_t UC_9 = '9';

typedef std::char_traits<_uc_char_t> uctraits;

struct ucitraits : public uctraits
{
	static bool eq(_uc_char_t uc1, _uc_char_t uc2);
	static bool lt(_uc_char_t uc1, _uc_char_t uc2);
	static int compare(const _uc_char_t* p, const _uc_char_t* q, size_t n);
};


static const int E_UNKNOWN = 0;
static const int E_UTF8 = 8;
static const int E_UTF16BE = 16;
static const int E_UTF16LE = -16;
static const int E_UTF16 = E_UTF16LE;


enum EEncodingError
{
	eUnrecognizedEncoding,
	eInvalidChar,
	eUnableToReadIstream,
	eUnableToWriteOstream
};

struct TEncErr : public std::exception
{
	EEncodingError ecode;
	int int_param;
	unsigned int uint_param;
	std::string msg;
	virtual const char * what(void) const throw() { return msg.c_str(); }
	TEncErr(EEncodingError e, int i_p, unsigned int ui_p, const std::string &m) : std::exception(), ecode(e), int_param(i_p), uint_param(ui_p), msg(m) {};
	virtual ~TEncErr(void) throw() {};
};



//typedef std::basic_string < _uc_char_t, ucitraits, std::allocator<_uc_char_t> > IUSTRING_base;
bool DecodeFromUTF8(const BYTE *m_dimBuf, size_t ttlBytes, _uc_char_t &uc, size_t &numBytes, bool noMoreBytes);
//size_t EncodeToUTF8(_uc_char_t uc, BYTE *m_dimBuf);
std::string EncodeUBytesToUTF8(const _uc_char_t *pSrc, size_t ttlUChars);

template <typename TCHARTRAITS>
class CUSTRING : public std::basic_string<_uc_char_t, TCHARTRAITS, std::allocator<_uc_char_t> >
{
public:
	typedef std::basic_string<_uc_char_t, TCHARTRAITS, std::allocator<_uc_char_t> > USTRING_base;
	static const CUSTRING k_EmptyUSTRING;
	CUSTRING(void) : USTRING_base() {};
	CUSTRING(const _uc_char_t *chars, size_t n) :
		USTRING_base(chars, n) {};
	CUSTRING(const CUSTRING &src) :
		USTRING_base((const USTRING_base &)src) {};
	CUSTRING(CUSTRING &&src) :
		USTRING_base(std::move((USTRING_base &&)src)) {};
	CUSTRING(const USTRING_base &base) : USTRING_base(base) {};
	CUSTRING(USTRING_base &&base) : USTRING_base(std::move(base)) {};

	CUSTRING & operator = (const CUSTRING &src);
	CUSTRING & operator = (CUSTRING &&src);
	CUSTRING & operator = (const USTRING_base &base);
	CUSTRING & operator = (USTRING_base &&base);


	CUSTRING(const std::string &utf8);
	CUSTRING & operator = (const std::string &utf8);

	//CUSTRING(std::string &utf8);
	//CUSTRING & operator = (std::string &utf8);


	CUSTRING(const char *utf8);
	CUSTRING & operator = (const char *utf8);

	operator std::string(void) const;

private:
	void x_ParseCharArray(const BYTE * pData, size_t ttlBytes);

};

template <typename TCHARTRAITS>
const CUSTRING<TCHARTRAITS> CUSTRING<TCHARTRAITS>::k_EmptyUSTRING;

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (const CUSTRING &src)
{
	USTRING_base::operator = ((const USTRING_base&)src);
	return *this;
}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (CUSTRING &&src)
{
	USTRING_base::operator = (std::move((USTRING_base &&)src));
	return *this;
}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (const USTRING_base &base)
{
	USTRING_base::operator = (base);
	return *this;
}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (USTRING_base &&base)
{
	USTRING_base::operator = (std::move(base));
	return *this;
}

template <typename TCHARTRAITS>
void CUSTRING<TCHARTRAITS>::x_ParseCharArray(const BYTE * pData, size_t ttlBytes)
{
	if (ttlBytes > 0)
	{
		_uc_char_t uc = 0;
		size_t bytesDone = 0, bytes_consumed = 0;
		while (DecodeFromUTF8(pData + bytesDone, ttlBytes - bytesDone, uc, bytes_consumed, true))
		{
			USTRING_base::push_back(uc);
			bytesDone += bytes_consumed;
		}
	}
}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS>::CUSTRING(const std::string &utf8) : USTRING_base()
{
	size_t ttlBytes = utf8.size();
	if (ttlBytes > 0)
		x_ParseCharArray(reinterpret_cast<const BYTE* > (utf8.data()), ttlBytes);

}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS>::CUSTRING(const char *utf8) : USTRING_base()
{
	if (nullptr != utf8)
	{
		size_t ttlBytes = strlen(utf8);
		if (ttlBytes > 0)
			x_ParseCharArray(reinterpret_cast<const BYTE* > (utf8), ttlBytes);
	}
}


template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (const std::string &utf8)
{
	USTRING_base::clear();
	size_t ttlBytes = utf8.size();
	if (ttlBytes > 0)
		x_ParseCharArray(reinterpret_cast<const BYTE* > (utf8.data()), ttlBytes);
	return *this;
}


template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS> & CUSTRING<TCHARTRAITS>::operator = (const char *utf8)
{
	USTRING_base::clear();
	if (nullptr != utf8)
	{
		size_t ttlBytes = strlen(utf8);
		if (ttlBytes > 0)
			x_ParseCharArray(reinterpret_cast<const BYTE* > (utf8), ttlBytes);
	}
	return *this;
}

template <typename TCHARTRAITS>
CUSTRING<TCHARTRAITS>::operator std::string(void) const
{
	return EncodeUBytesToUTF8(USTRING_base::data(), USTRING_base::size());
}

typedef CUSTRING<uctraits> _uc_string_t;
typedef CUSTRING<ucitraits> IUSTRING;

const _uc_string_t & GetEmptyUSTRING(void);
#define k_ustrEmptyUSTRING GetEmptyUSTRING()

typedef bool(*UCDecodeFunc)(const BYTE*, size_t, _uc_char_t&, size_t&, bool);
// -- this class automatically detect utf-8 and utf16 (in either little or big endian)
// -- does not support utf-32. 
class CUTFIstream
{
	template<typename TUSTRING>
	friend CUTFIstream & operator >> (CUTFIstream & dec_stream, TUSTRING &ustr);
	//friend CUTFIstream & operator >> (CUTFIstream & dec_stream, _uc_char_t &uc);
public:
	CUTFIstream(std::istream & bytes_in);
	~CUTFIstream(void);

	// -- try to read n UCHARs and append to ustr, return actual read.
	bool ReadUC(_uc_char_t &uc);
	
	template<typename TUSTRING>
	std::streamsize read(typename TUSTRING::USTRING_base &ustr, std::streamsize n);
	// -- return true if eof reached. otherwise return false

	template<typename TUSTRING>
	size_t getline(typename TUSTRING::USTRING_base &ustr, _uc_char_t delim = UC_NL);


	int GetEncoding(void) const { return m_iDetectedEncoding; }
	// -- simple status query
	bool eof(void) const;
	bool good(void) const;
	std::ios::iostate rdstate(void) const { return m_pBytesInStream->rdstate(); }
	std::streamsize GetCurrIstreamPos(void) const;

private:
	static const std::streamsize BUFSIZE = 4096;
		
	// -- critical resource.
	std::streamsize ret_buff(void);
	// -- read from stream to fill buffer. return true if all bytes are read from stream. Otherwise return false (actual read bytes are less than desired.
	bool fill_buf(void);	//

	std::istream *m_pBytesInStream;
	int m_iDetectedEncoding;
	UCDecodeFunc m_lpfnDecode;
	// -- record total bytes read from istream
	std::streamsize m_ulBytesFromStream;
	// -- buffer
	size_t m_ulBufIdx;
	size_t m_ulTotalBytes;	//in buffer
	BYTE m_dimBuf[BUFSIZE];
};

template<typename TUSTRING>
std::streamsize CUTFIstream::read(typename TUSTRING::USTRING_base &ustr, std::streamsize n)
{
	std::streamsize idx = 0;
	_uc_char_t uc = 0;
	while (idx < n)
	{
		if (!ReadUC(uc))
			break;
		ustr.push_back(uc);
		++idx;
	}
	return idx;
}

template<typename TUSTRING>
size_t CUTFIstream::getline(typename TUSTRING::USTRING_base &ustr, _uc_char_t delim)
{
	std::streamsize idx = 0;
	_uc_char_t uc = 0, last = 0;

	if (!ReadUC(uc))
		return idx;
	while (uc != delim)
	{
		ustr.push_back(uc);
		++idx;
		last = uc;

		if (!ReadUC(uc))
			break;
	}

	if (UC_NL == uc && UC_CR == last)
	{
		ustr.pop_back();
		--idx;
	}

	return idx;
}


template<typename TUSTRING>
CUTFIstream & operator >> (CUTFIstream & dec_stream, TUSTRING &ustr)
{
	_uc_char_t uc = 0;
	while (dec_stream.ReadUC(uc))
		ustr.push_back(uc);

	return dec_stream;
}




//-- Encoding facilities
// -- for escape sequences
typedef std::map<_uc_char_t, std::vector<_uc_char_t> > TEscapeSeqs;
typedef size_t(*UCEncodeFunc)(_uc_char_t, BYTE*);
class CUTFOstream
{
	friend CUTFOstream & operator << (CUTFOstream & enc_stream, _uc_char_t uc);

	template <typename TUSTRING>
	friend CUTFOstream & operator << (CUTFOstream & enc_stream, const TUSTRING &ustr);
public:
	typedef bool (CUTFOstream::*write_uc_func)(_uc_char_t);	//with or without escape check
	typedef bool (CUTFOstream::*write_ustr_func)(const _uc_char_t *ustr, std::streamsize n);
	CUTFOstream(std::ostream & os, int enc = E_UTF8, const TEscapeSeqs *pesc = nullptr);
	void PrintBOM(void);

	bool write(const _uc_char_t *src, std::streamsize n);


private:

	static const std::streamsize BUFSIZE = 4096;

	std::ostream *m_pBytesOutStream;
	int m_iEncoding;
	const TEscapeSeqs *m_pEscSeqs;

	UCEncodeFunc m_lpfnEncode;
	size_t m_ulSentinelBufSize;

	

	write_uc_func m_pWriteUCFunc;
	write_ustr_func m_pWriteUStrFunc;
	// -- buffer
	size_t m_ulBufIdx;
	BYTE m_dimBuf[BUFSIZE];

	bool write_uc(_uc_char_t uc);
	bool write_uc_esc(_uc_char_t uc);

	bool write_ustr(const _uc_char_t *ustr, std::streamsize n);
	bool write_ustr_esc(const _uc_char_t *ustr, std::streamsize n);
};

CUTFOstream & operator << (CUTFOstream & enc_stream, _uc_char_t uc);


template <typename TUSTRING>
CUTFOstream & operator << (CUTFOstream & enc_stream, const TUSTRING &ustr)
{
	enc_stream.write(ustr.data(), ustr.size());
	return enc_stream;
}



#endif
