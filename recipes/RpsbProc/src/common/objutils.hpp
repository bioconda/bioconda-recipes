#if !defined(__OBJ_UTILS__)
#define __OBJ_UTILS__
#include <objects/general/general__.hpp>
#include <objects/seqloc/seqloc__.hpp>
#include <serial/objhook.hpp>
#include <serial/objistr.hpp>
#include <serial/objistrasn.hpp>
#include <serial/objistrasnb.hpp>
#include <serial/objistrjson.hpp>
#include <serial/objistrxml.hpp>
#include <serial/objostr.hpp>
#include <serial/objostrasn.hpp>
#include <serial/objostrasnb.hpp>
#include <serial/objostrjson.hpp>
#include <serial/objostrxml.hpp>
#include <serial/objhook.hpp>
#include <serial/serial.hpp>
#include "envdef.hpp"

/***********************************************************************************************************************
//	this is to convert e_Id variant in object id into e_Str variant so that Cn3D 4.1- can work correctly
************************************************************************************************************************/
class CObjectIdWriteHooker: public ncbi::CWriteChoiceVariantHook
{
	virtual void WriteChoiceVariant(ncbi::CObjectOStream& os, const ncbi::CConstObjectInfoCV& variant);   
};

// *********************************************************************************************************************/

//template<class BioObj> 
//void ObjStreamOut(ncbi::CNcbiOstream& os, const BioObj& rBioObj, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
//{
//  if (ncbi::eSerial_Xml == eFormat)	//Get rid of dtd
//  {
//  	ncbi::CObjectOStreamXml os_xml(os, eNoOwnership);
//  	os_xml.SetReferenceDTD(false);
//  	ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(os_xml, new CObjectIdWriteHooker);
//  	os_xml << rBioObj;
//  }
//	else
//	{
////#if defined(__USING_CENTOS6__)
//		ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, eNoOwnership);
////#else
////		ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, ncbi::eNoOwnership);
////#endif
//		ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(*pOStream, new CObjectIdWriteHooker);
//		*pOStream << rBioObj;
//		delete pOStream;
//	}
//}
//
//template<class BioObj> 
//void ObjStreamOut(ncbi::CNcbiOstream& os, const BioObj* pBioObj, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
//{
//	if (nullptr == pBioObj) return;
//	
//	if (ncbi::eSerial_Xml == eFormat)	//Get rid of dtd
//  {
////#if defined(__USING_CENTOS6__)
//    ncbi::CObjectOStreamXml os_xml(os, eNoOwnership);
////#else
////		ncbi::CObjectOStreamXml os_xml(os, ncbi::eNoOwnership);
////#endif
//   	os_xml.SetReferenceDTD(false);
//   	ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(os_xml, new CObjectIdWriteHooker);
//   	os_xml << (*pBioObj);
//  }
//	else
//	{
////#if defined(__USING_CENTOS6__)
//		ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, eNoOwnership);
////#else
////		ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, ncbi::eNoOwnership);
////#endif
//		ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(*pOStream, new CObjectIdWriteHooker);
//		*pOStream << (*pBioObj);
//		delete pOStream;
//	}
//}

template<class BioObj> 
void ObjStreamOut(ncbi::CNcbiOstream& os, const BioObj& rBioObj, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
{
	ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, eNoOwnership);
	
	if (ncbi::eSerial_Xml == eFormat)	//Get rid of dtd
  {
  	ncbi::CObjectOStreamXml *p_os_xml = dynamic_cast< ncbi::CObjectOStreamXml* > (pOStream);
  	if (nullptr != p_os_xml)
  		p_os_xml->SetReferenceDTD(false);
  }
	
	ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(*pOStream, new CObjectIdWriteHooker);
	*pOStream << rBioObj;
	delete pOStream;
}

template<class BioObj> 
void ObjStreamOut(ncbi::CNcbiOstream& os, const BioObj* pBioObj, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
{
	if (nullptr == pBioObj) return;
	
	ncbi::CObjectOStream *pOStream = ncbi::CObjectOStream::Open(eFormat, os, eNoOwnership);
	
	if (ncbi::eSerial_Xml == eFormat)	//Get rid of dtd
  {
  	ncbi::CObjectOStreamXml *p_os_xml = dynamic_cast< ncbi::CObjectOStreamXml* > (pOStream);
  	if (nullptr != p_os_xml)
  		p_os_xml->SetReferenceDTD(false);
  }
	
	ncbi::CObjectTypeInfo(ncbi::objects::CSeq_id::GetTypeInfo()).FindVariant("local").SetLocalWriteHook(*pOStream, new CObjectIdWriteHooker);
	*pOStream << (*pBioObj);
	delete pOStream;
}



template<class BioObj> 
void ObjStreamIn(ncbi::CNcbiIstream& is, BioObj& rBioObj, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
{
//#if defined(__USING_CENTOS6__)
	ncbi::CObjectIStream *pIStream = ncbi::CObjectIStream::Open(eFormat, is, eNoOwnership);
//#else
//	ncbi::CObjectIStream *pIStream = ncbi::CObjectIStream::Open(eFormat, is, ncbi::eNoOwnership);
//#endif

	*pIStream >> rBioObj;
	//pIStream->Read(ObjectInfo(rBioObj));
	delete pIStream;
}

template<class BioObj> 
BioObj* ObjStreamIn(ncbi::CNcbiIstream& is, BioObj* pBioObj = nullptr, ncbi::ESerialDataFormat eFormat = ncbi::eSerial_AsnText)
{
	BioObj* pEffective = pBioObj ? pBioObj : new BioObj();
//#if defined(__USING_CENTOS6__)
	ncbi::CObjectIStream *pIStream = ncbi::CObjectIStream::Open(eFormat, is, eNoOwnership);
//#else
//	ncbi::CObjectIStream *pIStream = ncbi::CObjectIStream::Open(eFormat, is, ncbi::eNoOwnership);
//#endif

	*pIStream >> (*pEffective);
	//pIStream->Read(ObjectInfo(rBioObj));
	delete pIStream;
	return pEffective;
}

template<class BioObj>
std::string GetString(const BioObj& rBioObj)
{
	std::stringstream ss;
	ObjStreamOut<BioObj> (ss, rBioObj);
	return ss.str();
}

#endif
