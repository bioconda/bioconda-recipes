#include <ncbi_pch.hpp>
#include "prosite.hpp"
#include <stack>
#include <string>
#include <iostream>

using namespace std;

static const std::string kPlainEmptyString;

CProSite::TPatternPos::TPatternPos(void):
	m_uiFlags(0), m_strAltChars(kPlainEmptyString), m_ulMinCount(1), m_ulMaxCount(1), m_pfnMatch(&TPatternPos::x_PosMatch)
{};



void CProSite::Search(const std::string &text, vector<CProSite::TMatched> &result) const
{
	result.clear();
	size_t tlen = text.size();
	for (size_t i = 0; i < tlen; ++i)
	{
		size_t mpos = Match(text, tlen, i);
		if (string::npos != mpos)	//success
			result.push_back(TMatched(i, mpos));
	}
}

void CProSite::DebugPrint(void) const
{
	cout << "Total positions: " << m_vecCompiledPattern.size() << " =====================================================================" << endl;
	for (vector<TPatternPos> :: const_iterator iter = m_vecCompiledPattern.begin(); iter != m_vecCompiledPattern.end(); ++iter)
	{
		size_t totalAlts = iter->m_strAltChars.size();
		
		cout << "Filter mode: " << ((iter->m_uiFlags & TPatternPos::NEGATIVE_FILTER) ? "negative" : "positive") << ", Match mode: " << ((iter->m_uiFlags & TPatternPos::LAZY_MATCH) ? "lazy" : "aggresive") << ", minimal count: " << iter->m_ulMinCount << ", maximal count: " << iter->m_ulMaxCount << ", Total alternatives: " << totalAlts << ": ";
		char sep[2] = {0, 0};
		for (size_t i = 0; i < totalAlts; ++i)
		{
			cout << sep << '\'' << iter->m_strAltChars[i] << '\'';
			sep[0] = ',';
		}
		cout << endl;
	}
	cout << "=======================================================================================================" << endl;
}

 
CProSite::EParseError CProSite::Parse(const string &expr, size_t &errorPos)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": expr = " << expr << endl;
#endif
// ***********************************************************/

	if (expr.empty()) return eUnexpectedEnd;
	
	enum __EParserStatus
	{
		eParserReady = 0,
		ePlainText,	//collecting plain text
		eAlternates,	//in [] collecting alternative
		eAltRedund,
		eNegations,	//in {} collecting alternative
		eNegRedund,
		eRepeats,	//in () collecting repeats
		eRange	//only valid for X, in (a,b) collecting 
	} status = eParserReady;
	
	EParseError eErrorType = eNoError;	

	
	string::const_iterator iterChar = expr.begin(), iterCharEnd = expr.end();
	
	m_vecCompiledPattern.clear();
	TPatternPos __dummy;
	vector<TPatternPos> :: iterator iterCurr = m_vecCompiledPattern.end();
	
	string lit(kPlainEmptyString);
	bool bEscaped = false;	//if '\' is detected
	bool bInfLit = false;
	
	while (iterCharEnd != iterChar)
	{
		char c = *iterChar;
		if ('a' <= c && 'z' >= c) c -= 0x20;	//turn to capital letters
		switch (c)
		{
		case '*':	//stop codon
			if (!bEscaped)	//not escaped, as equivalent to (0, inf)
			{
				switch (status)
				{
				case ePlainText:
					iterCurr->m_ulMinCount = 0;
					iterCurr->m_ulMaxCount = -1;	//the biggest possible
					if (iterCurr->m_strAltChars == "X") iterCurr->m_uiFlags |= TPatternPos::LAZY_MATCH;
					break;
				case eAlternates:	//always treat as a literal * (stop codon)
				case eNegations:
					iterCurr->m_strAltChars.push_back(c);
					break;
				case eRange:	//accepting max
				case eRepeats:
					if (lit.empty() && !bInfLit) 
					{
						bInfLit = true;
						break;
					}
				case eAltRedund:
				case eNegRedund:
					break;
				default:
					eErrorType = eSyntaxError;
					goto labelErrorRet;
				}
				break;
			}
			
		case 'A':
		case 'C':
		case 'D':
		case 'E':
		case 'F':
		case 'G':
		case 'H':
		case 'I':
		case 'K':
		case 'L':
		case 'M':
		case 'N':
		case 'P':
		case 'Q':
		case 'R':
		case 'S':
		case 'T':
		case 'U':	//newly added selenocysteine
		case 'V':
		case 'W':
		case 'Y':
		
			switch (status)
			{
			case eParserReady:	//No current
				status = ePlainText;
			case ePlainText:	//current is valid
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
			case eAlternates:	//single char alternative, assume: iterCurrAltPattern is undefined
			case eNegations:
				iterCurr->m_strAltChars.push_back(c);
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			bEscaped = false;
			break;
		case 'X':	//special: wildcard, no alternates or negates allowed.
			switch (status)
			{
			case eParserReady:	//No current
				status = ePlainText;
			case ePlainText:	//current is valid
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
				iterCurr->m_strAltChars.push_back(c);
				//iterCurr->m_uiFlags |= TPatternPos::LAZY_MATCH;
				break;
			case eAlternates:	//if alternates, and 'X' mean everything canbe accepted.
			case eNegations:
				iterCurr->m_strAltChars.push_back(c);
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			bEscaped = false;
			break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			switch (status)
			{
			case eRepeats:
			case eRange:
				if (!bInfLit)
				{
					lit.push_back(c);
					break;
				}
			
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
				
			case eAltRedund:
			case eNegRedund:
				break;	//ignore it
			}
			bEscaped = false;
			break;
		case '(':
			switch (status)
			{
			case ePlainText:
				status = eRepeats;	//change to repeats. assert(cTargetChar is defined)
				lit.clear();
				break;
			// -- added 02/12/2016 to tolerate redunence in alternations
			case eAlternates:
				status = eAltRedund;
				break;
			case eNegations:
				status = eNegRedund;
				break;
			// -- End added 02/12/2016 
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			break;
		case ')':
			switch (status)
			{
			case eRepeats:	//end of repeat
				if (!lit.empty())	//has input
				{
					iterCurr->m_ulMinCount = iterCurr->m_ulMaxCount = (size_t)atol(lit.c_str());
				}
				else if (bInfLit)
				{
					iterCurr->m_ulMinCount = 0;
					iterCurr->m_ulMaxCount = -1;	//the biggest possible
					if (iterCurr->m_strAltChars == "X") iterCurr->m_uiFlags |= TPatternPos::LAZY_MATCH;	//infinit X will have lazy match
					bInfLit = false;
				}
				else
				{
					eErrorType = eSyntaxError;
					goto labelErrorRet;
				}
				status = ePlainText;

				break;
			case eRange:	//end of range, assume iterGroup already renewed by the ',' token
				if (!lit.empty())	//has input
				{
					iterCurr->m_ulMaxCount = (size_t)atol(lit.c_str());
					// -- check for reversed
					if (iterCurr->m_ulMaxCount < iterCurr->m_ulMinCount)
					{
						iterCurr->m_ulMaxCount ^= iterCurr->m_ulMinCount;
						iterCurr->m_ulMinCount ^= iterCurr->m_ulMaxCount;
						iterCurr->m_ulMaxCount ^= iterCurr->m_ulMinCount;
					}
				}
				else if (bInfLit)
				{
					iterCurr->m_ulMaxCount = -1;
					if (iterCurr->m_strAltChars == "X") iterCurr->m_uiFlags |= TPatternPos::LAZY_MATCH;
					bInfLit = false;
				}
				else
				{
					eErrorType = eSyntaxError;
					goto labelErrorRet;
				}
				status = ePlainText;
				break;
			case eAltRedund:
				status = eAlternates;
				break;
			case eNegRedund:
				status = eNegations;
				break;	//ignore it 
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			};
			break;

		case ',':	//turn repeat into range
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case eRepeats:	//turn repeats into a range spec.
			
				if (!lit.empty())
				{
					iterCurr->m_ulMinCount = (size_t)atol(lit.c_str());
					lit.clear();
					status = eRange;
					break;
				}
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			case eAltRedund:
			case eNegRedund:
				break;
			};
			break;
		case '\\':
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			bEscaped = true;
			break;
			
		case '[':	//start variable set
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case ePlainText:
			case eParserReady:
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
				//iterCurr->m_uiFlags = true;
				status = eAlternates;
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			};
			break;
		case ']':	//end variable set
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case eAlternates:
				if (!iterCurr->m_strAltChars.empty())
				{
					iterCurr->x_NormalizeAltChars();
					status = ePlainText;
					break;
				}
				
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			break;
		case '{':	//negative set
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case ePlainText:	//start of alternative
			case eParserReady:
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
				iterCurr->m_uiFlags |= TPatternPos::NEGATIVE_FILTER;
				iterCurr->m_pfnMatch = &TPatternPos::x_NegMatch;
				status = eNegations;
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			};
			break;
		case '}':	//end negative set
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case eNegations:
				if (!iterCurr->m_strAltChars.empty())
				{
					iterCurr->x_NormalizeAltChars();
					status = ePlainText;
					break;
				}
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			break;
		case '<':	//start anchor
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case eAlternates:
				if (m_vecCompiledPattern.begin() != iterCurr)	//not the first 
				{
					eErrorType = eSyntaxError;
					goto labelErrorRet;
				}
			case eNegations:
				iterCurr->m_strAltChars.push_back(c);
				break;
			case eParserReady:
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
				iterCurr->m_strAltChars.push_back(c);
				status = ePlainText;
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			break;
		case '>':	//end anchor
			if (bEscaped)
			{
				eErrorType = eInvalidChar;
				goto labelErrorRet;
			}
			switch (status)
			{
			case ePlainText:
			case eParserReady:
				iterCurr = m_vecCompiledPattern.emplace(m_vecCompiledPattern.end(), __dummy);
				iterCurr->m_strAltChars.push_back(c);
				status = ePlainText;
				break;
			case eNegations:
				iterCurr->m_strAltChars.push_back(c);
				break;
			default:
				eErrorType = eSyntaxError;
				goto labelErrorRet;
			}
			break;
		case '-':	//ignore
		case ' ':
		case '\t':
			break;
		default:
			eErrorType = eInvalidChar;
			goto labelErrorRet;
		}
		++iterChar;
	}
	
labelErrorRet:
	errorPos = (iterChar - expr.begin());
	return eErrorType;	
}
 
size_t CProSite::Match(const string &text, size_t tlen, size_t start_pos) const
{
	if (start_pos >= tlen) return string::npos;
	stack<x_TMatchRec> stkFlexStack;
	
	x_TMatchRec curr(m_vecCompiledPattern.begin());
	
	vector<TPatternPos> :: const_iterator iterPosEnd = m_vecCompiledPattern.end();
	
	
	while (iterPosEnd != curr.iterPos)
	{
		int matched = curr.iterPos->Match(text, tlen, curr.flex, start_pos);
		if (matched < 0)	//match failed
		{
			if (stkFlexStack.empty()) return string::npos;
			curr = stkFlexStack.top();
			stkFlexStack.pop();
		}
		else	//match success
		{
			if (matched > 0) stkFlexStack.push(curr);
			start_pos = curr.flex.back();
			++curr.iterPos;
			curr.flex.clear();
		}
	}
	
	
	// -- successfully matched all PatternPosition
	return start_pos;	//should always be valid.
	
}
void CProSite::TPatternPos::x_NormalizeAltChars(void)
{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Entering CProSite::TPatternPos::x_NormalizeAltChars(void), m_strAltChars = " << m_strAltChars << endl;
#endif
// ***********************************************************/

	if (!m_strAltChars.empty())
	{
		size_t idx = 0, ttl = m_strAltChars.size();
		vector<size_t> veciidx;
		veciidx.reserve(ttl);
		while (idx < ttl)
		{
			char currc = m_strAltChars[idx];
			if ('X' == currc)	//no matter others, just being the one
			{
				m_strAltChars.clear();
				m_strAltChars.push_back('X');
				break;
			}
			veciidx.clear();
			
			size_t rmv = 0;
			size_t idx2 = idx + 1;
			while (idx2 < ttl)
			{
				if (m_strAltChars[idx2] == currc)
					++rmv;
				else if (rmv > 0)
					m_strAltChars[idx2 - rmv] = m_strAltChars[idx2];
				
				++idx2;
			}
			
			ttl -= rmv;
			m_strAltChars.erase(ttl);	//erase m
			//while (rmv > 0)
			//{
			//	m_strAltChars.pop_back();
			//	--rmv;
			//}
			
			++idx;
		}
	}
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": Leaving CProSite::TPatternPos::x_NormalizeAltChars(void), m_strAltChars = " << m_strAltChars << endl;
#endif
// ***********************************************************/
}
// -- negative position match
size_t CProSite::TPatternPos::x_NegMatch(const string &text, size_t tlen, size_t pos) const
{
	string::const_iterator iterChar = m_strAltChars.begin(), iterCharEnd = m_strAltChars.end();
	size_t adv = 0;
	
	while (iterCharEnd != iterChar)
	{
		switch (*iterChar)
		{
		case '<':	//start anchor
			if (0 == pos)	//matched, fail it
				return string::npos;
			break;
		case '>':	//end anchor
			if (pos == tlen)	//matched
				return string::npos;
			break;
		case 'X':
			if (pos < tlen)
				return string::npos;
			break;
		default:
			if (pos < tlen)
			{
				char c = text[pos];
				adv = 1;
				if ('a' <= c && 'z' >= c) c -= 0x20;
				if (*iterChar == c)	//matched
					return string::npos;
			}
			else
				return string::npos;
		}
		
		++iterChar;
	}
	return adv;	//nothing matched, successful
}
 
// -- positive position match
size_t CProSite::TPatternPos::x_PosMatch(const string &text, size_t tlen, size_t pos) const
{
	string::const_iterator iterChar = m_strAltChars.begin(), iterCharEnd = m_strAltChars.end();
	while (iterCharEnd != iterChar)
	{
		switch (*iterChar)
		{
		case '<':	//start anchor
			if (0 == pos)	//matched
				return 0;
			break;
		case '>':	//end anchor
			if (pos == tlen)	//matched
				return 0;
			break;
		case 'X':	//match any
			if (pos < tlen)	//last, 
				return 1;
			break;
		default:
			if (pos < tlen)
			{
				char c = text[pos];
				if ('a' <= c && 'z' >= c) c -= 0x20;
				if (*iterChar == c)	//matched
					return 1;
			}
		}
		
		++iterChar;
	}
	return string::npos;
}


int CProSite::TPatternPos::Match(const string &text, size_t tlen, vector<size_t> &rMatchRec, size_t start_pos) const
{

	size_t matched = rMatchRec.size();	//assume: at least one [0] as the start position

	int retVal = 0;	//return 0: match success but no more flex, -1: match failed. >1: # of flex left
	if (m_uiFlags & LAZY_MATCH)	//do not clear rMatchRec
	{
		if (0 == matched)	//the first time
		{
			
			rMatchRec.push_back(start_pos);
			
			// -- first, must match to minimal count
			
			while (rMatchRec.size() <= m_ulMinCount)
			{
				size_t adv = (this->*m_pfnMatch)(text, tlen, start_pos);
				
				if (string::npos == adv)	//fail
				{
					return -1;
				}
				start_pos += adv;
				rMatchRec.push_back(start_pos);
			}
			if (m_ulMaxCount > m_ulMinCount) retVal = 1;
			else retVal = 0;
		}
		else if (matched <= m_ulMaxCount)	//still flex	//revisit
		{
			start_pos = rMatchRec[matched - 1];
			size_t adv = (this->*m_pfnMatch)(text, tlen, start_pos);
			if (string::npos == adv)	//successful
				retVal = -1;
			else
			{
				start_pos += adv;
				rMatchRec.push_back(start_pos);
				if (m_ulMaxCount > matched) retVal = 1;
				else retVal = 0;
			}
		}
	}
	else	//aggressive match
	{
		if (0 == matched)	//the first time
		{
			rMatchRec.push_back(start_pos);
			while ((matched = rMatchRec.size()) <= m_ulMaxCount)
			{
				size_t adv = (this->*m_pfnMatch)(text, tlen, start_pos);
				if (string::npos == adv)	//fail
					break;
				start_pos += adv;
				rMatchRec.push_back(start_pos);
			}
		}
		else 
		{
			rMatchRec.pop_back();
			matched = rMatchRec.size();
		}
		if (matched < m_ulMinCount + 1) retVal = -1;	// minimal match not reached
		else if (matched > m_ulMinCount + 1) retVal = 1;	//with flex
		else retVal = 0;
	}
	return retVal;
}

void CProSite::GetMinimalXMap(string &minMap) const
{
	minMap.clear();
	size_t ttl = m_vecCompiledPattern.size();
/*debug*******************************************************
#if defined(_DEBUG)
cerr << "GetMinimalXMap: ttl = " << ttl << endl;
#endif
// ***********************************************************/
	if (ttl > 0)
	{
		minMap.reserve(ttl + ttl);
		for (size_t i = 0; i < ttl; ++i)
		{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << "m_vecCompiledPattern[i].m_ulMinCount = " << m_vecCompiledPattern[i].m_ulMinCount << "m_vecCompiledPattern[i].m_strAltChars = " << m_vecCompiledPattern[i].m_strAltChars << endl;
#endif
// ***********************************************************/
			if (m_vecCompiledPattern[i].m_ulMinCount > 0)
			{
/*debug*******************************************************
#if defined(_DEBUG)
cerr << "m_vecCompiledPattern[i].m_strAltChars.size() = " << m_vecCompiledPattern[i].m_strAltChars.size() << endl;
#endif
// ***********************************************************/
				switch (m_vecCompiledPattern[i].m_strAltChars.size())
				{
				case 0:
					break;
				case 1:
					if ('X' == m_vecCompiledPattern[i].m_strAltChars[0]) minMap.append(m_vecCompiledPattern[i].m_ulMinCount, 'X');
					else if (m_vecCompiledPattern[i].m_uiFlags & TPatternPos::NEGATIVE_FILTER) minMap.append(m_vecCompiledPattern[i].m_ulMinCount, 'A');
					else minMap.append(m_vecCompiledPattern[i].m_ulMinCount, 'S');
					break;
				default:	//>1
					minMap.append(m_vecCompiledPattern[i].m_ulMinCount, 'A');
				}
			}
		}
	}
	
}
