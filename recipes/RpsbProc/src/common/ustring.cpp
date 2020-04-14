#include <ncbi_pch.hpp>
#include "ustring.hpp"
//#include <wstring>
#include <sstream>
#include <cstring>
#include <utility>

using namespace std;

//const _uc_string_t k_ustrEmptyUSTRING;
const _uc_string_t & GetEmptyUSTRING(void)
{
	static const _uc_string_t EmptyUSTRING;
	return EmptyUSTRING;
}

inline
_uc_char_t __ucase0(_uc_char_t uc)
{

	if (uc >= 0x61 && uc <= 0x7a) return uc - 0x20;
	return uc;
}

inline void __ucase1(_uc_char_t &uc)
{
	if (uc >= 0x61 && uc <= 0x7a) uc -= 0x20;
}


bool ucitraits::eq(_uc_char_t uc1, _uc_char_t uc2)
{
	__ucase1(uc1);
	__ucase1(uc2);
	return uc1 == uc2;
}

bool ucitraits::lt(_uc_char_t uc1, _uc_char_t uc2)
{
	__ucase1(uc1);
	__ucase1(uc2);
	return uc1 < uc2;
}

int ucitraits::compare(const _uc_char_t* p, const _uc_char_t* q, size_t n)
{
	for (size_t i = 0; i < n; ++i)
	{
		if (ucitraits::lt(p[i], q[i]))
			return -1;
		if (ucitraits::eq(p[i], q[i]))
			continue;
		return 1;
	}
	return 0;
}

const _uc_char_t UTFBOM = 0xFEFF;

const size_t UTF8BUFSIZE = 6;
const size_t UTF16SIZE = 2;

bool IsValidUTF8Start(unsigned char uc, size_t &numbytes)
{

	unsigned mask = 0x80;
	if (0 == (uc & mask))
	{
		numbytes = 1;
		return true;
	}

	mask >>= 1;
	if (0 == (uc & mask))	//invalid! 
		return false;
	numbytes = 2;

	mask >>= 1;
	while (mask > 1 && (uc & mask) > 0)
	{
		++numbytes;
		mask >>= 1;
	}

	if (1 == mask)
		return false;

	return true;
}

// -- return if successful. If not enough bytes in m_dimBuf, return false. If not start
// -- with valid utf-8 sequence, throw TEncErr
// -- if return true (success), numBytes contains number of bytes consumed. 
// -- if return false (fail due to not enough bytes), numBytes contains number of more bytes needed
// -- if noMoreBytes, rest bytes treated as is (non-encoded byte).
bool DecodeFromUTF8(const BYTE *m_dimBuf, size_t ttlBytes, _uc_char_t &uc, size_t &numBytes, bool noMoreBytes)
{
	numBytes = 0;
	if (ttlBytes > 0)
	{
		if (!IsValidUTF8Start(m_dimBuf[0], numBytes))
		{

			//if (!forceCont)
			//{
			//	char dimBuf[16];
			//	sprintf(dimBuf, "0x%x", (unsigned int)(m_dimBuf[0]));
			//	throw TEncErr(string("Invalid UTF8 start byte -- ") + dimBuf);
			//}

			// -- treat as non-necoded byte
			//uc = m_dimBuf[0];
			numBytes = 1;
			//return true;
		}

		if (1 == numBytes)	//just one
			uc = m_dimBuf[0];
		else if (numBytes > ttlBytes)
		{
			if (!noMoreBytes)
			{
				numBytes -= ttlBytes;

				return false;
			}
			// -- if no more bytes, treat rest bytes as unencoded
			uc = m_dimBuf[0];
			numBytes = 1;
		}
		// -- start decoding
		else
		{
			unsigned char ucmask = 0xff >> (numBytes + 1);

			uc = (m_dimBuf[0] & ucmask);

			for (size_t idx = 1; idx < numBytes; ++idx)
			{
				uc = (uc << 6) + (m_dimBuf[idx] & 0x3f);

			}
		}
		return true;
	}
	return false;
}

// -- if noPair == true, when two bytes for leading surrogate detected but not enough bytes for trailing surrogates, decode leading as normal
// -- code point (illegal in UTF16 standard) instead of return false for more bytes.
bool DecodeFromUTF16LE(const BYTE *m_dimBuf, size_t ttlBytes, _uc_char_t &uc, size_t &numBytes, bool noMoreBytes)
{
	numBytes = 0;
	if (ttlBytes > 0)
	{
		numBytes = UTF16SIZE;
		if (ttlBytes < numBytes)
		{
			if (!noMoreBytes)
			{
				numBytes -= ttlBytes;
				return false;
			}

			// no more bytes, treat this as unencoded byte
			uc = m_dimBuf[0];
			numBytes = 1;
		}
		else	//we have at least two butes
		{
			uc = (((_uc_char_t)(m_dimBuf[1])) << 8) + m_dimBuf[0];

			if (m_dimBuf[1] >= 0xD8 && m_dimBuf[1] < 0xDC)	//possible surrpair
			{
				numBytes += UTF16SIZE;

				if (ttlBytes < numBytes)
				{
					if (!noMoreBytes)
					{
						numBytes -= ttlBytes;
						return false;
					}
					// -- code this as 
					numBytes -= UTF16SIZE;
				}
				else if (m_dimBuf[3] >= 0xDC && m_dimBuf[3] < 0xE0)	//surrpair)
					uc = 0x10000 + ((uc - 0xD800) << 10) + (((_uc_char_t)m_dimBuf[3] << 8) + m_dimBuf[2] - 0xDC00);
				else
					numBytes -= UTF16SIZE;
			}
		}

		return true;

	}
	return false;
}

bool DecodeFromUTF16BE(const BYTE *m_dimBuf, size_t ttlBytes, _uc_char_t &uc, size_t &numBytes, bool noMoreBytes)
{
	numBytes = 0;
	if (ttlBytes > 0)
	{
		numBytes = UTF16SIZE;
		if (ttlBytes < numBytes)	//only one byte -- has to return false
		{
			if (!noMoreBytes)
			{
				numBytes -= ttlBytes;
				return false;
			}
			// no more bytes, treat this as unencoded byte
			uc = m_dimBuf[0];
			numBytes = 1;
		}
		else
		{
			// -- at least two bytes
			uc = (((_uc_char_t)(m_dimBuf[0])) << 8) + m_dimBuf[1];

			if (m_dimBuf[0] >= 0xD8 && m_dimBuf[0] < 0xDC)	//possible surrpair
			{
				numBytes += UTF16SIZE;
				if (ttlBytes < numBytes)	//not enough for a second pair
				{
					if (!noMoreBytes)	//return false for trailing surrogate
					{
						numBytes -= ttlBytes;
						return false;
					}
					// -- no more bytes, just treat it as normal cp
					numBytes -= UTF16SIZE;
				}
				else if (m_dimBuf[2] >= 0xDC && m_dimBuf[2] < 0xE0)	//surrpair)
					uc = 0x10000 + ((uc - 0xD800) << 10) + (((_uc_char_t)m_dimBuf[2] << 8) + m_dimBuf[3] - 0xDC00);
				else	//not surrogate pair, already calculated uc
					numBytes -= UTF16SIZE;
			}
		}
		return true;
	}
	return false;
}


int DetectEncoding(const char *src, size_t ttlchars, size_t &bomEnd)
//int DetectEncoding(const string &str, size_t &bomEnd)
{
	// -- UTF-8 BOM: 
	size_t idx = 0;
	bomEnd = 0;	//assume no BOM
	if (idx < ttlchars)
	{
		unsigned char uc = (unsigned char)src[idx];
		switch (uc)
		{
		case 0xff:	//possible UTF16LE
			++idx;
			if (idx < ttlchars)
			{
				uc = (unsigned char)src[idx];
				if (0xfe == uc)	//BOM Found for E_UTF16LE
				{
					bomEnd = ++idx;
					return E_UTF16LE;
				}
			}

			break;
		case 0xfe:	//possible UTF16BE
			++idx;
			if (idx < ttlchars)
			{
				uc = (unsigned char)src[idx];
				if (0xff == uc)	//BOM Found for E_UTF16BE
				{

					bomEnd = ++idx;
					return E_UTF16BE;
				}
			}

			break;

		case 0xef:	//UTF8-sig
			++idx;
			if (idx < ttlchars)
			{
				uc = (unsigned char)src[idx];
				if (0xbb == uc)	//BOM Found for E_UTF8
				{
					++idx;
					if (idx < ttlchars)
					{
						uc = (unsigned char)src[idx];
						if (0xbf == uc)	//UTF8 mark found
						{
							bomEnd = ++idx;
							return E_UTF8;
						}
					}

				}
			}

			break;
		}	//switch looking for signatures

		// -- no signature found. 
		idx = 0;
		bomEnd = 0;
		size_t odd_nulls = 0, even_nulls = 0, odd_sps = 0, even_sps = 0, utf8seqsz = 0;

		// -- check if are UTF8 valid
		bool bUTF8Valid = true;

		size_t spLeadAt = string::npos;

		while (idx < ttlchars)
		{
			uc = (unsigned char)src[idx];
			if (0 == uc)
			{
				++((idx & 0x1) ? odd_nulls : even_nulls);
			}

			// -- if still in valid UTF-8 sequence
			if (bUTF8Valid)
			{
				if (0 == utf8seqsz)	//should start a new sequence
				{
					if ((bUTF8Valid = IsValidUTF8Start(uc, utf8seqsz)))
						--utf8seqsz;
				}
				else if ((0xc0 & uc) == 0x80)
					--utf8seqsz;
				else
					bUTF8Valid = false;
			}

			if (string::npos == spLeadAt && uc >= 0xD8 && uc < 0xDC)
			{
				spLeadAt = idx;

			}
			else if (uc >= 0xDC && uc < 0xE0)
			{
				if (idx == spLeadAt + 2)
					++((spLeadAt & 0x1) ? odd_sps : even_sps);
				spLeadAt = string::npos;
			}


			++idx;
		}

		// -- now check for flags
		if (bUTF8Valid)
			return E_UTF8;

		// -- now borrow bUTF8Valid as flag of big (true) or little (false) endian
		if (even_nulls > odd_nulls)
		{
			if (even_sps > odd_sps || (even_nulls - odd_nulls > odd_sps - even_sps))
				return E_UTF16BE;	//high confidence

			return E_UTF16LE;
		}
		else if (even_nulls < odd_nulls)
		{
			if (even_sps < odd_sps || (odd_nulls - even_nulls > even_sps - odd_sps))
				return E_UTF16LE;	//high confidence

			return E_UTF16BE;
		}
		else if (even_sps > odd_sps)
			return E_UTF16BE;

		return E_UTF16BE;
	}
	return E_UNKNOWN;
}




// -- must guarantee enough space for *m_dimBuf. 
// -- return number of bytes generated
size_t EncodeToUTF8(_uc_char_t uc, BYTE *m_dimBuf)
{
	unsigned char mask = 0xff, hdr = 0xfe;
	size_t numbytes = 0;
	if (uc < 0x80L)
	{
		m_dimBuf[0] = (unsigned char)(uc & 0x7f);
		return 1;
	}
	else if (uc < 0x800L)
	{
		numbytes = 2;
	}
	else if (uc < 0x10000L)
	{
		numbytes = 3;
	}
	else if (uc < 0x200000L)
	{
		numbytes = 4;
	}
	else if (uc < 0x4000000L)
	{
		numbytes = 5;
	}
	else
	{
		numbytes = 6;
	}

	for (size_t i = numbytes; i > 1; --i)
	{
		m_dimBuf[i - 1] = 0x80 | (uc & 0x3f);
		uc >>= 6;
	}

	m_dimBuf[0] = (uc & (mask >> (numbytes + 1))) | (hdr << (7 - numbytes));

	return numbytes;
}


size_t EncodeToUTF16LE(_uc_char_t uc, BYTE *m_dimBuf)
{
	size_t numbytes = UTF16SIZE;
	if (uc >= 0x10FFFF)	//max for UTF16, just treat as 0x10FFFF
	{
		m_dimBuf[1] = 0xDB;
		m_dimBuf[0] = 0xFF;
		m_dimBuf[3] = 0xDF;
		m_dimBuf[2] = 0xFF;
		numbytes = UTF16SIZE + UTF16SIZE;
	}
	else if (uc > 0xFFFF)	//use surrogte-pair
	{
		uc -= 0x10000;
		UINT16 tailing = 0xDC00 + (uc & 0x3FF);
		uc = (uc >> 10) + 0xD800;
		m_dimBuf[1] = uc >> 8;
		m_dimBuf[0] = uc & 0xFF;
		m_dimBuf[3] = tailing >> 8;
		m_dimBuf[2] = tailing & 0xFF;
		numbytes = UTF16SIZE + UTF16SIZE;
	}
	else // -- no surrogte-pair
	{
		m_dimBuf[1] = uc >> 8;
		m_dimBuf[0] = uc & 0xFF;
	}

	return numbytes;
}

size_t EncodeToUTF16BE(_uc_char_t uc, BYTE *m_dimBuf)
{
	size_t numbytes = UTF16SIZE;
	if (uc >= 0x10FFFF)	//max for UTF16, just treat as 0x10FFFF
	{
		m_dimBuf[0] = 0xDB;
		m_dimBuf[1] = 0xFF;
		m_dimBuf[2] = 0xDF;
		m_dimBuf[3] = 0xFF;
		numbytes = UTF16SIZE + UTF16SIZE;
	}
	else if (uc > 0xFFFF)	//use surrogte-pair
	{
		uc -= 0x10000;
		UINT16 tailing = 0xDC00 + (uc & 0x3FF);
		uc = (uc >> 10) + 0xD800;
		m_dimBuf[0] = uc >> 8;
		m_dimBuf[1] = uc & 0xFF;
		m_dimBuf[2] = tailing >> 8;
		m_dimBuf[3] = tailing & 0xFF;
		numbytes = UTF16SIZE + UTF16SIZE;
	}
	else // -- no surrogte-pair
	{
		m_dimBuf[0] = uc >> 8;
		m_dimBuf[1] = uc & 0xFF;
	}
	return numbytes;
}



string EncodeUBytesToUTF8(const _uc_char_t *pSrc, size_t ttlUChars)
{
	BYTE buf[UTF8BUFSIZE];
	string dst;
	for (size_t i = 0; i < ttlUChars; ++i)
		dst.append(reinterpret_cast<const char*> (buf), EncodeToUTF8(pSrc[i], buf));
	return dst;
}

CUTFIstream::CUTFIstream(istream &bytes_in) :
m_pBytesInStream(&bytes_in), m_iDetectedEncoding(E_UTF8), m_lpfnDecode(&DecodeFromUTF8), m_ulBytesFromStream(0), m_ulBufIdx(0), m_ulTotalBytes(0)
{
	if (!m_pBytesInStream->good())
		throw TEncErr(eUnableToReadIstream, m_pBytesInStream->rdstate(), 0, "Initial reading of input stream error, stream not in goodbit");
	m_ulTotalBytes = m_pBytesInStream->read(reinterpret_cast< char* > (m_dimBuf), BUFSIZE).gcount();
	if (0 == m_ulTotalBytes)
		throw TEncErr(eUnableToReadIstream, m_pBytesInStream->rdstate(), 0, "Reading operation returned 0 bytes");

	size_t bomEnd = 0;
	m_iDetectedEncoding = DetectEncoding(reinterpret_cast< const char* > (m_dimBuf), m_ulTotalBytes, bomEnd);
	switch (m_iDetectedEncoding)
	{
	case E_UTF8:
		break;	//nothing needs to be done
	case E_UTF16LE:
		m_lpfnDecode = &DecodeFromUTF16LE;
		break;
	case E_UTF16BE:
		m_lpfnDecode = &DecodeFromUTF16BE;
		break;
	default:
		{
			m_pBytesInStream->seekg(0, m_pBytesInStream->beg);
			throw TEncErr(eUnrecognizedEncoding, 0, 0, "Unable to determine stream encoding");
		}
	}
	m_pBytesInStream->clear();
	m_pBytesInStream->seekg(bomEnd, m_pBytesInStream->beg);
	m_ulTotalBytes = 0;
	//m_ulBufIdx = 0;
	m_ulBytesFromStream += bomEnd;
}


bool CUTFIstream::ReadUC(_uc_char_t &uc)
{
	size_t bytes_consumed = 0;
	bool no_more_bytes = m_pBytesInStream->eof();
	bool gotit = m_lpfnDecode(m_dimBuf + m_ulBufIdx, m_ulTotalBytes - m_ulBufIdx, uc, bytes_consumed, no_more_bytes);
	if (!gotit && !no_more_bytes)
	{
		no_more_bytes = fill_buf();
		gotit = m_lpfnDecode(m_dimBuf + m_ulBufIdx, m_ulTotalBytes - m_ulBufIdx, uc, bytes_consumed, no_more_bytes);
	}

	if (gotit)
		m_ulBufIdx += bytes_consumed;
	return gotit;
}




streamsize CUTFIstream::GetCurrIstreamPos(void) const
{
	return m_ulBytesFromStream + m_ulBufIdx - m_ulTotalBytes;
}

streamsize CUTFIstream::ret_buff(void)
{
	streamsize pos = GetCurrIstreamPos();

	if (pos < m_ulBytesFromStream)
	{
		m_pBytesInStream->clear();
		m_pBytesInStream->seekg(pos, m_pBytesInStream->beg);
	}
		

	m_ulTotalBytes = m_ulBufIdx = 0;	//reset buffer
	return pos;
}

bool CUTFIstream::fill_buf(void)
{
	size_t leftover = m_ulTotalBytes - m_ulBufIdx;
	if (leftover > 0 && m_ulBufIdx > 0)
		memcpy(m_dimBuf, m_dimBuf + m_ulBufIdx, leftover * sizeof(BYTE));
	m_ulBufIdx = 0;
	m_ulTotalBytes = leftover;

	bool no_more_bytes = m_pBytesInStream->eof();
	if (leftover < BUFSIZE && !no_more_bytes)
	{
		size_t bytes_read = m_pBytesInStream->read(reinterpret_cast< char* > (m_dimBuf + leftover), (BUFSIZE - leftover) * sizeof(BYTE)).gcount();
		m_ulTotalBytes += bytes_read;
		no_more_bytes = m_pBytesInStream->eof();
		m_ulBytesFromStream += bytes_read;
	}

	return no_more_bytes;
}

bool CUTFIstream::eof(void) const
{
	return (m_pBytesInStream->eof() && m_ulBufIdx >= m_ulTotalBytes);
}

bool CUTFIstream::good(void) const
{
	return (m_pBytesInStream->good() || m_ulBufIdx < m_ulTotalBytes);
}


CUTFIstream::~CUTFIstream(void)
{
	ret_buff();
}


CUTFOstream::CUTFOstream(ostream & os, int enc, const TEscapeSeqs *pesc) :
m_pBytesOutStream(&os), m_iEncoding(enc), m_pEscSeqs(pesc), m_lpfnEncode(&EncodeToUTF8), m_ulSentinelBufSize(UTF8BUFSIZE), m_pWriteUCFunc(&CUTFOstream::write_uc), m_pWriteUStrFunc(&CUTFOstream::write_ustr), m_ulBufIdx(0)
{
	switch (enc)
	{
	case E_UTF16LE:
		m_iEncoding = enc;
		m_lpfnEncode = &EncodeToUTF16LE;
		m_ulSentinelBufSize = UTF16SIZE + UTF16SIZE;	//for surrogate pairs
		break;
	case E_UTF16BE:
		m_iEncoding = enc;
		m_lpfnEncode = &EncodeToUTF16BE;
		m_ulSentinelBufSize = UTF16SIZE + UTF16SIZE;	//for surrogate pairs
		break;
	default:;
	}

	if (nullptr != m_pEscSeqs)
	{
		m_pWriteUCFunc = &CUTFOstream::write_uc_esc;
		m_pWriteUStrFunc = &CUTFOstream::write_ustr_esc;
	}
}

void CUTFOstream::PrintBOM(void)
{
	write_uc(UTFBOM);
}

bool CUTFOstream::write(const _uc_char_t *src, std::streamsize n)
{
	return (this->*m_pWriteUStrFunc)(src, n);
}

bool CUTFOstream::write_uc(_uc_char_t uc)
{
	bool success = true;
	m_ulBufIdx += m_lpfnEncode(uc, m_dimBuf + m_ulBufIdx);
	try
	{
		m_pBytesOutStream->write(reinterpret_cast< const char* >(m_dimBuf), m_ulBufIdx);
		success = m_pBytesOutStream->good();
	}
	catch (...)
	{
		success = false;
	}

	m_ulBufIdx = 0;

	return success;
}

bool CUTFOstream::write_ustr(const _uc_char_t *src, streamsize n)
{
	bool isgood = m_pBytesOutStream->good();
	streamsize idx = 0;

	// -- no escape sequence
	while (idx < n && isgood)
	{
		m_ulBufIdx += m_lpfnEncode(src[idx], m_dimBuf + m_ulBufIdx);

		if (m_ulBufIdx + m_ulSentinelBufSize > BUFSIZE)
		{
			// -- write to stream
			try
			{
				m_pBytesOutStream->write(reinterpret_cast< const char* > (m_dimBuf), m_ulBufIdx);
			}
			catch (...)
			{
				;
			}

			m_ulBufIdx = 0;
			isgood = m_pBytesOutStream->good();

		}

		++idx;
	}
	// -- last batch
	if (m_ulBufIdx > 0 && isgood)
	{
		try
		{
			m_pBytesOutStream->write(reinterpret_cast< const char* > (m_dimBuf), m_ulBufIdx);
		}
		catch (...)
		{
			;
		}
		isgood = m_pBytesOutStream->good();
		m_ulBufIdx = 0;
	}
	return isgood;
}


// -- assume m_pEscSeqs is not nullptr
bool CUTFOstream::write_uc_esc(_uc_char_t uc)
{

	TEscapeSeqs::const_iterator iterEsc = m_pEscSeqs->find(uc);

	if (m_pEscSeqs->end() != iterEsc)
		return write_ustr(&(*iterEsc->second.begin()), iterEsc->second.size());

	return write_uc(uc);
}

bool CUTFOstream::write_ustr_esc(const _uc_char_t *ustr, streamsize n)
{
	TEscapeSeqs::const_iterator iterEsc = m_pEscSeqs->end(), iterEscEnd = iterEsc;
	streamsize idx = 0;
	bool isgood = m_pBytesOutStream->good();

	size_t escIdx = 0, escEnd = 0;
	while (idx < n && isgood)
	{
		if (escEnd > 0)	//dealing with escape sequence
		{
			if (escIdx == escEnd)
			{
				++idx;
				escIdx = escEnd = 0;
				continue;
			}
			else	//assume escIdx < escEnd
			{
				m_ulBufIdx += m_lpfnEncode(iterEsc->second[escIdx], m_dimBuf + m_ulBufIdx);
				++escIdx;
			}
		}
		else	//0 == escEnd, normal text
		{
			_uc_char_t uc = ustr[idx];

			iterEsc = m_pEscSeqs->find(uc);
			if (iterEscEnd != iterEsc)
			{
				if (iterEsc->second.empty())	//escaped away
				{
					++idx;
					continue;
				}
				escIdx = 0;
				escEnd = iterEsc->second.size();
				continue;
			}
			else	// -- no escape, normal write
			{
				m_ulBufIdx += m_lpfnEncode(uc, m_dimBuf + m_ulBufIdx);
				++idx;
			}
		}

		if (m_ulBufIdx + m_ulSentinelBufSize > BUFSIZE)
		{
			// -- write to stream
			try
			{
				m_pBytesOutStream->write(reinterpret_cast< const char* > (m_dimBuf), m_ulBufIdx);
			}
			catch (...)
			{
				;
			}

			isgood = m_pBytesOutStream->good();
			m_ulBufIdx = 0;
		}
	}

	// -- last batch
	if (m_ulBufIdx > 0 && isgood)
	{
		// -- write to stream
		try
		{
			m_pBytesOutStream->write(reinterpret_cast< const char* > (m_dimBuf), m_ulBufIdx);
		}
		catch (...)
		{
			;
		}

		isgood = m_pBytesOutStream->good();
		m_ulBufIdx = 0;
	}

	return isgood;

}

CUTFOstream & operator << (CUTFOstream & enc_stream, _uc_char_t uc)
{
	(enc_stream.*(enc_stream.m_pWriteUCFunc))(uc);
	return enc_stream;
}
