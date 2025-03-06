/***********************************
 *Author: liumy@mail.sdu.edu.cn
 *Date: 12/12/2019
 *Reference: Dashing
 *TODO:
 *optimization:
 *	kmer
 *	hash
 *	clz
 *  K->C
 *  union
 *function:
 *  estimation
 *  distance
 ***********************************/

#ifndef _HYPERLOGLOG_H_
#define _HYPERLOGLOG_H_

#include <array>
#include <climits>
#include <limits>
#include <set>
#include <cmath>
#include <atomic>
#include <random>
#include <vector>
#include <cstring>
#include <thread>
#include <string.h>
#include <cassert>


enum EstimationMethod: uint8_t {
	ORIGINAL       = 0,
	ERTL_IMPROVED  = 1, // Improved but biased method
	ERTL_MLE       = 2  // element-wise max, followed by MLE
};
enum JointEstimationMethod: uint8_t {
	ERTL_JOINT_MLE = 3  // Ertl special version
};


static constexpr double make_alpha(size_t m) {
	switch(m) {
		case 16: return .673;
		case 32: return .697;
		case 64: return .709;
		default: return 0.7213 / (1 + 1.079/m);
	}
}
static constexpr double LARGE_RANGE_CORRECTION_THRESHOLD = (1ull << 32) / 30.;
static constexpr double TWO_POW_32 = 1ull << 32;

static constexpr const char *JESTIM_STRINGS []
{
	"ORIGINAL", "ERTL_IMPROVED", "ERTL_MLE", "ERTL_JOINT_MLE"
};

// Based off https://github.com/oertl/hyperloglog-sketch-estimation-paper/blob/master/c%2B%2B/cardinality_estimation.hpp
template<typename FloatType>
static constexpr FloatType gen_sigma (FloatType x) {
	if(x == 1.) return std::numeric_limits<FloatType>::infinity();
	FloatType z(x);
	for(FloatType zp(0.), y(1.); z != zp;) {
		x *= x; zp = z; z += x * y; y += y;
		if(std::isnan(z)) {
			std::fprintf(stderr, "[W:%s:%d] Reached nan. Returning the last usable number.\n", __FUNCTION__, __LINE__);
			return zp;
		}
	}
	return z;
}

template<typename FloatType>
static constexpr FloatType gen_tau (FloatType x) {
	if (x == 0. || x == 1.) {
		//std::fprintf(stderr, "x is %f\n", (float)x);
		return 0.;
	}
	FloatType z(1-x), tmp(0.), y(1.), zp(x);
	while(zp != z) {
		x = std::sqrt(x);
		zp = z;
		y *= 0.5;
		tmp = (1. - x);
		z -= tmp * tmp * y;
	}
	return z / 3.;
}

#ifndef _CLZ_H_
#define _CLZ_H_

static inline std::uint64_t roundup64(std::size_t x) noexcept {
	--x;
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	x |= x >> 32;
	return ++x;
}

#define clztbl(x, arg) do {\
	switch(arg) {\
		case 0:                         x += 4; break;\
		case 1:                         x += 3; break;\
		case 2: case 3:                 x += 2; break;\
		case 4: case 5: case 6: case 7: x += 1; break;\
	}} while(0)

constexpr inline int clz_manual( std::uint32_t x )
{
	int n(0);
	if ((x & 0xFFFF0000) == 0) {n  = 16; x <<= 16;}
	if ((x & 0xFF000000) == 0) {n +=  8; x <<=  8;}
	if ((x & 0xF0000000) == 0) {n +=  4; x <<=  4;}
	clztbl(n, x >> (32 - 4));
	return n;
}

// Overload
constexpr inline int clz_manual( std::uint64_t x )
{
	int n(0);
	if ((x & 0xFFFFFFFF00000000ull) == 0) {n  = 32; x <<= 32;}
	if ((x & 0xFFFF000000000000ull) == 0) {n += 16; x <<= 16;}
	if ((x & 0xFF00000000000000ull) == 0) {n +=  8; x <<=  8;}
	if ((x & 0xF000000000000000ull) == 0) {n +=  4; x <<=  4;}
	clztbl(n, x >> (64 - 4));
	return n;
}

// clz wrappers. Apparently, __builtin_clzll is undefined for values of 0.
// For our hash function, there is only 1 64-bit integer value which causes this problem.
// I'd expect that this is acceptable. And on Haswell+, this value is the correct value.
#if __GNUC__ || __clang__
#ifdef AVOID_CLZ_UNDEF
constexpr inline unsigned clz(unsigned long long x) {
	return x ? __builtin_clzll(x) : sizeof(x) * CHAR_BIT;
}

constexpr inline unsigned clz(unsigned long x) {
	return x ? __builtin_clzl(x) : sizeof(x) * CHAR_BIT;
}
#else
constexpr inline unsigned clz(unsigned long long x) {
	return __builtin_clzll(x);
}

constexpr inline unsigned clz(unsigned long x) {
	return __builtin_clzl(x);
}
#endif
#else
#pragma message("Using manual clz")
#define clz(x) clz_manual(x)
// https://en.wikipedia.org/wiki/Find_first_set#CLZ
// Modified for constexpr, added 64-bit overload.
#endif

static_assert(clz(0x0000FFFFFFFFFFFFull) == 16, "64-bit clz hand-rolled failed.");
static_assert(clz(0x000000000FFFFFFFull) == 36, "64-bit clz hand-rolled failed.");
static_assert(clz(0x0000000000000FFFull) == 52, "64-bit clz hand-rolled failed.");
static_assert(clz(0x0000000000000000ull) == 64, "64-bit clz hand-rolled failed.");
static_assert(clz(0x0000000000000003ull) == 62, "64-bit clz hand-rolled failed.");
static_assert(clz(0x0000013333000003ull) == 23, "64-bit clz hand-rolled failed.");


#endif //_CLZ_H_






/*
   namespace Sketch {


//	class HyperLogLog{



private:
uint32_t p() const {return np_;}//verification
uint32_t q() const {return (sizeof(uint64_t) * CHAR_BIT) - np_;}
uint64_t m() const {return static_cast<uint64_t>(1) << np_;}
size_t size() const {return size_t(m());}
bool get_is_ready() const {return is_calculated_;}
const auto &core()    const {return core_;}
EstimationMethod get_estim()       const {return  estim_;}
JointEstimationMethod get_jestim() const {return jestim_;}
void set_estim(EstimationMethod val) { estim_ = std::max(val, ERTL_MLE);}
void set_jestim(JointEstimationMethod val) { jestim_ = val;}
void set_jestim(uint16_t val) {set_jestim(static_cast<JointEstimationMethod>(val));}
void set_estim(uint16_t val)  {estim_  = static_cast<EstimationMethod>(val);}

// Returns cardinality estimate. Sums if not calculated yet.
double creport() const {
csum();
return value_;
}
double report() noexcept {
csum();
return creport();
}
HyperLogLog(int np):core_(1uL<<np,0),np_(np),is_calculated_(0),estim_(EstimationMethod::ERTL_MLE),jestim_(JointEstimationMethod::ERTL_JOINT_MLE) {};
~HyperLogLog(){};


//private:
void add(uint64_t hashval);
void addh(const std::string &element);
double alpha()          const {return make_alpha(m());}
static double small_range_correction_threshold(uint64_t m) {return 2.5 * m;}
double union_size(const HyperLogLog &other) const;
// Call sum to recalculate if you have changed contents.
void csum() const { if(!is_calculated_) sum(); }
void sum() const {
const auto counts(sum_counts(core_)); // std::array<uint32_t, 64>  // K->C
value_ = calculate_estimate(counts, estim_, m(), np_, alpha(), 1e-2);
is_calculated_ = 1;
}
std::array<uint32_t,64> sum_counts(const std::vector<uint8_t> &sketchInfo) const;
double calculate_estimate(const std::array<uint32_t,64> &counts, EstimationMethod estim, uint64_t m, uint32_t p, double alpha, double relerr) const; 
template<typename T>
void compTwoSketch(const std::vector<uint8_t> &sketch1, const std::vector<uint8_t> &sketch2, T &c1, T &c2, T &cu, T &cg1, T &cg2, T &ceq) const;
template<typename T>
double ertl_ml_estimate(const T& c, unsigned p, unsigned q, double relerr=1e-2) const; 
template<typename HllType>
std::array<double, 3> ertl_joint(const HllType &h1, const HllType &h2) const; 

static constexpr double make_alpha(size_t m) {
switch(m) {
case 16: return .673;
case 32: return .697;
case 64: return .709;
default: return 0.7213 / (1 + 1.079/m);
}
}
static constexpr double LARGE_RANGE_CORRECTION_THRESHOLD = (1ull << 32) / 30.;
static constexpr double TWO_POW_32 = 1ull << 32;




//	}; // class HyperLogLog

} //namespace Sketch
*/
#endif // #ifndef HYPERLOGLOG_H_
