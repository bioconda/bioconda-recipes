#ifndef __XXHASH_H__
#define __XXHASH_H__

#include <stdexcept>
#include "xxhash.h"

class xxhash {
protected:
  XXH64_state_t* const m_state;
  const unsigned long long m_seed;

public:
  xxhash(unsigned long long seed = 0)
    : m_state(XXH64_createState())
    , m_seed(seed)
  {
    if(m_state == nullptr)
      throw std::runtime_error("Error creating state of xxhash");
    reset();
  }

  ~xxhash() {
    XXH64_freeState(m_state);
  }

  inline void reset() { reset(m_seed); }
  void reset(unsigned long long seed) {
    if(XXH64_reset(m_state, seed) == XXH_ERROR)
      throw std::runtime_error("Error reset of xxhash");
  }

  void update(const void* ptr, size_t len) {
    if(XXH64_update(m_state, ptr, len) == XXH_ERROR)
      throw std::runtime_error("Error update of xxhash");
  }

  unsigned long long digest() {
    return XXH64_digest(m_state);
  }
};

#endif /* __XXHASH_H__ */
