#include <ncbi_pch.hpp>
#include "datanode.hpp"
using namespace std;

TAtomicCounterValueType CRefCounter::operator ++(void)
{
	return 1 + m_count.fetch_add(1, memory_order_relaxed);
}

TAtomicCounterValueType CRefCounter::operator ++(int)
{
	return m_count.fetch_add(1, memory_order_relaxed);
}

TAtomicCounterValueType CRefCounter::operator --(void)
{
	return m_count.fetch_sub(1, memory_order_acq_rel) - 1;
}

TAtomicCounterValueType CRefCounter::operator --(int)
{
	return m_count.fetch_sub(1, memory_order_acq_rel);
}



CDocNodeBase::CDocNodeBase(void):
	m_counter(0)
{}

void CDocNodeBase::x_IncRef(void)
{
	++m_counter;
}
void CDocNodeBase::x_DecRef(void)
{	
	TAtomicCounterValueType c = --m_counter;
	if (0 == c)
		delete this;
}
