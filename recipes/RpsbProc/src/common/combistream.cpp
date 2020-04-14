#include <ncbi_pch.hpp>
#include "combistream.hpp"
#include <cstring>
using namespace std;

CCombFileBuf::CCombFileBuf(size_t bsize, size_t pbsize):
	m_buffer(new streambuf::char_type[bsize]),
	m_bufend(m_buffer + bsize),
	m_backsize(pbsize),
	m_effpbsize(0),
	m_files(),
	m_currIstream(),
	m_istream(nullptr),
	m_mode(ios::in | ios::binary)
{}

CCombFileBuf::~CCombFileBuf(void)
{
	delete []m_buffer;
	delete m_istream;
}

void CCombFileBuf::AppendFile(const string &path)
{
	if (!path.empty()) m_files.emplace_back(path);
}

istream * CCombFileBuf::OpenStream(ios::openmode mode)
{
	m_mode = ((mode & ios::binary) | ios::in);
	if (nullptr == m_istream)
	{
		m_istream = new istream(this);
		setg(m_buffer, m_buffer, m_buffer);
	}

	return m_istream;
}

streambuf::int_type CCombFileBuf::underflow(void)
{
	streambuf::char_type *_gptr = gptr();


	if (_gptr < egptr())
		return streambuf::traits_type::to_int_type(*_gptr);
			
	streambuf::char_type *_new_bufend = m_buffer + m_effpbsize;
	_gptr = _new_bufend;
	

	while (!m_files.empty())
	{
		if (!m_currIstream.is_open())	//previously read
		{
			m_currIstream.open(m_files.front().c_str(), m_mode);
		}
		if (m_currIstream.good())
		{

			m_currIstream.read(_new_bufend, (m_bufend - _new_bufend) * sizeof(streambuf::char_type));

			if (m_currIstream.good())	//complete read 
			{
				// -- set _new_bufend as the end -- if incomplete read after all, _new_bufend will be the position after the last char
				_new_bufend = m_bufend;
				break;
			}

			// -- read failed. go to next file
			_new_bufend += m_currIstream.gcount();

		}

		m_currIstream.close();
		m_files.pop_front();
	}
	
	// -- calculate next effective putback size
	m_effpbsize = _new_bufend - _gptr;
	if (m_effpbsize > m_backsize) m_effpbsize = m_backsize;


	// -- here, just check if ok. 
	if (_gptr < _new_bufend)
	{
		setg(m_buffer, _gptr, _new_bufend);	//_new_bufend play as the buffer end
		return streambuf::traits_type::to_int_type(*_gptr);
	}
	else
		return streambuf::traits_type::eof();
	
}


streambuf::int_type CCombFileBuf::pbackfail(streambuf::int_type c)
{
	streambuf::char_type * _gptr = gptr();

	if (_gptr > m_buffer)
	{
		--_gptr;
		*_gptr = (streambuf::char_type)c;
		setg(m_buffer, _gptr, egptr());
		return c;
	}

	return streambuf::traits_type::eof();
	
}

void CCombFileBuf::Reset(void)
{
	delete m_istream;
	m_istream = nullptr;
	if (m_currIstream.is_open())	//previously read
		m_currIstream.close();
	m_files.clear();
	memset(m_buffer, 0, m_bufend - m_buffer);
	m_effpbsize = 0;
}
