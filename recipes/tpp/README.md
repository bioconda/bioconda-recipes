Trans-Proteomic Pipeline
========================

The Trans-Proteomic Pipeline (TPP) is an open-source data analysis software
for proteomics developed at the Institute for Systems Biology (ISB) by the
Ruedi Aebersold group under the Seattle Proteome Center. The TPP includes
PeptideProphet,[2] ProteinProphet,[3] ASAPRatio, XPRESS, Libra, and a number
of parsers/converters.

Build Notes
-----------

This build of TPP was patched in the following ways for Bioconda packaging:

1. Windows-specific build items were removed where possible, as Bioconda does
   not support building for Windows.
   
2. Binaries that are not directly part of TPP (e.g. msconvert, comet,
hardklor, X!Tandem, etc) are either not built or are removed during the build
process. This helps to keep the Bioconda installation tidy and prevents the
TPP recipe from overwriting the binaries installed by the primary Bioconda
packages of these tools.

3. Files related to the web-based GUI are either not built or are removed
during the build process.

The following targets are built:

###Quantitation

- ASAPRatioPeptideParser
- ASAPRatioProteinRatioParser
- ASAPRatioPvalueParser
- LibraProteinRatioParser
- LibraPeptideParser
- Q3ProteinRatioParser
- StPeter
- XPressPeptideParser
- XPressProteinRatioParser

###Validation

- DiscoFilter
- InterProphetParser
- PeptideProphetParser
- ProteinProphet
- PTMProphetParser
- RespectParser

###Visualization

- InteractParser
- xinteract

###Parsers

- CombineOut
- CompactParser
- DatabaseParser
- Mascot2XML
- MzXML2Search
- Out2XML
- PeptideMapper
- RefreshParser
- RTCalc
- RTCatalogParser
- Sequest2XML
- Sqt2XML
- Tandem2XML

