#ifndef ASSERTS
#define NDEBUG // disable asserts; those asserts make sure that with PRECISION == [1 or 2], all is correct 
#endif

// some 64-bit assert macros
#if defined(_LP64) && defined(_largeint)
#define assert128(x) assert(precision != 2 || (x));
#else
#define assert128(x) ;
#endif

#include <assert.h>
#include <stdio.h>
#include "LargeInt.h"

using namespace std;

template<int precision>
LargeInt<precision>::LargeInt()
{
}

template<int precision>
LargeInt<precision>::LargeInt(const uint64_t &c)
{
    array[0] = c;
    for (int i = 1; i < precision; i++)
        array[i] = 0;
}


template<int precision>
LargeInt<precision> LargeInt<precision>::operator+ (const LargeInt<precision>& other) const
{
    LargeInt<precision> result;
    int carry = 0;
    for (int i = 0 ; i < precision ; i++)
    {
            result.array[i] = array[i] + other.array[i] + carry;
            carry = (result.array[i] < array[i]) ? 1 : 0;
    }
    
    assert(precision != 1 || (result == other.array[0] + array[0]));
    assert128(result.toInt128() == other.toInt128() + toInt128());
    return result;
}

template<int precision>
LargeInt<precision> LargeInt<precision>::operator- (const LargeInt<precision>& other) const
{
    LargeInt<precision> result;
    int carry = 0;
    for (int i = 0 ; i < precision ; i++)
    {
            result.array[i] = array[i] - other.array[i] - carry;
            carry = (result.array[i] > array[i]) ? 1 : 0;
    }
    
    assert(precision != 1 || (result == array[0] - other.array[0]));
    assert128(result.toInt128() == toInt128() - other.toInt128());
    return result;
}


template<int precision>
LargeInt<precision> LargeInt<precision>::operator* (const int& coeff) const
{
    LargeInt<precision> result (*this);
    // minia doesn't have that many multiplications cases

    if (coeff == 2 || coeff == 4) 
    {
        result = result << (coeff / 2);
    }
    else
    {
        if (coeff == 21)
        {
            result = (result << 4) + (result << 2) + result;
        }
        else
        {
            printf("unsupported LargeInt multiplication: %d\n",coeff);
            exit(1);
        }
    }

    assert(precision != 1 || (result == array[0] * coeff));
    assert128(result.toInt128() == toInt128() * coeff);
    return result;
}


template<int precision>
LargeInt<precision> LargeInt<precision>::operator/ (const uint32_t& divisor) const
{
    LargeInt<precision> result;
    fill( result.array, result.array + precision, 0 );

    // inspired by Divide32() from http://subversion.assembla.com/svn/pxcode/RakNet/Source/BigInt.cpp 
    
    uint64_t r = 0;
    uint32_t mask32bits = ~0;
    for (int i = precision-1; i >= 0; --i)
    {
        for (int j = 1; j >= 0; --j) // [j=1: high-32 bits, j=0: low-32 bits] of array[i]
        {
            uint64_t n = (r << 32) | ((array[i] >> (32*j)) & mask32bits );
            result.array[i] = result.array[i] | (((n / divisor) & mask32bits) << (32*j));
            r = n % divisor;
        }
    }
    assert(precision != 1 || (result == array[0] / divisor));
    assert128(result.toInt128() == toInt128() / divisor);
    return result;
}


template<int precision>
uint32_t LargeInt<precision>::operator% (const uint32_t& divisor) const
{
    uint64_t r = 0;
    uint32_t mask32bits = ~0;
    for (int i = precision-1; i >= 0; --i)
    {
        for (int j = 1; j >= 0; --j) // [j=1: high-32 bits, j=0: low-32 bits] of array[i]
        {
            uint64_t n = (r << 32) | ((array[i] >> (32*j)) & mask32bits );
            r = n % divisor;
        }
    }

    assert(precision != 1 || (r == array[0] % divisor));
    assert128(r == toInt128() % divisor);
    return (uint32_t)r;
}

template<int precision>
LargeInt<precision> LargeInt<precision>::operator^ (const LargeInt& other) const
{
    LargeInt<precision> result;
    for (int i=0 ; i < precision ; i++)
            result.array[i] = array[i] ^ other.array[i];
    
    assert(precision != 1 || (result == (array[0] ^ other.array[0])));
    assert128(result.toInt128() == (toInt128() ^ other.toInt128()));
    return result;
}

template<int precision>
LargeInt<precision> LargeInt<precision>::operator& (const LargeInt& other) const
{
    LargeInt<precision> result;
    for (int i=0 ; i < precision ; i++)
            result.array[i] = array[i] & other.array[i];
    
    assert(precision != 1 || (result == (array[0] & other.array[0])));
    assert128(result.toInt128() == (toInt128() & other.toInt128()));
    return result;
}


template<int precision>
LargeInt<precision> LargeInt<precision>::operator~ () const
{
    LargeInt<precision> result;
    for (int i=0 ; i < precision ; i++)
            result.array[i] = ~array[i];
    
    assert(precision != 1 || (result == ~array[0]));
    assert128(result.toInt128() == ~toInt128());
    return result;
}

template<int precision>
LargeInt<precision> LargeInt<precision>::operator<< (const int& coeff) const
{
    LargeInt<precision> result (0);

    int large_shift = coeff / 64;
    int small_shift = coeff % 64;
    
    for (int i = large_shift ; i < precision-1; i++)
    {
       result.array[i] = result.array[i] | (array[i-large_shift] << small_shift);
       if (small_shift == 0) // gcc "bug".. uint64_t x; x>>64 == 1<<63, x<<64 == 1
           result.array[i+1] = 0;
       else
           result.array[i+1] = array[i-large_shift] >> (64 - small_shift);

    }
    result.array[precision-1] = result.array[precision-1] | (array[precision-1-large_shift] << small_shift);
    
    assert(precision != 1 || (result == (array[0] << coeff)));
    assert128(result.toInt128() == (toInt128() << coeff));
    return result;
}

template<int precision>
LargeInt<precision> LargeInt<precision>::operator>> (const int& coeff) const
{
    LargeInt<precision> result (0);

    int large_shift = coeff / 64;
    int small_shift = coeff % 64;
    
    result.array[0] = (array[large_shift] >> small_shift);

    for (int i = 1 ; i < precision - large_shift ; i++)
    {
       result.array[i] = (array[i+large_shift] >> small_shift);
       if (small_shift == 0 && large_shift > 0) // gcc "bug".. uint64_t x; x>>64 == 1<<63, x<<64 == 1
       {
           result.array[i-1] =  result.array[i-1];
       }
       else
       {
           result.array[i-1] =  result.array[i-1] | (array[i+large_shift] << (64 - small_shift));
       }
    }

    assert(precision != 1 || ( small_shift == 0 || (result == array[0] >> coeff)));
    assert128(small_shift == 0 || (result.toInt128() == (toInt128() >> coeff)));
    return result;
}

template<int precision>
bool LargeInt<precision>::operator!= (const LargeInt& c) const
{
    for (int i = 0 ; i < precision ; i++)
            if( array[i] != c.array[i] )
                return true;
    return false;
}

template<int precision>
bool LargeInt<precision>::operator== (const LargeInt& c) const
{
    for (int i = 0 ; i < precision ; i++)
            if( array[i] != c.array[i] )
                return false;
    return true;
}

template<int precision>
bool LargeInt<precision>::operator< (const LargeInt& c) const
{
    for (int i = precision-1 ; i>=0 ; --i)
            if( array[i] != c.array[i] )
                return array[i] < c.array[i]; 
    
    return false;
}
 
template<int precision>
bool LargeInt<precision>::operator<=(const LargeInt& c) const
{
    return operator==(c) || operator<(c);
}   

template<int precision>
uint64_t LargeInt<precision>::toInt() const
{ 
    return array[0];
}

#ifdef _LP64
template<int precision>
__uint128_t LargeInt<precision>::toInt128() const
{ 
    return ((__uint128_t)array[0]) + (((__uint128_t)array[1]) << ((__uint128_t)64));
}
#endif

#ifdef KMER_PRECISION
template class LargeInt<KMER_PRECISION>; // since we didn't define the functions in a .h file, that trick removes linker errors, see http://www.parashift.com/c++-faq-lite/separate-template-class-defn-from-decl.html
#endif
