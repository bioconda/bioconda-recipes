#if !defined(__NORM_BASE__)
#define __NORM_BASE__

#include <exception>
#include <iostream>
#include <string>
#include <sstream>
/**********************************************************************
*	Some basic numeric definitions
**********************************************************************/
constexpr const long double PI = 3.1415926535898L;
//constexpr const double k_dDec2RadFact = ((double)2.0) * PI / (double)360;
//constexpr const unsigned int k_uiUnsignedLimit = ~(unsigned int)0;
//constexpr const int k_iIntUpperLimit = (int)(k_uiUnsignedLimit >> 1);
//constexpr const int k_iIntLowerLimit = - k_iIntUpperLimit - 1;
//constexpr const size_t k_sztUpperLimit = ~(size_t)0;

constexpr const double k_RAD_PER_DEG = ((double)2.0) * PI / (double)360;
constexpr const unsigned int k_UINT_MAX = ~(unsigned int)0;
constexpr const int k_INT_MAX = (int)(k_UINT_MAX >> 1);
constexpr const int k_INT_MIN = - k_INT_MAX - 1;
constexpr const size_t k_SIZE_MAX = ~(size_t)0;


#define BoolAlpha(a) (a ? "true" : "false")

/**********************************************************************
*	Detect and define fixed-width types
**********************************************************************/
typedef unsigned char BYTE;	//assume 8 

// -- take sizeof(short), sizeof(int) sizeof(long)
template<size_t, size_t, size_t>
struct TWordSizeDef;

template<>
struct TWordSizeDef<1, 2, 2>
{
	typedef int INT16;
	typedef long long INT32;
	typedef long long INT64;	//no way doing 64 bit, just define the same as 32bit
	typedef unsigned int UINT16;
	typedef unsigned long long UINT32;
	typedef unsigned long long UINT64;
};

template<>
struct TWordSizeDef<1, 2, 4>
{
	typedef int INT16;
	typedef long INT32;
	typedef long long INT64;
	typedef unsigned int UINT16;
	typedef unsigned long UINT32;
	typedef unsigned long long UINT64;
};

template<>
struct TWordSizeDef<2, 2, 4>
{
	typedef int INT16;
	typedef long INT32;
	typedef long long INT64;
	typedef unsigned int UINT16;
	typedef unsigned long UINT32;
	typedef unsigned long long UINT64;
};

template<>
struct TWordSizeDef<2, 4, 4>
{
	typedef short INT16;
	typedef int INT32;
	typedef long long INT64;
	typedef unsigned short UINT16;
	typedef unsigned int UINT32;
	typedef unsigned long long UINT64;
};

template<>
struct TWordSizeDef<2, 4, 8>
{
	typedef short INT16;
	typedef int INT32;
	typedef long INT64;
	typedef unsigned short UINT16;
	typedef unsigned int UINT32;
	typedef unsigned long UINT64;
};

typedef TWordSizeDef<sizeof(short), sizeof(int), sizeof(long)> TMachineWords;

typedef TMachineWords :: INT16 INT16;
typedef TMachineWords :: INT32 INT32;
typedef TMachineWords :: UINT16 UINT16;
typedef TMachineWords :: UINT32 UINT32;
typedef TMachineWords :: INT64 INT64;
typedef TMachineWords :: UINT64 UINT64;


/**********************************************************************
*	Empty string reference
**********************************************************************/
const std::string & GetEmptyString(void);
#define k_strEmptyString GetEmptyString()
//extern const std::string k_strEmptyString;
const std::wstring & GetEmptyWString(void);
#define k_strEmptyWString GetEmptyWString()

/**********************************************************************
*	Define exception class
class exception
{
public:
  exception () noexcept;
  exception (const exception&) noexcept;
  exception& operator= (const exception&) noexcept;
  virtual ~exception();
  virtual const char* what() const noexcept;
};

usage:
	throw CSimpleException(__FILE__, __LINE__, "Parse error!");
**********************************************************************/

class CSimpleException: public std::exception
{
public:
	CSimpleException(const std::string &f, int l, const std::string &m) noexcept;
	CSimpleException(const std::string &f, int l, std::string &&m) noexcept;
	CSimpleException(const std::string &f, int l, const std::stringstream &ss) noexcept;
	void Print(std::ostream &os) const noexcept;
	virtual const char* what() const noexcept;
	const std::string & GetMessage(void) const {return m_msg;}
	const std::string & GetFile(void) const {return m_file;}
	const int GetLine(void) const {return m_line;}
private:
	std::string m_msg;
	std::string m_file;	//__FILE__
	int m_line;	//__LINE__
};

std::ostream & operator << (std::ostream &os, const CSimpleException &e);

#define THROW_SIMPLE(a) throw CSimpleException(__FILE__, __LINE__, dynamic_cast<const stringstream& > (stringstream() << a))


#endif



