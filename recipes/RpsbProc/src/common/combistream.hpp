#if !defined(__COMB_STREAM__)
#define __COMB_STREAM__

/********************************************************************
*	A streambuf drivative that combines multiple input files together. 
*********************************************************************/
#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <list>

class CCombFileBuf: public std::streambuf
{
public:
	typedef std::list<std::string> FileList;
	static constexpr const size_t DEFBUFSIZE = 4096;
	static constexpr const size_t PUTBACKSIZE = 16;
	CCombFileBuf(size_t bsize = DEFBUFSIZE, size_t pbsize = PUTBACKSIZE);
	virtual ~CCombFileBuf(void);
	void AppendFile(const std::string &path);
	size_t NLeft(void) const {return m_files.size();}
	std::istream * OpenStream(std::ios_base::openmode mode = std::ios_base::binary);	//only binary accepted
	const FileList & GetFiles(void) const {return m_files;}
	
	// -- close stream, reset all buffer pointers and discard all left files: ready to accept 
	void Reset(void);
private:
	virtual std::streambuf::int_type underflow(void) override;
	virtual std::streambuf::int_type pbackfail(std::streambuf::int_type c = std::streambuf::traits_type::eof()) override;
	std::streambuf::char_type *m_buffer, *m_bufend;
	size_t m_backsize;
	size_t m_effpbsize;	//depends on how many actually read
	FileList m_files;
	std::ifstream m_currIstream;
	std::istream *m_istream;
	std::ios_base::openmode m_mode;
};





#endif
