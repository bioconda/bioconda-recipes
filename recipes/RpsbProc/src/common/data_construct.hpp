#if !defined(__DATA_CONSTRUCTION__)
#define __DATA_CONSTRUCTION__

#include <utility>

template<typename __T, typename...  __Args>
inline
void _construct_(__T* _p, __Args&&... args)
{
	::new (static_cast<void*>(_p)) __T(std::forward<__Args>(args)...);
}

template<typename __T>
inline
void _destroy_(__T* _p)
{
	_p->__T::~__T();
}

template<bool>
struct _destroy_call_
{
	template<typename __T>
	static void __call_destructor__(__T *_p)
	{
		_destroy_<__T>(_p);
	};
};

// -- specialize for true: if trivial, do nothing
template<>
struct _destroy_call_<true>
{
	template<typename __T>
	static void __call_destructor__(__T *_p) {};
};



#endif
