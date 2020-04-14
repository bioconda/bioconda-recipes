#if !defined(__STD_STOMIC__)
#define __STD_STOMIC__

#include <atomic>
#include "normbase.hpp"

//std::atomic guarantees whatever alignment is necessary
typedef INT64 TAtomicCounterValueType;
typedef std::atomic<TAtomicCounterValueType> TAtomicCounterType;
	




#endif
