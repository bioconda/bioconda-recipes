#if !defined(__ENUM_LIT__)
#define __ENUM_LIT__
#include <string>

typedef size_t TENUMIDX;

/*****************************************************
Enumerated const char * values

// -- declare
struct TMyLits
{
	enum EIndex: TENUMIDX
	{
		eEnumStart = 0,
		e_name1 = eEnumStart,
		e_name2 = e_name1 + 1,
		...
		//
		eEnumStop = e_namen + 1
	};
	
	static const EIndex eDefault = e_name1;
	static const char* dimLits[eEnumStop - eEnumStart];
	static const char* dimDisplay[eEnumStop - eEnumStart];
};


// -- define
const char* TMyLits::dimLits[] = {"name1", "name2", ...};
const char* TMyLits::dimDisplay[] = {"Name 1", "Name 2", ...};
******************************************************/
template<typename EnumLitType>
const char* GetDefaultLit(void)
{
	return EnumLitType::dimLits[EnumLitType::eDefault - EnumLitType::eEnumStart];
}

template<typename EnumLitType>
const char* GetDefaultVal(void)
{
	return EnumLitType::eDefault;
}

template<typename EnumLitType>
const char* GetLit(TENUMIDX iIdx)
{
	if (iIdx < EnumLitType::eEnumStart || iIdx >= EnumLitType::eEnumStop) return EnumLitType::dimLits[EnumLitType::eDefault - EnumLitType::eEnumStart];
	else return EnumLitType::dimLits[iIdx - EnumLitType::eEnumStart];
}

template<typename EnumLitType>
const char* GetLit2(TENUMIDX iIdx)
{
	if (iIdx < EnumLitType::eEnumStart || iIdx >= EnumLitType::eEnumStop) return nullptr;
	else return EnumLitType::dimLits[iIdx - EnumLitType::eEnumStart];
}

template<typename EnumLitType>
const char* GetDisplay(TENUMIDX iIdx)
{
	if (iIdx < EnumLitType::eEnumStart || iIdx >= EnumLitType::eEnumStop) return EnumLitType::dimLits[EnumLitType::eDefault - EnumLitType::eEnumStart];
	else return EnumLitType::dimDisplay[iIdx - EnumLitType::eEnumStart];
}

template<typename EnumLitType>
const char* GetDisplay2(TENUMIDX iIdx)
{
	if (iIdx < EnumLitType::eEnumStart || iIdx >= EnumLitType::eEnumStop) return nullptr;
	else return EnumLitType::dimDisplay[iIdx - EnumLitType::eEnumStart];
}

// -- return eDefault if not found
template<typename EnumLitType>
TENUMIDX GetIdx(const std::string& strLit)
{
	for (TENUMIDX i = EnumLitType::eEnumStart; i < EnumLitType::eEnumStop; ++i)
	{
		if (strLit == EnumLitType::dimLits[i - EnumLitType::eEnumStart]) return i;
	}
	return EnumLitType::eDefault;
}

// -- return eEnumStop (invalid) if not found
template<typename EnumLitType>
TENUMIDX GetIdx2(const std::string& strLit)
{
	for (TENUMIDX i = EnumLitType::eEnumStart; i < EnumLitType::eEnumStop; ++i)
	{
		if (strLit == EnumLitType::dimLits[i - EnumLitType::eEnumStart]) return i;
	}
	return EnumLitType::eEnumStop;
}

#endif
