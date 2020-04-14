#include <ncbi_pch.hpp>
#include "segset.hpp"



bool TSeg_base::IsValid(void) const
{
	return (to >= from);
}

//Deliberately left out lext and rext
bool TSeg_base::operator == (const TSeg_base& other) const
{
	return from == other.from && to == other.to;
}

bool TSegSortLeft::operator () (const TSeg_base* s1, const TSeg_base* s2)
{
	return s1->from < s2->from;
}

bool TSegSortLength::operator () (const TSeg_base* s1, const TSeg_base* s2)
{
	return s1->to - s1->from > s2->to - s2->from;
}


