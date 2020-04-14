#if !defined(__PROSITE__)
#define __PROSITE__

#include <string>
#include <vector>


class CProSite
{
public:
	enum EParseError
	{
		eNoError,
		eInvalidChar,
		eSyntaxError,
		eUnexpectedEnd
	};

	struct TMatched
	{
		size_t start, end;
		TMatched(size_t s = std::string::npos, size_t e = std::string::npos): start(s), end(e) {};
	};
	CProSite(void):m_vecCompiledPattern() {};
	EParseError Parse(const std::string &expr, size_t &errorPos);
	size_t Match(const std::string &text, size_t tlen, size_t start_pos) const;
	void Search(const std::string &text, std::vector<TMatched> &result) const;
	
	// -- return a vector of minimal match length, with 'X' as generic, 'A' as alternative and S as strict.
	void GetMinimalXMap(std::string &minMap) const;
	void DebugPrint(void) const;
	
private:
	struct TPatternPos
	{
		static const unsigned int NEGATIVE_FILTER = 0x1;
		static const unsigned int LAZY_MATCH = 0x2;
		unsigned int m_uiFlags;	//positive or negative select
		std::string m_strAltChars;
		size_t m_ulMinCount, m_ulMaxCount;
		size_t (TPatternPos::*m_pfnMatch)(const std::string &text, size_t tlen, size_t pos) const;
		
		TPatternPos(void);
		//return <0 as match fail. return 0 as "just match" without flex. return >0 as how many flex positions
		int Match(const std::string &text, size_t tlen, std::vector<size_t> &rMatchRec, size_t start_pos = std::string::npos) const;
		size_t x_NegMatch(const std::string &text, size_t tlen, size_t pos) const;
		size_t x_PosMatch(const std::string &text, size_t tlen, size_t pos) const;
			
		void x_NormalizeAltChars(void);
	};
	


	struct x_TMatchRec
	{
		std::vector<size_t> flex;
		std::vector<TPatternPos> :: const_iterator iterPos;
		
		x_TMatchRec(std::vector<TPatternPos> :: const_iterator p): flex(), iterPos(p) {};
	};
	
	std::vector<TPatternPos> m_vecCompiledPattern;
	
};

#endif
