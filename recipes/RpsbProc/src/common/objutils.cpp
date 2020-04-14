#include <ncbi_pch.hpp>
#include "objutils.hpp"
#include <objects/general/general__.hpp>
#include <objects/seqloc/seqloc__.hpp>
USING_NCBI_SCOPE;
using namespace objects;

void CObjectIdWriteHooker::WriteChoiceVariant(CObjectOStream& os, const CConstObjectInfoCV& variant)
{
	//const CObject_id& objid = *CType<CObject_id>::Get(variant.GetVariant().GetPointedObject());
	const CObject_id& objid = *reinterpret_cast<const CObject_id*> (variant.GetVariant().GetObjectPtr());
	if (objid.Which() == CObject_id::e_Id)
	{
		char dimBuf[16];
		sprintf(dimBuf, "%d", objid.GetId());
		
		CObject_id rep_id;
		rep_id.SetStr(dimBuf);
		
		//const ncbi::CTypeInfo* typeInfo = ObjectInfo(rep_id);
		
		
		//CConstObjectInfoCV infoCV(ObjectInfo(rep_id));
		os.WriteObject(ObjectInfo(rep_id));
		//DefaultWrite(os, infoCV);
		//os << rep_id;
	}
	else DefaultWrite(os, variant);
}
