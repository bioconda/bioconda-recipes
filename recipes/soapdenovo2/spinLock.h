#ifndef SPINLOCK_H
#define SPINLOCK_H

#ifdef __APPLE__
#include <pthread.h>
#include <errno.h>

#ifndef PTHREAD_PROCESS_PRIVATE
#define PTHREAD_PROCESS_PRIVATE 0
#endif

/* macOS has no POSIX spinlocks; minimal test-and-set replacement using GCC/Clang atomic builtins */
typedef int pthread_spinlock_t;

static inline int pthread_spin_init(pthread_spinlock_t *l, int pshared)
{
    (void)pshared;
    __atomic_store_n(l, 0, __ATOMIC_RELEASE);
    return 0;
}

static inline int pthread_spin_destroy(pthread_spinlock_t *l)
{
    (void)l;
    return 0;
}

static inline int pthread_spin_lock(pthread_spinlock_t *l)
{
    while (__atomic_exchange_n(l, 1, __ATOMIC_ACQUIRE)) {
        /* spin on a plain load to avoid hammering the cache line */
        while (__atomic_load_n(l, __ATOMIC_RELAXED)) {
#if defined(__aarch64__)
            __asm__ __volatile__("yield");
#elif defined(__x86_64__)
            __asm__ __volatile__("pause");
#endif
        }
    }
    return 0;
}

static inline int pthread_spin_trylock(pthread_spinlock_t *l)
{
    return __atomic_exchange_n(l, 1, __ATOMIC_ACQUIRE) ? EBUSY : 0;
}

static inline int pthread_spin_unlock(pthread_spinlock_t *l)
{
    __atomic_store_n(l, 0, __ATOMIC_RELEASE);
    return 0;
}

#endif /* __APPLE__ */
#endif /* SPINLOCK_H */
