/******************************************************************************
 *
 * MetaCache - Meta-Genomic Classification Tool
 *
 * Copyright (C) 2016-2019 André Müller (muellan@uni-mainz.de)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *****************************************************************************/

#ifndef MC_HASHES_H_
#define MC_HASHES_H_


#include <stdint.h>
#include <utility>


namespace mc {

/*************************************************************************//**
 *
 * @brief integer hash: 32 bits -> 32 bits
 *        invented by Thomas Mueller:
 *        http://stackoverflow.com/users/382763/thomas-mueller
 *
 *****************************************************************************/
inline uint32_t
thomas_mueller_hash(uint32_t x) noexcept {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x);
    return x;
}

//makes sure we cant't use the wrong types
template<class T> void thomas_mueller_hash(T) = delete;



/*************************************************************************//**
 *
 * @brief integer hash: 32 bits -> 32 bits
 *
 *****************************************************************************/
inline uint32_t
nvidia_hash(uint32_t x) noexcept {
    x = (x + 0x7ed55d16) + (x << 12);
    x = (x ^ 0xc761c23c) ^ (x >> 19);
    x = (x + 0x165667b1) + (x <<  5);
    x = (x + 0xd3a2646c) ^ (x <<  9);
    x = (x + 0xfd7046c5) + (x <<  3);
    x = (x ^ 0xb55a4f09) ^ (x >> 16);
    return x;
}

//makes sure we cant't use the wrong types
template<class T> void nvidia_hash(T) = delete;



/*************************************************************************//**
 *
 * @brief integer hash: 64 bits -> 64 bits
 *
 *****************************************************************************/
inline uint64_t
murmur3_fmix(uint64_t x, uint64_t seed) noexcept {
	x ^= seed; 
    x ^= x >> 33;
    x *= 0xff51afd7ed558ccd;
    x ^= x >> 33;
    x *= 0xc4ceb9fe1a85ec53;
    x ^= x >> 33;
    return x;
}

inline uint32_t
murmur3_fmix(uint32_t x, uint32_t seed) noexcept {
	x ^= seed;
    x ^= x >> 16;
    x *= 0x85ebca6b;
    x ^= x >> 13;
    x *= 0xc2b2ae35;
    x ^= x >> 16;
    return x;
}

//makes sure we cant't use the wrong types
template<class T> void murmur3_fmix(T) = delete;



/*************************************************************************//**
 *
 * @brief integer hash: 64 bits -> 64 bits
 *        based on splitmix64 by Sebastiano Vigna (vigna@acm.org)
 *
 *****************************************************************************/
inline uint64_t
splitmix64_hash(uint64_t x) noexcept
{
    x = (x ^ (x >> 30)) * uint64_t(0xbf58476d1ce4e5b9);
    x = (x ^ (x >> 27)) * uint64_t(0x94d049bb133111eb);
    x = x ^ (x >> 31);
    return x;
}

//makes sure we cant't use the wrong types
template<class T> void splitmix64_hash(T) = delete;



/*************************************************************************//**
 *
 * @brief integer "down" hash: 64 bits -> 32 bits
 *
 *****************************************************************************/
inline uint32_t
halve_size_hash(uint64_t x) noexcept
{
    x = (~x) + (x << 18);
    x = x ^ (x >> 31);
    x = x * 21;
    x = x ^ (x >> 11);
    x = x + (x << 6);
    x = x ^ (x >> 22);
    return uint32_t(x);
}

//makes sure we cant't use the wrong types
template<class T> void halve_size_hash(T) = delete;



/*************************************************************************//**
 *
 * @brief for testing purposes
 *
 *****************************************************************************/
struct identity_hash
{
    template<class T>
    T&& operator () (T&& x) const noexcept {
        return std::forward<T>(x);
    }
};



/*************************************************************************//**
 *
 * @brief same number of output bits as input bits
 *
 *****************************************************************************/
template<class T>
struct same_size_hash;

template<>
struct same_size_hash<uint32_t> {
    uint32_t operator () (uint32_t x) const noexcept {
        return thomas_mueller_hash(x);
    }
};

template<>
struct same_size_hash<uint64_t> {
    uint64_t operator () (uint64_t x, uint64_t seed) const noexcept {
        return murmur3_fmix(x, seed);
    }
};



/*************************************************************************//**
 *
 * @brief output is 32 bits
 *
 *****************************************************************************/
template<class T>
struct to32bits_hash;

template<>
struct to32bits_hash<uint32_t> {
    uint32_t operator () (uint32_t x) const noexcept {
        return thomas_mueller_hash(x);
    }
};

template<>
struct to32bits_hash<uint64_t> {
    uint32_t operator () (uint64_t x, uint64_t seed) const noexcept {
        return halve_size_hash(murmur3_fmix(x, seed));
    }
};


} // namespace mc


#endif
