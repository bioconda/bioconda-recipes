/*
 * arbitrary-precision integer library
 * very limited: only does what minia needs (but not what minia deserves)
 */

#ifndef LargeInt_h
#define LargeInt_h

#include <stdint.h>
#include <algorithm>

template<int precision>
class LargeInt 
{

    public:
    uint64_t array[precision];
    LargeInt(const uint64_t &);
    LargeInt();

    // overloading
    LargeInt operator+(const LargeInt &) const;
    LargeInt operator-(const LargeInt &) const;
    LargeInt operator*(const int &) const;
    LargeInt operator/(const uint32_t &) const;
    uint32_t operator%(const uint32_t &) const;
    LargeInt operator^(const LargeInt &) const;
    LargeInt operator&(const LargeInt &) const;
    LargeInt operator~() const;
    LargeInt operator<<(const int &) const;
    LargeInt operator>>(const int &) const;
    bool     operator!=(const LargeInt &) const;
    bool     operator==(const LargeInt &) const;
    bool     operator<(const LargeInt &) const;
    bool     operator<=(const LargeInt &) const;

    // custom
    uint64_t toInt() const;
    #ifdef _LP64
    __uint128_t toInt128() const;
    #endif


// c++ fun fact:
// "const" will ban the function from being anything which can attempt to alter any member variables in the object.
};

#endif
