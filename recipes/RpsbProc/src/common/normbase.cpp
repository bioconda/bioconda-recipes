#include <ncbi_pch.hpp>
#include "normbase.hpp"
using namespace std;

//const string k_strEmptyString("");
const string & GetEmptyString(void)
{
	static const string EmptyStdString("");
	return EmptyStdString;
}

//const wstring k_strEmptyWString(L"");
const wstring & GetEmptyWString(void)
{
	static const wstring EmptyStdWString(L"");
	return EmptyStdWString;
}


CSimpleException::CSimpleException(const string &f, int l, const string &m) noexcept:
	exception(),
	m_msg(m), m_file(f), m_line(l)
{}

CSimpleException::CSimpleException(const string &f, int l, string &&m) noexcept:
	exception(),
	m_msg(move(m)), m_file(f), m_line(l)
{}

CSimpleException::CSimpleException(const std::string &f, int l, const std::stringstream &ss) noexcept:
	exception(),
	m_msg(ss.str()), m_file(f), m_line(l)
{}

const char* CSimpleException::what() const noexcept
{
	return m_msg.c_str();
}

void CSimpleException::Print(ostream &os) const noexcept
{
	try
	{
		os << m_file << ':' << m_line << "; " << m_msg << endl;
	}
	catch (...)
	{;}
}

ostream & operator << (ostream &os, const CSimpleException &e)
{
	e.Print(os);
	return os;
}
