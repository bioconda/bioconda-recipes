#include <ncbi_pch.hpp>
#include "argwrapper.hpp"

USING_NCBI_SCOPE;

const char TArgDefinition::EMPTYSTR[] = "";


CArgDescriptions * ProcessArgDefinitions(const string &binname, const string &usage, const string &descr, const TArgDefinition *pDefs, size_t ndef, const TExtraArg *pExtra, size_t nextra, CArgDescriptions::EMiscFlags miscflgs)
{

	CArgDescriptions *pMyArgs = new CArgDescriptions;
	pMyArgs->SetArgsType(CArgDescriptions::eRegularArgs);
	pMyArgs->SetMiscFlags(miscflgs);
	pMyArgs->SetUsageContext(binname, usage);
	pMyArgs->SetDetailedDescription(descr);
/*debug*******************************************************
#if defined(_DEBUG)
cerr << __FILE__ << ':' << __LINE__ << ": ndef = " << ndef << ", pDefs = " << (void*)pDefs << endl;
#endif
// ***********************************************************/

	if (nullptr != pDefs && ndef > 0)
	{
		// -- setup contraint for args, according to situations
		// -- yet to find a way to specify them statically
		// -- add args
		for (size_t i = 0; i < ndef; ++i)
		{
			const TArgDefinition & argdef = pDefs[i];
			switch (argdef.cat)
			{
			case TArgDefinition::eKey:
				if (argdef.optional)
				{
					if (TArgDefinition::EMPTYSTR != argdef.def_val || TArgDefinition::EMPTYSTR != argdef.val_env)
						pMyArgs->AddDefaultKey(argdef.name, argdef.synopsis, argdef.descr, argdef.type, argdef.def_val, argdef.flags, argdef.val_env, argdef.def_val);
					else
						pMyArgs->AddOptionalKey(argdef.name, argdef.synopsis, argdef.descr, argdef.type, argdef.flags);
				}
				else	//non-optional
					pMyArgs->AddKey(argdef.name, argdef.synopsis, argdef.descr, argdef.type, argdef.flags);
				if (TArgDefinition::EMPTYSTR != argdef.alias)
					pMyArgs->AddAlias(argdef.alias, argdef.name);
				break;
			case TArgDefinition::eOpenPos:	//opening positional
				pMyArgs->AddOpening(argdef.name, argdef.descr, argdef.type, argdef.flags);
				if (TArgDefinition::EMPTYSTR != argdef.alias)
					pMyArgs->AddAlias(argdef.alias, argdef.name);
				break;
			case TArgDefinition::ePos:	//positional
				if (argdef.optional)
				{
					if (TArgDefinition::EMPTYSTR != argdef.def_val || TArgDefinition::EMPTYSTR != argdef.val_env)
						pMyArgs->AddDefaultPositional(argdef.name, argdef.descr, argdef.type, argdef.def_val, argdef.flags, argdef.val_env, argdef.def_val);
					else
						pMyArgs->AddOptionalPositional(argdef.name, argdef.descr, argdef.type, argdef.flags);
				}
				else	//non-optional
					pMyArgs->AddPositional(argdef.name, argdef.descr, argdef.type, argdef.flags);
				if (TArgDefinition::EMPTYSTR != argdef.alias)
					pMyArgs->AddAlias(argdef.alias, argdef.name);
				break;
			case TArgDefinition::eFlag:	//for flag, bool "optional" is used to "set_value"
				pMyArgs->AddFlag(argdef.name, argdef.descr, argdef.optional);
				if (TArgDefinition::EMPTYSTR != argdef.alias)
					pMyArgs->AddAlias(argdef.alias, argdef.name);
				break;
			case TArgDefinition::eNegFlag:	//for negated flag, the 'alias' is used as the original flag it negates
				pMyArgs->AddNegatedFlagAlias(argdef.name, argdef.alias, argdef.descr);
				break;
			}
			if (nullptr != argdef.constraint)
			{
				pMyArgs->SetConstraint(argdef.name, argdef.constraint, argdef.neg_constraint);
			}
		}
	}
	
	if (nullptr != pExtra && nextra > 0)
	{
		// -- add args
		for (size_t i = 0; i < nextra; ++i)
		{
			const TExtraArg &argdef = pExtra[i];
			pMyArgs->AddExtra(argdef.n_mandatory, argdef.n_optional, argdef.descr, argdef.type, argdef.flags);
		}
	}
	
	return pMyArgs;
	
}


	
