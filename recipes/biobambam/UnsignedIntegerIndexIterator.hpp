/*
    libmaus2
    Copyright (C) 2009-2015 German Tischler
    Copyright (C) 2011-2015 Genome Research Limited

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#if ! defined(LIBMAUS2_UTIL_UNSIGNEDINTEGERINDEXITERATOR_HPP)
#define LIBMAUS2_UTIL_UNSIGNEDINTEGERINDEXITERATOR_HPP

#include <libmaus2/math/UnsignedInteger.hpp>
#include <iterator>
#include <cstdint>

namespace libmaus2
{
	namespace util
	{
		/*
		 * Random-access index iterator over an owner that exposes get(index_type).
		 *
		 * NOTE (compatibility fix): difference_type MUST be a signed integral type.
		 * It was previously libmaus2::math::UnsignedInteger<k>, which is neither
		 * signed nor integral. Modern libc++ (Xcode/clang 15+) and libstdc++ (C++17/20)
		 * refuse to treat such a type as an iterator: C++20 std::iterator_traits then
		 * synthesises no iterator_category, the constrained std::advance overload is
		 * discarded, and std::lower_bound fails with "no matching function for call to
		 * 'advance'". Using int64_t here restores conformance. The internal index i
		 * stays an UnsignedInteger<k>; only the iterator's public arithmetic surface
		 * is integral.
		 */
		template<typename _owner_type, typename _data_type, size_t _k>
		struct UnsignedIntegerIndexIterator
		{
			typedef _owner_type owner_type;
			typedef _data_type data_type;
			static size_t const k = _k;
			typedef UnsignedIntegerIndexIterator<owner_type,data_type,k> this_type;

			typedef libmaus2::math::UnsignedInteger<k> index_type;

			// conforming iterator_traits typedefs (no deprecated std::iterator base)
			typedef ::std::random_access_iterator_tag iterator_category;
			typedef data_type        value_type;
			typedef int64_t          difference_type;   // was index_type; now signed integral
			typedef data_type        reference;         // read-only / by-value proxy iterator
			typedef data_type const *pointer;

			owner_type const * owner;
			index_type i;

			UnsignedIntegerIndexIterator() : owner(0), i(0) {}
			UnsignedIntegerIndexIterator(owner_type const * rowner, int64_t const ri = 0) : owner(rowner), i(static_cast<uint64_t>(ri)) {}
			UnsignedIntegerIndexIterator(owner_type const * rowner, index_type const & ri) : owner(rowner), i(ri) {}
			UnsignedIntegerIndexIterator(UnsignedIntegerIndexIterator const & o) : owner(o.owner), i(o.i) {}

			UnsignedIntegerIndexIterator & operator=(UnsignedIntegerIndexIterator const & o)
			{
				owner = o.owner;
				i = o.i;
				return *this;
			}

			data_type operator*() const
			{
				return owner->get(i);
			}

			data_type operator[](difference_type j) const
			{
				this_type t = *this;
				t += j;
				return owner->get(t.i);
			}

			this_type & operator++()
			{
				i += index_type(1);
				return *this;
			}
			this_type operator++(int)
			{
				this_type temp = *this;
				i += index_type(1);
				return temp;
			}
			this_type & operator--()
			{
				i -= index_type(1);
				return *this;
			}
			this_type operator--(int)
			{
				this_type temp = *this;
				i -= index_type(1);
				return temp;
			}

			// integral-typed arithmetic (this is what std::advance / std::distance require)
			this_type & operator+=(difference_type j)
			{
				if ( j >= 0 )
					i += index_type(static_cast<uint64_t>(j));
				else
					i -= index_type(static_cast<uint64_t>(-j));
				return *this;
			}
			this_type & operator-=(difference_type j)
			{
				return *this += -j;
			}

			// retained UnsignedInteger-typed arithmetic for backward compatibility.
			// (Unambiguous vs. the integral overloads: an integer argument always
			//  prefers the difference_type overload via a standard conversion.)
			this_type & operator+=(index_type const & j)
			{
				i += j;
				return *this;
			}
			this_type & operator-=(index_type const & j)
			{
				i -= j;
				return *this;
			}

			bool operator< (this_type const & I) const { return i < I.i; }
			bool operator> (this_type const & I) const { return I.i < i; }
			bool operator<=(this_type const & I) const { return !(I.i < i); }
			bool operator>=(this_type const & I) const { return !(i < I.i); }
			bool operator==(this_type const & I) const { return (owner==I.owner) && (i == I.i); }
			bool operator!=(this_type const & I) const { return ! ( operator==(I) ); }
		};

		template<typename _owner_type, typename _data_type, size_t _k>
		inline UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> operator+(UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> I, int64_t j)
		{
			I += j;
			return I;
		}

		template<typename _owner_type, typename _data_type, size_t _k>
		inline UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> operator+(int64_t j, UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> I)
		{
			I += j;
			return I;
		}

		template<typename _owner_type, typename _data_type, size_t _k>
		inline UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> operator-(UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> I, int64_t j)
		{
			I -= j;
			return I;
		}

		// retained UnsignedInteger-typed free operators
		template<typename _owner_type, typename _data_type, size_t _k>
		inline UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> operator+(UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> const & I, libmaus2::math::UnsignedInteger<_k> const & j)
		{
			UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> J = I;
			J += j;
			return J;
		}

		template<typename _owner_type, typename _data_type, size_t _k>
		inline UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> operator- ( UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> const & I, libmaus2::math::UnsignedInteger<_k> const & j)
		{
			UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> J = I;
			J -= j;
			return J;
		}

		// iterator difference: MUST return the (signed integral) difference_type.
		// Indices here are array offsets that comfortably fit in 63 bits.
		template<typename _owner_type, typename _data_type, size_t _k>
		inline int64_t operator- ( UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> const & I, UnsignedIntegerIndexIterator<_owner_type,_data_type,_k> const & J )
		{
			bool const neg = ( I.i < J.i );
			libmaus2::math::UnsignedInteger<_k> const d = neg ? (J.i - I.i) : (I.i - J.i);
			uint64_t v = static_cast<uint64_t>(d[0]);
			if ( _k >= 2 )
				v |= (static_cast<uint64_t>(d[1]) << 32);
			int64_t const r = static_cast<int64_t>(v);
			return neg ? -r : r;
		}
	}
}
#endif
