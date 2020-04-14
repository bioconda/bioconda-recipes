#if !defined(__ENV_DEF__)
#define __ENV_DEF__
#if defined(__DB_OFFLINE__)
#include "normbase.hpp"
#else
#include <BasicUtils/normbase.hpp>
#endif
/**********************************************************************
*	Basic Typedefs
***********************************************************************/

#include <corelib/ncbimisc.hpp>
#include <corelib/ncbiobj.hpp>
#include <corelib/ncbitype.h>


typedef ncbi::TGi GI_t;
typedef ncbi::TSeqPos SeqLen_t;
typedef ncbi::TSignedSeqPos SeqPos_t;

typedef ncbi::TUintId PssmId_t, PIG_t, ArchId_t, PubMedId_t, GeneId_t;
typedef UINT32 Flags_t;
typedef ncbi::TIntId TaxId_t, ClusterId_t, PrefTaxId_t;

constexpr const SeqLen_t k_SeqLen_Max = ~(SeqLen_t)0;
constexpr const SeqPos_t RESIDUE_DISPLAY_OFFSET = 1;

enum class INTERNAL_CODE: int
{
	e_OK = 0,
	e_PIGPEN_HOLE = 1
};

#endif
