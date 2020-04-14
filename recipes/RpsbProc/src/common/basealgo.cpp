#include <ncbi_pch.hpp>
#include "basealgo.hpp"
#include <cstdarg>
#include <cstring>
using namespace std;

void TrimString(string &ori) noexcept
{
	size_t pos0 = 0, pos1 = ori.size(), len = pos1;
	while (pos0 < pos1)
	{
		if (ori[pos0] > ' ')
			break;
		++pos0;
	}
	
	while (pos1 > pos0)
	{
		if (ori[pos1 - 1] > ' ')
			break;
		--pos1;
	}
	
	if (pos1 - pos0 < len)
		ori = ori.substr(pos0, pos1 - pos0);
}

string TrimString(string &&ori) noexcept
{
	TrimString(ori);
	return move(ori);
}

void LTrimString(string &ori) noexcept
{
	size_t pos = 0, len = ori.size();
	while (pos < len)
	{
		if (ori[pos] > ' ')
			break;
		++pos;
	}
	
	if (pos > 0)
		ori = ori.substr(pos);
}

string LTrimString(string &&ori) noexcept
{
	LTrimString(ori);
	return move(ori);
}

void RTrimString(string &ori) noexcept
{
	size_t pos = ori.size(), len = pos;
	while (pos > 0)
	{
		if (ori[pos - 1] > ' ')
			break;
		--pos;
	}
	
	if (pos < len)
		ori = ori.substr(0, pos);
}

string RTrimString(string &&ori) noexcept
{
	RTrimString(ori);
	return move(ori);
}


char* StrCat(const char* lpszFirst...)
{
	if (nullptr == lpszFirst) return nullptr;
	va_list pArgs;
	va_start(pArgs, lpszFirst);
	unsigned int uiSize = 0;
	const char *lpszOneStr = lpszFirst;
	do
	{
		uiSize += strlen(lpszOneStr);	//calculate
	}while (nullptr != (lpszOneStr = va_arg(pArgs, char*)));	//deal with it until nullptr
	
	char *lpszResult = new char[uiSize + 1];	//allocate
	lpszOneStr = lpszFirst;
	char *pDest = lpszResult;
	
	// -- second time loop -- copy strings
	va_start(pArgs, lpszFirst);
	do	//deal with it until nullptr
	{
		while ((*pDest++ = *lpszOneStr++));
		pDest--;
	}while (nullptr != (lpszOneStr = va_arg(pArgs, char*)));
	va_end(pArgs);
	return lpszResult;
}

void StrCatBuf(char * buf, const char* lpszFirst...)
{
	if (nullptr == lpszFirst) return;
	char * pDest = buf;
	va_list pArgs;
	va_start(pArgs, lpszFirst);
	const char *lpszOneStr = lpszFirst;
	do
	{
		while ((*pDest++ = *lpszOneStr++));
		pDest--;

	}while (nullptr != (lpszOneStr = va_arg(pArgs, char*)));	//deal with it until nullptr

	va_end(pArgs);
}

size_t StrToUpper(string &dst)
{
	size_t count = 0;
	
	for (string::iterator iter = dst.begin(), iterEnd = dst.end(); iterEnd != iter; ++iter)
	{
		*iter = toupper(*iter);
		++count;
	}
	return count;
}

size_t StrToLower(string &dst)
{
	size_t count = 0;
	
	for (string::iterator iter = dst.begin(), iterEnd = dst.end(); iterEnd != iter; ++iter)
	{
		*iter = tolower(*iter);
		++count;
	}
	return count;
}


size_t StringReplace(string& rText, const string& rOld, const string& rNew)
{
	size_t counter = 0;
	size_t old_len = rOld.length(), new_len = rNew.length();
	
	size_t pos = rText.find(rOld);
	while (string::npos != pos)	//found instance
	{
		++counter;	//counting
		rText.replace(pos, old_len, rNew);
		pos = rText.find(rOld, pos + new_len);	//skip rNew. will not replace instance inside rNew
	}
	return counter;
}

void BinHexOut(std::ostream &os, const BYTE * src, size_t n, const char delim)
{
	char dlm[2] = {0, 0};
	const BYTE *pidx = src;
	for (size_t i = 0; i < n; ++i, ++pidx)
	{
		
		os << dlm << Nib2Char((*pidx) >> 4) << Nib2Char((*pidx) & 0xf);
		dlm[0] = delim;
	}
}



void CStringTokenizer::SplitString(const string& rSrcStr, const string& rToken, vector<string>& container)
{
	container.clear();
	if (rSrcStr.empty()) return;
	
	size_t token_len = rToken.size(), last_pos = 0;
	
labelNext:
	size_t pos = rSrcStr.find(rToken, last_pos);
	if (pos == string::npos)
	{
		container.emplace_back(rSrcStr.substr(last_pos));
		return;
	}
	
	container.emplace_back(rSrcStr.substr(last_pos, pos - last_pos));
	last_pos = pos + token_len;
	goto labelNext;
}


void CStringTokenizer::SplitString(const string& rSrcStr, char tk, vector<string>& container)
{
	container.clear();
	if (rSrcStr.empty()) return;
	
	size_t last_pos = 0;
	
labelNext:
	size_t pos = rSrcStr.find(tk, last_pos);
	if (pos == string::npos)
	{
		container.emplace_back(rSrcStr.substr(last_pos));
		return;
	}
	
	container.emplace_back(rSrcStr.substr(last_pos, pos - last_pos));
	last_pos = pos + 1;
	goto labelNext;
}



CStringTokenizer::CStringTokenizer(const string &str, const string & tk):
	m_src(&str), m_token(tk), m_len(m_src->size()), m_tklen(m_token.size()), m_pos(0)
{}


CStringTokenizer::CStringTokenizer(const std::string &str, std::string && tk):
	m_src(&str), m_token(move(tk)), m_len(m_src->size()), m_tklen(m_token.size()), m_pos(0)
{}

CStringTokenizer::CStringTokenizer(const string &str, char tk):
	m_src(&str), m_token(1, tk), m_len(m_src->size()), m_tklen(m_token.size()), m_pos(0)
{}

void CStringTokenizer::Reset(const string &str, const string & tk)
{
	m_src = &str;
	m_token = tk;
	m_len = m_src->size();
	m_tklen = m_token.size();
	m_pos = 0;
}

void CStringTokenizer::Reset(const string &str, string && tk)
{
	m_src = &str;
	m_token = move(tk);
	m_len = m_src->size();
	m_tklen = m_token.size();
	m_pos = 0;
}

void CStringTokenizer::Reset(const string &str, char tk)
{
	m_src = &str;
	m_token.clear();
	m_token.push_back(tk);
	m_len = m_src->size();
	m_tklen = 1;
	m_pos = 0;
}

// -- return the current substr and advance pointer to next
string CStringTokenizer::get(void)
{
	if (m_pos >= m_len) throw 0;
	if (m_token.empty())
	{
		m_pos = m_len;
		return *m_src;
	}
	size_t pos1 = m_src->find(m_token, m_pos);
	if (string::npos == pos1)	//last one
		pos1 = m_len;
	size_t tp0 = m_pos;
	m_pos = pos1 + m_tklen;
	return m_src->substr(tp0, pos1 - tp0);
}

string CStringTokenizer::getidx(unsigned int i) const
{
	if (m_token.empty())
	{
		if (i > 0) throw 0;
		return *m_src;
	}
	
	size_t pos0 = 0, pos1 = m_src->find(m_token, pos0);
	if (string::npos == pos1)
		pos1 = m_len;

	while (i > 0)
	{
		if (pos1 >= m_len)
			throw 0;
		
		pos0 = pos1 + m_tklen;
		pos1 = m_src->find(m_token, pos0);
		if (string::npos == pos1)
			pos1 = m_len;
		--i;
	}

	return m_src->substr(pos0, pos1 - pos0);
}
	
	

size_t CStringTokenizer::count(void) const
{
	if (m_pos >= m_len)
		return 0;
	
	if (m_token.empty())
		return 1;
		
	size_t c = 0;
	size_t pos0 = m_pos;
	while (pos0 < m_len)
	{
		pos0 = m_src->find(m_token, pos0);
		++c;
		if (string::npos == pos0)
			pos0 = m_len;
		else
			++pos0;
	}
		
	return c;
}



char * B64Encode(const void * blob, size_t &bytes)
{
	static char baseTable[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	if (0 == bytes || nullptr == blob) return nullptr;
	
	ldiv_t grp_info = ldiv((long)bytes, 3);
	
	
	unsigned char *pBlob = (unsigned char *)blob;
	
	char * result = new char [(grp_info.quot + 1) * 4];
	memset(result, 0, sizeof(unsigned char) * (grp_info.quot + 1) * 4);
	
	char * dest = result;
	
	
	for (long i = 0; i < grp_info.quot; ++i)
	{
		dest[0] = baseTable[pBlob[0] >> 2];
		dest[1] = baseTable[((pBlob[0] & 0x3) << 4) + (pBlob[1] >> 4)];
		dest[2] = baseTable[((pBlob[1] & 0xf) << 2) + (pBlob[2] >> 6)];
		dest[3] = baseTable[pBlob[2] & 0x3f];
		dest += 4;
		pBlob += 3;
	}
	
	// -- at this point pBlob already pointed to the rest bytes
	
	if (grp_info.rem > 0)
	{
		unsigned char remainder[3];
		remainder[0] = remainder[1] = remainder[2] = 0;
		for (long i = 0; i < grp_info.rem; ++i) remainder[i] = pBlob[i];
		
		dest[0] = baseTable[remainder[0] >> 2];
		
		if (1 == grp_info.rem)
		{
			dest[1] = baseTable[((remainder[0] & 0x3) << 4) + (remainder[1] >> 4)];
			dest[2] = dest[3] = '=';
			
		}
		else if (2 == grp_info.rem)
		{
			dest[1] = baseTable[((remainder[0] & 0x3) << 4) + (remainder[1] >> 4)];
			dest[2] = baseTable[((remainder[1] & 0xf) << 2) + (remainder[2] >> 6)];
			dest[3] = '=';
		}
		
		++grp_info.quot;
	}
	
	bytes = grp_info.quot * 4;
	
	return result;
}

unsigned char __B64BitValue(char c)
{
	if ('+' == c) return 62;
	if ('/' == c) return 63;
	if ('#' == c) return 0;
	if (c <= '9') return c - '0' + 52;
	if (c <= 'Z') return c - 'A';
	return c - 'a' + 26;
}

unsigned char * B64Decode(const char * src, size_t &bytes)
{
	if (nullptr == src || 0 == bytes) return nullptr;
	const char * src_end = src + bytes;
		
	size_t grps = bytes / 4;
	size_t dst_len = grps * 3;
	
	
	unsigned char *buf = new unsigned char [dst_len];
	memset(buf, 0, dst_len * sizeof(unsigned char));
	
	const char * src_idx = src;
	unsigned char * dst_idx = buf;
	
	char src_grp[4];
	int src_grp_idx = 0;
	
	int pad_idx = -1;
	
	while (src_idx < src_end)
	{
		if (isalnum(*src_idx) || '+' == *src_idx || '/' == *src_idx)	//skip invalid chars
		{
			if (pad_idx >= 0)	//error: normal characters after '='
				goto error_return;
			src_grp[src_grp_idx++] = *src_idx;
		}
		else if ('=' == *src_idx)
		{
			if (src_grp_idx < 2)	//invalid situation. error in src string
				goto error_return;
			if (pad_idx < 0) pad_idx = src_grp_idx;
			src_grp[src_grp_idx++] = *src_idx;
		}
		
		if (src_grp_idx >= 4)	//do decoding for one group
		{
			
			

			unsigned char v0 = __B64BitValue(src_grp[0]);
			unsigned char v1 = __B64BitValue(src_grp[1]);
			unsigned char v2 = __B64BitValue(src_grp[2]);
			unsigned char v3 = __B64BitValue(src_grp[3]);
			
			
			dst_idx[0] = (v0 << 2) + (v1 >> 4);
			dst_idx[1] = ((v1 & 0xf) << 4) + (v2 >> 2);
			dst_idx[2] = ((v2 & 0x3) << 6) + v3;
			
			dst_idx += 3;
			src_grp_idx = 0;
			
			if (pad_idx >= 0) break;
		}
		++src_idx;
	}

	
	if (src_grp_idx > 0) goto error_return;//incomplete set, error
	
	switch (pad_idx)
	{
		case -1:
			bytes = dst_idx - buf;
			break;
		case 2:
			bytes = dst_idx - buf - 2;
			break;
		case 3:
			bytes = dst_idx - buf - 1;
			break;
		default:
			goto error_return;
	}
	
	return buf;
	
error_return:
	delete [] buf;
	bytes = 0;
	return nullptr;
	
}


struct _xMD5Implement
{
	static constexpr const size_t U32ChunkSize = 16;
	static constexpr const size_t ByteChunkSize = 4 * U32ChunkSize;
	static constexpr const size_t BLOCKSIZE = 64;
	static const UINT32 s[BLOCKSIZE];
	
	
	
	inline
	static UINT32 rotl (UINT32 x, UINT32 w)
	{
    return (x << w) | (x >> (32 - w));
  };
	_xMD5Implement(void);	//just initialize
	
	UINT32 m_K[BLOCKSIZE];
	
	UINT32 a, b, c, d;
	
	void DigestChunk(const UINT32 *mblock);
	
	string GetHexString(void) const;
  
};

const UINT32 _xMD5Implement::s[]
{
	7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
	5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
	4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
	6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
};

string _xMD5Implement::GetHexString(void) const
{

	char dimBuf[33];
	char *pidx = dimBuf;
	
	UINT32 byte_mask = 0xff, nib_mask = 0xf;
	
	UINT32 _a = a, _b = b, _c = c, _d = d;
	
	BYTE bt = (BYTE) (_a & byte_mask);


	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_a >>= 8;
	bt = (BYTE) (_a & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_a >>= 8;
	bt = (BYTE) (_a & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_a >>= 8;
	bt = (BYTE) (_a & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	
	bt = (BYTE) (_b & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_b >>= 8;
	bt = (BYTE) (_b & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_b >>= 8;
	bt = (BYTE) (_b & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_b >>= 8;
	bt = (BYTE) (_b & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	
	bt = (BYTE) (_c & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_c >>= 8;
	bt = (BYTE) (_c & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_c >>= 8;
	bt = (BYTE) (_c & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_c >>= 8;
	bt = (BYTE) (_c & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	
	bt = (BYTE) (_d & byte_mask);
	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_d >>= 8;
	bt = (BYTE) (_d & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_d >>= 8;
	bt = (BYTE) (_d & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	_d >>= 8;
	bt = (BYTE) (_d & byte_mask);

	*pidx++ = Nib2Char(bt >> 4);
	*pidx++ = Nib2Char(bt & nib_mask);
	
	*pidx = '\0';
	return string(dimBuf);
}

_xMD5Implement::_xMD5Implement(void):
	m_K
	{
		0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
		0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
		0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
		0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
		0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
		0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
		0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
		0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
		0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
		0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
		0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
		0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
		0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
		0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
		0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
		0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
	},
	a{0x67452301},
	b{0xefcdab89},
	c{0x98badcfe},
	d{0x10325476}
	
{}

void _xMD5Implement::DigestChunk(const UINT32 *mblock)
{

	UINT32 A = a, B = b, C = c, D = d;
	UINT32 F = 0, g = 0;
	
	for (size_t i = 0; i < 16; ++i)
	{
		F = (B & C) | ((~B) & D);
		g = i;
		
		F = F + A + m_K[i] + mblock[g];
    A = D;
    D = C;
    C = B;
    B = B + _xMD5Implement::rotl(F, _xMD5Implement::s[i]);
	}
	
	for (size_t i = 16; i < 32; ++i)
	{
		F = (D & B) | ((~D) & C);
		g = (5 * i + 1) % 16;
		
		F = F + A + m_K[i] + mblock[g];
    A = D;
    D = C;
    C = B;
    B = B + _xMD5Implement::rotl(F, _xMD5Implement::s[i]);
	}
	
	for (size_t i = 32; i < 48; ++i)
	{
		F = B ^ C ^ D;
		g = (3 * i + 5) % 16;
		
		F = F + A + m_K[i] + mblock[g];
    A = D;
    D = C;
    C = B;
    B = B + _xMD5Implement::rotl(F, _xMD5Implement::s[i]);
	}
	
	for (size_t i = 48; i < 64; ++i)
	{
		F = C ^ (B | (~D));
		g = (7 * i) % 16;
		
		F = F + A + m_K[i] + mblock[g];
    A = D;
    D = C;
    C = B;
    B = B + _xMD5Implement::rotl(F, _xMD5Implement::s[i]);
	}
	
	a += A;
	b += B;
	c += C;
	d += D;
}


string MD5Digest(const void* bytes, UINT64 n)
{
	UINT64 ori_total_bits = n << 3;
	
	UINT32 msg_chunk[_xMD5Implement::U32ChunkSize];
	
	_xMD5Implement md5dev;

	UINT64 chars_left = n;
	const BYTE * psrc = (const BYTE*)bytes;
	
	while (chars_left >= _xMD5Implement::ByteChunkSize)
	{
		//memset(msg_chunk, 0, _xMD5Implement::U32ChunkSize * sizeof(UINT32));
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize; ++i)
		{
			msg_chunk[i] = (UINT32)(*psrc++);
			msg_chunk[i] |= (UINT32)(*psrc++) << 8;
			msg_chunk[i] |= (UINT32)(*psrc++) << 16;
			msg_chunk[i] |= (UINT32)(*psrc++) << 24;
		}
		
		md5dev.DigestChunk(msg_chunk);
		chars_left -= _xMD5Implement::ByteChunkSize;
	}
	
	BYTE patch[_xMD5Implement::ByteChunkSize];
	memset(patch, 0, _xMD5Implement::ByteChunkSize);
	
	if (chars_left > 0)
		memcpy(patch, psrc, chars_left);
	
	BYTE *pp = patch + chars_left;
	*pp = 128;
	pp = patch;
	if (chars_left >= _xMD5Implement::ByteChunkSize - 8)	//not enough space for patching, must add additional chunk
	{
		//memset(msg_chunk, 0, _xMD5Implement::U32ChunkSize * sizeof(UINT32));
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize; ++i)
		{
			msg_chunk[i] = (UINT32)(*pp++);
			msg_chunk[i] |= (UINT32)(*pp++) << 8;
			msg_chunk[i] |= (UINT32)(*pp++) << 16;
			msg_chunk[i] |= (UINT32)(*pp++) << 24;
		}
		
		md5dev.DigestChunk(msg_chunk);
		
		// -- next chunk will all be 0 except last 8 bytes
		memset(msg_chunk, 0, (_xMD5Implement::U32ChunkSize - 2) * sizeof(UINT32));
	}
	else	//finish in this 
	{
		//memset(msg_chunk, 0, _xMD5Implement::U32ChunkSize * sizeof(UINT32));
		
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize - 2; ++i)
		{
			msg_chunk[i] = (UINT32)(*pp++);
			msg_chunk[i] |= (UINT32)(*pp++) << 8;
			msg_chunk[i] |= (UINT32)(*pp++) << 16;
			msg_chunk[i] |= (UINT32)(*pp++) << 24;
		}
	}
	// -- all little endian, but switch the hi-32 bit and lo 32bit
	msg_chunk[_xMD5Implement::U32ChunkSize - 2] = ori_total_bits & 0xffffffff;
	msg_chunk[_xMD5Implement::U32ChunkSize - 1] = ori_total_bits >> 32;
	md5dev.DigestChunk(msg_chunk);
	
	return md5dev.GetHexString();
	
}

string MD5Digest(const string & msg)
{
	return MD5Digest(msg.data(), msg.size());
}

// -- unknown size at first
// -- istr must open as binary
string MD5Digest(istream &istr)
{
	if (!istr.good())
		THROW_SIMPLE("Input stream error: Cannot read");
		
	UINT64 total_bytes = 0;
	BYTE byte_buf[_xMD5Implement::ByteChunkSize];
	UINT32 msg_chunk[_xMD5Implement::U32ChunkSize];
	_xMD5Implement md5dev;
	
	istr.read(reinterpret_cast< char * > (byte_buf), _xMD5Implement::ByteChunkSize);
	
	// -- read full _xMD5Implement::ByteChunkSize bytes as expected
	while (istr.good())
	{
		//memset(msg_chunk, 0, _xMD5Implement::U32ChunkSize * sizeof(UINT32));
		const BYTE *psrc = byte_buf;
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize; ++i)
		{
			msg_chunk[i] = (UINT32)(*psrc++);
			msg_chunk[i] |= (UINT32)(*psrc++) << 8;
			msg_chunk[i] |= (UINT32)(*psrc++) << 16;
			msg_chunk[i] |= (UINT32)(*psrc++) << 24;
		}
		md5dev.DigestChunk(msg_chunk);
		total_bytes += _xMD5Implement::ByteChunkSize;
		istr.read(reinterpret_cast< char * > (byte_buf), _xMD5Implement::ByteChunkSize);
	}
	
	UINT64 last_read_bcount = istr.gcount();
	total_bytes = (total_bytes + last_read_bcount) << 3;	//turn to total bits
	
	BYTE *pp = byte_buf + last_read_bcount;
	// -- reset the rest buffer
	memset(byte_buf + last_read_bcount, 0, _xMD5Implement::ByteChunkSize - last_read_bcount);
	*pp = 128;	//append 1
	pp = byte_buf;
	if (last_read_bcount >= _xMD5Implement::ByteChunkSize - 8)	// not enough space for patching. must 
	{
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize; ++i)
		{
			msg_chunk[i] = (UINT32)(*pp++);
			msg_chunk[i] |= (UINT32)(*pp++) << 8;
			msg_chunk[i] |= (UINT32)(*pp++) << 16;
			msg_chunk[i] |= (UINT32)(*pp++) << 24;
		}
		md5dev.DigestChunk(msg_chunk);	//handle this chunk
		
		// -- prepare for next (the last) chunk: all UNIT32 but the last two must be 0
		// -- the last two are for total bit length
		memset(msg_chunk, 0, (_xMD5Implement::U32ChunkSize - 2) * sizeof(UINT32));
	}
	else	//there is enough space for patching
	{
		// -- fill all UNIT32 but the last two
		for (size_t i = 0; i < _xMD5Implement::U32ChunkSize - 2; ++i)
		{
			msg_chunk[i] = (UINT32)(*pp++);
			msg_chunk[i] |= (UINT32)(*pp++) << 8;
			msg_chunk[i] |= (UINT32)(*pp++) << 16;
			msg_chunk[i] |= (UINT32)(*pp++) << 24;
		}
	}
	
	// -- all little endian, but switch the hi-32 bit and lo 32bit
	msg_chunk[_xMD5Implement::U32ChunkSize - 2] = total_bytes & 0xffffffff;
	msg_chunk[_xMD5Implement::U32ChunkSize - 1] = total_bytes >> 32;
	md5dev.DigestChunk(msg_chunk);
	
	return md5dev.GetHexString();
	

}

inline
unsigned int helpsrand(void) noexcept
{
	unsigned int rs = time(0);
	srand(rs);
	return rs;
}

int GetRandInt(int max)
{
	static unsigned int rs = helpsrand();
	
	int r = rand();
	if (max < RAND_MAX)
		r %= (max + 1);
	return r;
}

string GetRandomString(void)
{
	int rn = GetRandInt();
	return MD5Digest(&rn, sizeof(int));
}

bool AlphaBool(const string& rEntryValue, bool bDefault)
{
	string lit = rEntryValue;
	StrToUpper(lit);
	if ("FALSE" == lit || "F" == lit) return false;
	if ("TRUE" == lit|| "T" == lit) return true;
	return bDefault;
}

