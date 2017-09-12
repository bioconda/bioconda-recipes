#!/bin/sh

cp -r bin $PREFIX
cp -r lib $PREFIX

mkdir -p $PREFIX/share/orthomcl/
cp doc/OrthoMCLEngine/Main/orthomcl.config.template $PREFIX/share/orthomcl/

chmod +x $PREFIX/bin/orthomclAdjustFasta
chmod +x $PREFIX/bin/orthomclBlastParser
chmod +x $PREFIX/bin/orthomclDropSchema
chmod +x $PREFIX/bin/orthomclDumpPairsFiles
chmod +x $PREFIX/bin/orthomclExtractProteinIdsFromGroupsFile
chmod +x $PREFIX/bin/orthomclExtractProteinPairsFromGroupsFile
chmod +x $PREFIX/bin/orthomclFilterFasta
chmod +x $PREFIX/bin/orthomclInstallSchema
chmod +x $PREFIX/bin/orthomclInstallSchema.sql
chmod +x $PREFIX/bin/orthomclLoadBlast
chmod +x $PREFIX/bin/orthomclLoadBlast.sql
chmod +x $PREFIX/bin/orthomclMclToGroups
chmod +x $PREFIX/bin/orthomclPairs
chmod +x $PREFIX/bin/orthomclReduceFasta
chmod +x $PREFIX/bin/orthomclReduceGroups
chmod +x $PREFIX/bin/orthomclRemoveIdenticalGroups
chmod +x $PREFIX/bin/orthomclSingletons
chmod +x $PREFIX/bin/orthomclSortGroupMembersByScore
chmod +x $PREFIX/bin/orthomclSortGroupsFile
