###################################################################################
# Program       : Makefile                                                        #
# Author        : Andrew Keller <akeller@systemsbiology.org>                      #
# Date          : 11.27.02                                                        #
#                                                                                 #
# for compilation of C++ version of TPP, including PeptideProphet                 #
#                                                                                 #
# Copyright (C) 2003 Andrew Keller                                                #
#                                                                                 #
# This library is free software; you can redistribute it and/or                   #
# modify it under the terms of the GNU Lesser General Public                      #
# License as published by the Free Software Foundation; either                    #
# version 2.1 of the License, or (at your option) any later version.              #
#                                                                                 #
# This library is distributed in the hope that it will be useful,                 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU               #
# General Public License for more details.                                        #
#                                                                                 #
# You should have received a copy of the GNU Lesser General Public                #
# License along with this library; if not, write to the Free Software             #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA       #
#                                                                                 #
# Andrew Keller                                                                   #
# Institute for Systems Biology                                                    #
# 401 Terry Avenue North                                                             #
# Seattle, WA  98109  USA                                                         #
# akeller@systemsbiology.org                                                      #
#                                                                                 #
###################################################################################

#
# A note about TPP Version and Build Numbers
#
# The files src/common/TPPVersion.h and src/common/TPPVersionInfo.cpp control the version
# info displayed by TPP components. This info is furnished to the various exe and cgi files
# by linking with an object file. During compilation build information, such at the
# build timestamp is included in the final objct file.
#
# The build infomation is refreshed when src/common/TPPVersion.h is changed, or during
# a "make clean all".  The intent is that the build number be the same across all TPP
# TPP components delivered to the end user.  It could of course be refreshed with 
# every "make all" but that would mean every app would relink every time, which would bog 
# down the development cycle.  If you wish to force a update of the build information
# without doing a "make clean", use "make new_build".
#

# Include configuration variables for the build, including determination of $(ARCH)
SRC_ROOT= $(PWD)/
include Makefile.incl


FASTAR_DIR = $(SRC_ROOT)../extern/fastar
ifeq (${LGPL},1) 
FASTAR_INCL= -I$(FASTAR_DIR)/spare -I$(FASTAR_DIR)/common 
VPATH_FASTAR =  $(FASTAR_DIR)/spare $(FASTAR_DIR)/common
LGPLFLAG= -D__LGPL__
else 
FASTAR_INCL=
VPATH_FASTAR =   
LGPLFLAG=
endif


ifeq (${ARCH},mingw-i686)
LIBARCHIVE_DIR = $(SRC_ROOT)../extern/libw32c
LIBARCHIVE_INCL = $(SRC_ROOT)../extern/libw32c/include
LIBARCHIVE = $(SRC_ROOT)../extern/libw32c/lib/archive.lib
# htmldoc doesn't build on MinGW
HTMLDOC_BIN = 
else
LIBARCHIVE_VER = 2.2.7
LIBARCHIVE_TGZ = $(SRC_ROOT)/../extern/libarchive-$(LIBARCHIVE_VER).tar.gz
LIBARCHIVE_DIR = $(OBJ_ARCH)/libarchive-$(LIBARCHIVE_VER)
LIBARCHIVE_INCL = $(LIBARCHIVE_DIR)/libarchive
LIBARCHIVE = $(OBJ_ARCH)/libarchive.a
endif

INCLUDE=\
  -I. \
  -I$(SRC_ROOT). \
  $(FASTAR_INCL) $(ZLIB_INCL) \
  -I$(SRC_ROOT)../extern/gzstream \
  -I$(SRC_ROOT)../extern \
  -I$(LIBARCHIVE_INCL) \
  -I$(TPP_MSDATA_READER_INCL) \
  -I$(EXPAT_INCL) -I$(HDF5_INCL) $(BOOST_INCL) -I$(FANN_INCLDIR) -I$(GSL_INCLDIR) $(GD_INCL) $(PWIZ_INCL) 

DISTRIBUTIONS_H= ContinuousDistribution.h DiscreteDistribution.h Distribution.h ExtremeValueDistribution.h GammaDistribution.h GaussianDistribution.h NonParametricDistribution.h GeneralizedGaussianDistribution.h
DISCRIMVALMIXTUREDISTRS_H= CometDiscrimValMixtureDistr.h DiscrimValMixtureDistr.h MascotDiscrimValMixtureDistr.h PhenyxDiscrimValMixtureDistr.h OMSSADiscrimValMixtureDistr.h CruxDiscrimValMixtureDistr.h YABSEDiscrimValMixtureDistr.h MyrimatchDiscrimValMixtureDistr.h MSGFDBDiscrimValMixtureDistr.h MSGFPLDiscrimValMixtureDistr.h ProbIDDiscrimValMixtureDistr.h SpectraSTDiscrimValMixtureDistr.h TandemDiscrimValMixtureDistr.h 
MIXTUREDISTRS_H= ContinuousMultimixtureDistr.h DecayContinuousMultimixtureDistr.h DiscreteMixtureDistr.h GlycMixtureDistr.h PhosphoMixtureDistr.h ICATMixtureDistr.h IsoMassDiffDiscrMixtureDistr.h MassDifferenceDiscrMixtureDistr.h MixtureDistr.h MzDifferenceDiscrMixtureDistr.h NMCMixtureDistr.h NTTMixtureDistr.h pIMixtureDistr.h RTMixtureDistr.h AccurateMassDiffDiscrMixtureDistr.h VariableOffsetMassDiffDiscrMixtureDistr.h VariableOffsetpIMixtureDistr.h KernelDensityPIMixtureDistr.h KernelDensityRTMixtureDistr.h
DISCRIMFUNCTIONS_H= DiscriminantFunction.h CometDiscrimFunction.h MascotDiscrimFunction.h PhenyxDiscrimFunction.h OMSSADiscrimFunction.h CruxDiscrimFunction.h YABSEDiscrimFunction.h MyrimatchDiscrimFunction.h MSGFDBDiscrimFunction.h MSGFPLDiscrimFunction.h InspectDiscrimFunction.h ProbIDDiscrimFunction.h AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SpectraSTDiscrimFunction.h TandemDiscrimFunction.h ToftofAbbrevSequestDiscrimFunction.h


ifeq (${XML_ONLY},1)
XMLFLAGS= -DXML_ONLY
else
XMLFLAGS=
endif

CFLAGS= ${OSFLAGS} ${XMLFLAGS} ${LGPLFLAG} -D__INTEL__ -DINLINING -DTPPLIB  ${FPIC}

# -DPWIZ_USER_VERSION_INFO_H=<TPPVersion.h> lets us insert TPP version info into ProteoWizard executables like msconvert
NAIVE_CC=g++ ${CFLAGS} ${DEBUG} ${INCLUDE}  -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -DPWIZ_USER_VERSION_INFO_H=\"common/TPPVersion.h\" -DWITHOUT_MZ5
ifneq  ($(strip $(PERL_BIN)),)
NAIVE_CC += -DPERL_BIN=\"${PERL_BIN}\"
endif
ifneq  ($(strip $(GNUPLOT_BINARY)),)
NAIVE_CC += -DGNUPLOT_BINARY=\"${GNUPLOT_BINARY}\"
endif

CC=${NAIVE_CC} -Dlint -Wformat -Wstrict-aliasing  -Wno-deprecated -Wno-char-subscripts


# put here the complete directory path for the include subdirectory
CCINC=

# here again the name of the c++ compiler
#LD=g++ -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE
LD=g++ ${INCLUDE} -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE

LDFLAGS= ${SYSLIBS} ${DEBUG} ${EXPAT_LIB} ${HDF5_LIB}
OLD = 
#-oldcxx

######################################################################
#
# do not edit past this point
#
######################################################################

#
# rules
#

COMPILE = $(CC) $(OLD) $(DEBUG) $(CCOPT) $(CCINC) -c $(OPT)

# you had better have a good reason for ignoring warnings, such as generated code
NAIVE_COMPILE = $(NAIVE_CC) $(OLD) $(DEBUG) $(CCOPT) $(CCINC) -c $(OPT)

.SUFFIXES:	.o .cxx .c .cpp .$(POBJ)

$(OBJ_ARCH)/%.o: %.c 
		$(COMPILE) -o $@ $<

$(OBJ_ARCH)/%.o: %.cpp 
		$(COMPILE) -o $@ $<

$(OBJ_ARCH)/%.o: %.cxx 
		$(COMPILE) -o $@ $<


# for building mzParser and ramp side by side - forces use of actual mzParser.h
$(OBJ_ARCH)/%.mzp.o: %.cpp 
		SAVEP=${TPP_MSDATA_READER_INCL}
		TPP_MSDATA_READER_INCL=$(SRC_DIR)Parsers/mzParser
		$(COMPILE) -o $@ $<
		TPP_MSDATA_READER_INCL=${SAVEP}


VPATH += \
  common \
  common/ModificationInfo \
  common/ModifiedResidueMass \
  common/ResidueMass \
  Enzyme \
  Enzyme/EnzymeDigestion \
  Enzyme/EnzymeDigestionParser \
  Enzyme/ProteolyticEnzyme \
  Enzyme/ProteolyticEnzyme/ProteolyticEnzymeFactory \
  mzXML/tools/readmzXML \
  util \
  util/out2summary \
  Parsers \
  Parsers/Algorithm2XML \
  Parsers/Algorithm2XML/Tandem2XML \
  Parsers/Algorithm2XML/Mascot2XML \
  Parsers/Algorithm2XML/SearchParams \
  Parsers/Algorithm2XML/SearchResult \
  Parsers/Algorithm2XML/Sequest2XML \
  Parsers/Algorithm2XML/Sqt2XML \
  Parsers/AnalysisSummaryParser \
  Parsers/CompactParser \
  Parsers/DatabaseParser \
  Parsers/Parser \
  $(TPP_MSDATA_READER_INCL) \
  Parsers/ramp \
  Parsers/RefreshParser \
  Parsers/MzXML2Search\
  Quantitation \
  Quantitation/ASAPRatio \
  Quantitation/ASAPRatio/ASAPCGIDisplay \
  Quantitation/ASAPRatio/ASAPRatio_Fns \
  Quantitation/ASAPRatio/ASAPRatioPeptideCGIDisplayParser \
  Quantitation/ASAPRatio/ASAPRatioPeptideParser \
  Quantitation/ASAPRatio/ASAPRatioProteinRatioParser \
  Quantitation/ASAPRatio/ASAPRatioPvalueParser \
  Quantitation/ASAPRatio/Normalization \
  Quantitation/ASAPRatio/PvalueModel \
  Quantitation/ASAPRatio/UniquePeptide \
  Quantitation/Libra \
  Quantitation/Libra/LibraPeptideParser \
  Quantitation/Libra/LibraProteinRatioParser \
  Quantitation/RatioParser \
  Quantitation/XPress \
  Quantitation/XPress/XPressCGIParser \
  Quantitation/XPress/XPressCGIProteinDisplayParser \
  Quantitation/XPress/XPressPeptideParser \
  Quantitation/XPress/XPressPeptideUpdateParser \
  Quantitation/XPress/XPressProteinRatioParser \
  Quantitation/Q3/Q3ProteinRatioParser \
  run_in \
  runperl_src \
  setWin32Permissions \
  tpp_hostname \
  Validation \
  Validation/DiscriminateFunction \
  Validation/DiscriminateFunction/Comet \
  Validation/DiscriminateFunction/Mascot \
  Validation/DiscriminateFunction/ProbID \
  Validation/DiscriminateFunction/Sequest \
  Validation/DiscriminateFunction/Tandem \
  Validation/DiscriminateFunction/Phenyx \
  Validation/DiscriminateFunction/OMSSA \
  Validation/DiscriminateFunction/Crux \
  Validation/DiscriminateFunction/YABSE \
  Validation/DiscriminateFunction/Myrimatch \
  Validation/DiscriminateFunction/MSGFDB \
  Validation/DiscriminateFunction/MSGFPL \
  Validation/DiscriminateFunction/Inspect \
  Validation/DiscriminateFunction/SpectraST \
  Validation/Distribution \
  Validation/MixtureDistribution \
  Validation/MixtureModel \
  Validation/ModelParser \
  Validation/iModelParser \
  Validation/ProteinProphet \
  Validation/PeptideProphet \
  Validation/PeptideProphet/PeptideProphetOptions \
  Validation/PeptideProphet/PeptideProphetParser \
  Validation/InterProphet/InterProphetParser \
  Validation/PTMProphetParser \
  Validation/Respect \
  Visualization \
  Visualization/Pep3D \
  Visualization/Pep3D/cgi_Pep3D_xml \
  Visualization/Comet \
  Visualization/Comet/comet-pepxml\
  Visualization/Comet/comet-fastadb \
  Visualization/Comet/plot-msms \
  Visualization/Comet/sequest-tgz-out \
  Visualization/InteractParser \
  Visualization/xinteract \
  Visualization/SpectraST \
  Visualization/ShowXIC \
  Search/SpectraST \
  $(VPATH_FASTAR) \
  refresh_interact \
  $(VPATH_PWIZ)

#
# targets
#

EXE_XML = \
     $(OBJ_ARCH)/PeptideProphetParser \
     $(OBJ_ARCH)/InterProphetParser \
     $(OBJ_ARCH)/PTMProphetParser \
     $(OBJ_ARCH)/RespectParser \
     $(OBJ_ARCH)/RTCalc \
     $(OBJ_ARCH)/RTCatalogParser \
     $(OBJ_ARCH)/ProteinProphet \
     $(OBJ_ARCH)/EnzymeDigestionParser \
     $(OBJ_ARCH)/XPressPeptideParser \
     $(OBJ_ARCH)/ASAPRatioPeptideParser \
     $(OBJ_ARCH)/ASAPRatioProteinRatioParser \
     $(OBJ_ARCH)/InteractParser \
     $(OBJ_ARCH)/DatabaseParser \
     $(OBJ_ARCH)/RefreshParser \
     $(OBJ_ARCH)/MzXML2Search \
     $(OBJ_ARCH)/XPressProteinRatioParser \
     $(OBJ_ARCH)/Q3ProteinRatioParser \
     $(OBJ_ARCH)/ASAPRatioPvalueParser \
     $(OBJ_ARCH)/CompactParser \
     $(OBJ_ARCH)/xinteract \
     $(OBJ_ARCH)/runperl \
     $(OBJ_ARCH)/tpp_hostname \
     $(OBJ_ARCH)/Sequest2XML \
     $(OBJ_ARCH)/Mascot2XML \
     $(OBJ_ARCH)/Tandem2XML \
     $(OBJ_ARCH)/LibraPeptideParser \
     $(OBJ_ARCH)/LibraProteinRatioParser \
     $(OBJ_ARCH)/Out2XML \
     $(OBJ_ARCH)/Sqt2XML \
     $(OBJ_ARCH)/CombineOut \
     $(OBJ_ARCH)/dtafilter \
     $(OBJ_ARCH)/runsearch \
     $(OBJ_ARCH)/out2summary \
     $(OBJ_ARCH)/readmzXML \
     $(OBJ_ARCH)/indexmzXML \
     $(OBJ_ARCH)/dta2mzxml \
     $(OBJ_ARCH)/plotspectrast \
     $(OBJ_ARCH)/spectrast \
     $(OBJ_ARCH)/Lib2HTML \
     $(OBJ_ARCH)/decoyFASTA \
     $(OBJ_ARCH)/pep_dbcount \
     $(OBJ_ARCH)/subsetdb \
     $(OBJ_ARCH)/translateDNA2AA-FASTA \
     $(OBJ_ARCH)/calculate_pi \
     $(OBJ_ARCH)/add_mz \
     $(OBJ_ARCH)/digestdb \
     $(OBJ_ARCH)/comet

EXE_HTML = $(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.cgi \
     $(OBJ_ARCH)/tpplib_perl.pm \
     $(OBJ_ARCH)/tpp_hostname \
     $(OBJ_ARCH)/run_in \
     $(OBJ_ARCH)/ASAPCGIDisplay.cgi \
     $(OBJ_ARCH)/ModelParser.cgi \
     $(OBJ_ARCH)/iModelParser.cgi \
     $(OBJ_ARCH)/XPressPeptideUpdateParser.cgi \
     $(OBJ_ARCH)/XPressCGIProteinDisplayParser.cgi \
     $(OBJ_ARCH)/Pep3D_xml.cgi \
     $(OBJ_ARCH)/ShowXIC.cgi \
     $(OBJ_ARCH)/disCidData_xml.cgi \
     $(OBJ_ARCH)/getCidData_xml.cgi \
     $(OBJ_ARCH)/AnalysisSummaryParser.cgi \
     $(OBJ_ARCH)/comet-pepxml.cgi \
     $(OBJ_ARCH)/comet-fastadb.cgi \
     $(OBJ_ARCH)/plot-msms.cgi \
     $(OBJ_ARCH)/plot-msms-js.cgi \
     $(OBJ_ARCH)/sequest-tgz-out.cgi \
     $(OBJ_ARCH)/xpress-prophet-update.cgi \
     $(OBJ_ARCH)/cometresult.cgi \
     $(OBJ_ARCH)/PepXMLViewer.cgi \
     $(OBJ_ARCH)/dta-xml.cgi \
     $(OBJ_ARCH)/plotspectrast.cgi 

ifeq (${ARCH_FAMILY},mingw)
EXE_HTML += $(OBJ_ARCH)/setWin32Permissions $(OBJ_ARCH)/crypt

# FIXME: putting this here for now (JS)
EXE_HTML += $(OBJ_ARCH)/pthreadGC2.dll

$(OBJ_ARCH)/pthreadGC2.dll : 
	cp /MinGW/bin/pthreadGC2.dll $(OBJ_ARCH)
endif


ifeq (${XML_ONLY},1)
EXE = ${EXE_XML}
else
EXE = ${EXE_XML} ${EXE_HTML}
endif

all : version $(HTMLDOC_BIN) $(EXPAT_LIB) $(GSL_LIBS) $(FANN_LIBS) \
      pwiz $(BOOST_LIBS) xtandem ${EXE} perl_paths | $(OBJ_ARCH)
	make -C ../COVERAGE/

debug :
	DEBUG='-g' make all 
debug-clean :
	DEBUG='-g' make clean all
debug-install :
	DEBUG='-g' make install

#
# Generate version and build information. Uses the current date and svn version
# as a build "id".  And use these variables sparingly as every time they are
# are referenced the time consuming "svnversion" is invoked.  Now we could
# use simply expanded variables, but that would mean svnversion would be 
# invoked every time the Makefile is read and we don't want to do that. Note
# also that svnversion returns "exported" on Linux or "Unversioned directory"
# in Msys/MingW.
#
.PHONY : version version-clean

TPP_VERSIONINFO := $(OBJ_ARCH)/TPPVersionInfo.o \
                   $(OBJ_ARCH)/TPPVersionInfo.nsh

BLDDAY = $(shell date '+%Y%m%d%H%M')
SVNREV = $(shell (svnversion -n .. || echo 'exported') | \
                 perl -pe 's/U.*tory/exported/')

version : $(TPP_VERSIONINFO)

$(TPP_VERSIONINFO) : TPP_BUILD_ID = $(BLDDAY)-$(SVNREV)
$(TPP_VERSIONINFO) : ./common/TPPVersionInfo.cpp
$(TPP_VERSIONINFO) : ./common/TPPVersion.h | $(OBJ_ARCH)
	@echo "### Generating version for TPP build $(TPP_BUILD_ID)"
	$(CXX) -c -o $(OBJ_ARCH)/TPPVersionInfo.o       \
	   -DTPP_BUILD_ID='$(TPP_BUILD_ID)'             \
	   -DTPP_BUILD_ARCH='$(ARCH)'                   \
	./common/TPPVersionInfo.cpp
	perl -ne 'print if ( s/^\#define TPP/\!define PRODUCT/ )' $< \
	   > $(OBJ_ARCH)/TPPVersionInfo.nsh
	echo '!define PRODUCT_BUILD_ID $(TPP_BUILD_ID)' \
	   >> $(OBJ_ARCH)/TPPVersionInfo.nsh
	@echo "### ...done generating version and build information for TPP"

version-clean :
	rm -f $(TPP_VERSIONINFO)

#
# cygwin or linux?
#
ifeq (${ARCH},cygwin)

install: install-windows

configure:

else 
ifeq (${ARCH_FAMILY},mingw)

install : 
	rm -f $(OBJ_ARCH)/TPP_Setup_*.exe
	@if [ ! -e "$(PROGRAMFILES)/NSIS/makensis.exe" ]; then echo Error: "$(PROGRAMFILES)/NSIS/makensis.exe" not found, you need to download and install the NSIS installer package from nsis.sourceforge.net; exit -1; fi;	
	cp ../../qualscore/qualscore.v1.0_2.jar $(OBJ_ARCH)/qualscore.jar
	cp -r ../../qualscore/lib $(OBJ_ARCH)/
# windows needs the .txt extension to understand how to display to user in install process
	cp -f ../README ../README.txt
	"$(PROGRAMFILES)/NSIS/makensis.exe" -DARCH="${ARCH}" -DPRODUCT_BUILD_DIR="$(OBJ_ARCH)" ../installer_win32/TPP_installer.nsi
	rm ../README.txt
	cp $(OBJ_ARCH)/TPP_Setup_*.exe $(OBJ_ARCH)/TPP_setup.exe
	$(OBJ_ARCH)/TPP_setup "/S"

configure:

else

install: install-linux

configure: configure-linux

endif
endif

#
# tweak perl and xsd files for install OS
#

$(OBJ_ARCH)/tpplib_perl.pm : perl_paths
.PHONY: perl_paths
perl_paths : TPPVersion.h $(OBJ_ARCH)/tpp_hostname ../perl/tpplib_perl.pm
	mkdir -p $(OBJ_ARCH)/help
	mkdir -p $(OBJ_ARCH)/schema
	mkdir -p $(OBJ_ARCH)/images
	cd perl_paths; export PERL=perl; make -f perl_paths.makefile all


$(SPECTRASTLIB): 	$(OBJ_ARCH)/SpectraSTPepXMLLibImporter.o $(OBJ_ARCH)/SpectraSTSpLibImporter.o \
	$(OBJ_ARCH)/FileUtils.o $(OBJ_ARCH)/Peptide.o $(OBJ_ARCH)/XMLWalker.o 
	ar -r $@ $^


$(TPP_BUILD): \
      $(OBJ_ARCH)/AbbrevSequestDiscrimFunction.o \
      $(OBJ_ARCH)/ASAPRatio_numFns.o \
      $(OBJ_ARCH)/ASAPRatio_pepFns.o \
      $(OBJ_ARCH)/ASAPRatio_txtFns.o \
      $(OBJ_ARCH)/ASAPRatioPeptideParserTagListComparator.o \
      $(OBJ_ARCH)/ASAPRatioPvalueParserTagListComparator.o \
      $(OBJ_ARCH)/CometDiscrimFunction.o \
      $(OBJ_ARCH)/CometDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/CometResult.o \
      $(OBJ_ARCH)/ContinuousDistribution.o \
      $(OBJ_ARCH)/ContinuousMultimixtureDistr.o \
      $(OBJ_ARCH)/DecayContinuousMultimixtureDistr.o \
      $(OBJ_ARCH)/DiscreteDistribution.o \
      $(OBJ_ARCH)/DiscreteMixtureDistr.o \
      $(OBJ_ARCH)/DiscriminantFunction.o \
      $(OBJ_ARCH)/DiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/Distribution.o \
      $(OBJ_ARCH)/ExtremeValueDistribution.o \
      $(OBJ_ARCH)/GammaDistribution.o \
      $(OBJ_ARCH)/GaussianDistribution.o \
      $(OBJ_ARCH)/GeneralizedGaussianDistribution.o \
      $(OBJ_ARCH)/GlycMixtureDistr.o \
      $(OBJ_ARCH)/PhosphoMixtureDistr.o \
      $(OBJ_ARCH)/hooks_tpp.o \
      $(OBJ_ARCH)/ICATMixtureDistr.o \
      $(OBJ_ARCH)/IsoMassDiffDiscrMixtureDistr.o \
      $(OBJ_ARCH)/InterProphetParser.o \
      $(OBJ_ARCH)/RespectParser.o \
      $(OBJ_ARCH)/RespectMain.o \
      $(OBJ_ARCH)/RespectFilter.o \
      $(OBJ_ARCH)/PTMProphetParser.o \
      $(OBJ_ARCH)/PTMProphetMain.o \
      $(OBJ_ARCH)/PTMProphet.o \
      $(OBJ_ARCH)/PTMProphetMpx.o \
      $(OBJ_ARCH)/RTCatalog.o \
      $(OBJ_ARCH)/GradientProgram.o \
      $(OBJ_ARCH)/RTCatalogParser.o \
      $(OBJ_ARCH)/RTCalculatorMain.o \
      $(OBJ_ARCH)/RTCatalogParserMain.o \
      $(OBJ_ARCH)/InterProphet.o \
      $(OBJ_ARCH)/SearchHit.o \
      $(OBJ_ARCH)/MascotDiscrimFunction.o \
      $(OBJ_ARCH)/MascotDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/MascotResult.o \
      $(OBJ_ARCH)/MascotScoreParser.o \
      $(OBJ_ARCH)/MassDifferenceDiscrMixtureDistr.o \
      $(OBJ_ARCH)/MixtureDistr.o \
      $(OBJ_ARCH)/MixtureDistrFactory.o \
      $(OBJ_ARCH)/MixtureModel.o \
      $(OBJ_ARCH)/ModificationInfo.o \
      $(OBJ_ARCH)/ModifiedResidueMass.o \
      $(OBJ_ARCH)/MzDifferenceDiscrMixtureDistr.o \
      $(OBJ_ARCH)/NMCMixtureDistr.o \
      $(OBJ_ARCH)/NonParametricDistribution.o \
      $(OBJ_ARCH)/Fit.o \
      $(OBJ_ARCH)/Normalization.o \
      $(OBJ_ARCH)/NTTMixtureDistr.o \
      $(OBJ_ARCH)/KDModel.o \
      $(OBJ_ARCH)/BoolModel.o \
      $(OBJ_ARCH)/Option.o \
      $(OBJ_ARCH)/OrderedResult.o \
      $(OBJ_ARCH)/OuterTag.o \
      $(OBJ_ARCH)/Parser.o \
      $(OBJ_ARCH)/PeptideProphetOptions.o \
      $(OBJ_ARCH)/PeptideProphetParser.o \
      $(OBJ_ARCH)/PhenyxDiscrimFunction.o \
      $(OBJ_ARCH)/PhenyxDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/PhenyxResult.o \
      $(OBJ_ARCH)/PhenyxZscore.o \
      $(OBJ_ARCH)/CruxDiscrimFunction.o \
      $(OBJ_ARCH)/CruxDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/CruxResult.o \
      $(OBJ_ARCH)/OMSSADiscrimFunction.o \
      $(OBJ_ARCH)/OMSSADiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/OMSSAResult.o \
      $(OBJ_ARCH)/OMSSAEscore.o \
      $(OBJ_ARCH)/OMSSAPscore.o \
      $(OBJ_ARCH)/YABSEDiscrimFunction.o \
      $(OBJ_ARCH)/YABSEDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/YABSEResult.o \
      $(OBJ_ARCH)/YABSELDAscore.o \
      $(OBJ_ARCH)/MyrimatchDiscrimFunction.o \
      $(OBJ_ARCH)/MyrimatchDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/MyrimatchResult.o \
      $(OBJ_ARCH)/MyrimatchMVHscore.o \
      $(OBJ_ARCH)/MSGFDBDiscrimFunction.o \
      $(OBJ_ARCH)/MSGFDBDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/MSGFPLDiscrimFunction.o \
      $(OBJ_ARCH)/MSGFPLDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/MSGFPLResult.o \
      $(OBJ_ARCH)/MSGFDBResult.o \
      $(OBJ_ARCH)/MSGFDB_MSGFscore.o \
      $(OBJ_ARCH)/MSGFPL_MSGFscore.o \
      $(OBJ_ARCH)/InspectDiscrimFunction.o \
      $(OBJ_ARCH)/InspectDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/InspectResult.o \
      $(OBJ_ARCH)/InspectMQscore.o \
      $(OBJ_ARCH)/InspectFscore.o \
      $(OBJ_ARCH)/pICalculator.o \
      $(OBJ_ARCH)/pIMixtureDistr.o \
      $(OBJ_ARCH)/ProbIDDiscrimFunction.o \
      $(OBJ_ARCH)/ProbIDDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/ProbIDResult.o \
      $(OBJ_ARCH)/ProDataComponent.o \
      $(OBJ_ARCH)/ProteolyticEnzyme.o \
      $(OBJ_ARCH)/ProteolyticEnzymeFactory.o \
      $(OBJ_ARCH)/PvalueModel.o \
      $(OBJ_ARCH)/Q3ProteinRatioParser.o \
      $(OBJ_ARCH)/Q3GroupPeptideParser.o \
      $(OBJ_ARCH)/random_access_compressed_ifstream.o \
      $(OBJ_ARCH)/random_access_gzFile.o \
      $(OBJ_ARCH)/ResidueMass.o \
      $(OBJ_ARCH)/RTCalculator.o \
      $(OBJ_ARCH)/RTMixtureDistr.o \
      $(OBJ_ARCH)/SearchParams.o \
      $(OBJ_ARCH)/SearchResult.o \
      $(OBJ_ARCH)/SequestDiscrimFunction.o \
      $(OBJ_ARCH)/SequestHit.o \
      $(OBJ_ARCH)/SequestOut.o \
      $(OBJ_ARCH)/SequestParams.o \
      $(OBJ_ARCH)/SequestResult.o \
      $(OBJ_ARCH)/SpectraSTDiscrimFunction.o \
      $(OBJ_ARCH)/SpectraSTDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/SpectraSTResult.o \
      $(OBJ_ARCH)/Spectrum.o \
      $(OBJ_ARCH)/spectStrct.o \
      $(OBJ_ARCH)/Tag.o \
      $(OBJ_ARCH)/TagFilter.o \
      $(OBJ_ARCH)/TagListComparator.o \
      $(OBJ_ARCH)/TandemDiscrimFunction.o \
      $(OBJ_ARCH)/TandemDiscrimValMixtureDistr.o \
      $(OBJ_ARCH)/TandemKscoreDF.o \
      $(OBJ_ARCH)/TandemHRKscoreDF.o \
      $(OBJ_ARCH)/TandemNativeDF.o \
      $(OBJ_ARCH)/TandemResult.o \
      $(OBJ_ARCH)/ToftofAbbrevSequestDiscrimFunction.o \
      $(OBJ_ARCH)/tpp_tarball.o \
      $(OBJ_ARCH)/TPPVersionInfo.o \
      $(OBJ_ARCH)/UniquePeptide.o \
      $(OBJ_ARCH)/util.o \
      $(OBJ_ARCH)/AccurateMassDiffDiscrMixtureDistr.o \
      $(OBJ_ARCH)/VariableOffsetMassDiffDiscrMixtureDistr.o \
      $(OBJ_ARCH)/VariableOffsetpIMixtureDistr.o \
      $(OBJ_ARCH)/KernelDensityPIMixtureDistr.o \
      $(OBJ_ARCH)/KernelDensityRTMixtureDistr.o \
      $(OBJ_ARCH)/wglob.o \
      $(OBJ_ARCH)/win32_system.o \
      $(OBJ_ARCH)/XPressPeptideParserTagListComparator.o \
	  $(TPP_MSDATA_READER_OBJS)  
	ar -r $@ $^ 


_PeptideProphetParser : $(OBJ_ARCH)/PeptideProphetParser

$(OBJ_ARCH)/PeptideProphetParser: $(OBJ_ARCH)/PeptideProphetParserMain.o $(OBJ_ARCH)/PeptideProphetParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS) 

_InterProphetParser : $(OBJ_ARCH)/InterProphetParser

_RespectParser : $(OBJ_ARCH)/RespectParser

_PTMProphetParser : $(OBJ_ARCH)/PTMProphetParser

_PVProphet : $(OBJ_ARCH)/PVProphet

_RTCalc : $(OBJ_ARCH)/RTCalc

_RTCatalogParser : $(OBJ_ARCH)/RTCatalogParser

$(OBJ_ARCH)/InterProphetParser: $(OBJ_ARCH)/InterProphetMain.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

$(OBJ_ARCH)/PTMProphetParser:  $(OBJ_ARCH)/PTMProphetMain.o $(OBJ_ARCH)/KDModel.o $(OBJ_ARCH)/PTMProphet.o $(OBJ_ARCH)/PTMProphetMpx.o $(OBJ_ARCH)/PTMProphetParser.o $(SPECTRAST_LIB) $(TPPLIB) 
	$(LD) $(DEBUG)  $(OPT) -o $@ $^ $(LDFLAGS)

$(OBJ_ARCH)/RespectParser:  $(OBJ_ARCH)/RespectMain.o $(OBJ_ARCH)/RespectFilter.o $(OBJ_ARCH)/RespectParser.o $(SPECTRAST_LIB) $(TPPLIB) 
	$(LD) $(DEBUG)  $(OPT) -o $@ $^ $(LDFLAGS)

$(OBJ_ARCH)/RTCalc: $(OBJ_ARCH)/RTCalculatorMain.o  $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)
	cp Parsers/Algorithm2XML/RTCalc.coeff $(OBJ_ARCH)

$(OBJ_ARCH)/RTCatalogParser: $(OBJ_ARCH)/GradientProgram.o $(OBJ_ARCH)/RTCatalogParserMain.o   $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_decoyFASTA: $(OBJ_ARCH)/decoyFASTA

$(OBJ_ARCH)/decoyFASTA: $(OBJ_ARCH)/decoyFASTA.o
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_ProteinProphet: $(OBJ_ARCH)/ProteinProphet

$(OBJ_ARCH)/ProteinProphet: $(OBJ_ARCH)/ProteinProphet.o $(OBJ_ARCH)/ppPeptide.o $(TPPLIB)  $(OBJ_ARCH)/ppProtein.o $(OBJ_ARCH)/ppParentProtein.o $(OBJ_ARCH)/ppSpectrum.o 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS) $(BOOST_REGEX_LIB) $(PTHREAD_LIB)

_EnzymeDigestionParser: $(OBJ_ARCH)/EnzymeDigestionParser

$(OBJ_ARCH)/EnzymeDigestionParser: $(OBJ_ARCH)/EnzymeDigestionParserMain.o $(OBJ_ARCH)/EnzymeDigestionParser.o $(OBJ_ARCH)/ProteolyticEnzymeFactory.o $(OBJ_ARCH)/ProteolyticEnzyme.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^  $(LDFLAGS) 

_XPressPeptideParser: $(OBJ_ARCH)/XPressPeptideParser

$(OBJ_ARCH)/XPressPeptideParser: $(OBJ_ARCH)/XPressPeptideParserMain.o $(OBJ_ARCH)/XPressPeptideParser.o $(TPPLIB)   
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_ASAPRatioPeptideParser: $(OBJ_ARCH)/ASAPRatioPeptideParser

$(OBJ_ARCH)/ASAPRatioPeptideParser: $(OBJ_ARCH)/ASAPRatioPeptideParserMain.o $(OBJ_ARCH)/ASAPRatioPeptideParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_xpress-prophet-update.cgi : $(OBJ_ARCH)/xpress-prophet-update.cgi 

$(OBJ_ARCH)/xpress-prophet-update.cgi : $(OBJ_ARCH)/XPressCGIParser.o $(OBJ_ARCH)/xpresscgimain.o $(TPPLIB) 
	$(LD) $(DEBUG)  $(OPT) -o $@ $^ $(LDFLAGS)	

_ASAPRatioPeptideCGIDisplayParser.cgi: $(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.cgi

$(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.cgi: $(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParserMain.o $(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.o $(OBJ_ARCH)/ASAPRatioPeptideUpdateParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_ASAPRatioProteinRatioParser : $(OBJ_ARCH)/ASAPRatioProteinRatioParser 

$(OBJ_ARCH)/ASAPRatioProteinRatioParser : $(OBJ_ARCH)/ASAPRatioProteinRatioParserMain.o $(OBJ_ARCH)/ASAPRatioProteinRatioParser.o $(OBJ_ARCH)/ASAPRatioGroupPeptideParser.o $(OBJ_ARCH)/ASAPProteinRatio.o $(OBJ_ARCH)/ASAPRatioPeptideParser.o $(OBJ_ARCH)/ASAPRatioMSMSSeqData.o $(OBJ_ARCH)/ASAPRatioPvalueParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_ASAPCGIDisplay.cgi : $(OBJ_ARCH)/ASAPCGIDisplay.cgi 

$(OBJ_ARCH)/ASAPCGIDisplay.cgi : $(OBJ_ARCH)/ASAPCGIDisplay2Main.o $(OBJ_ARCH)/ASAPRatioProteinCGIDisplayParser.o $(OBJ_ARCH)/ASAPCGIDisplayParser.o $(OBJ_ARCH)/ASAPCGIParser.o $(TPPLIB)   
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_InteractParser: $(OBJ_ARCH)/InteractParser

$(OBJ_ARCH)/InteractParser: $(OBJ_ARCH)/InteractParserMain.o $(OBJ_ARCH)/InteractParser.o $(TPPLIB)  $(EXPAT_LIB)
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS) 

_DatabaseParser: $(OBJ_ARCH)/DatabaseParser

$(OBJ_ARCH)/DatabaseParser: $(OBJ_ARCH)/DatabaseParserMain.o $(OBJ_ARCH)/DatabaseParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_crypt: $(OBJ_ARCH)/crypt

$(OBJ_ARCH)/crypt: $(OBJ_ARCH)/crypt.o
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_RefreshParser: $(OBJ_ARCH)/RefreshParser

ifeq (${LGPL},1)
$(OBJ_ARCH)/RefreshParser: $(OBJ_ARCH)/RefreshParserMain.o spareparts.a $(OBJ_ARCH)/RefreshParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)
else
$(OBJ_ARCH)/kwset.o : kwset.cxx

$(OBJ_ARCH)/obstack.o : obstack.cxx

$(OBJ_ARCH)/RefreshParser: $(OBJ_ARCH)/RefreshParserMain.o $(OBJ_ARCH)/RefreshParser.o $(OBJ_ARCH)/kwset.o $(OBJ_ARCH)/obstack.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)
endif

_MzXML2Search: $(OBJ_ARCH)/MzXML2Search

$(OBJ_ARCH)/MzXML2Search: $(OBJ_ARCH)/MzXML2Search.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_ModelParser.cgi : $(OBJ_ARCH)/ModelParser.cgi 

$(OBJ_ARCH)/ModelParser.cgi : $(OBJ_ARCH)/ModelParserMain.o $(OBJ_ARCH)/ModelParser.o $(TPPLIB) 
	$(LD) $(DEBUG) $(OPT) -o $@ $^ $(LDFLAGS)

_iModelParser.cgi : $(OBJ_ARCH)/iModelParser.cgi 

$(OBJ_ARCH)/iModelParser.cgi : $(OBJ_ARCH)/IModelParserMain.o $(OBJ_ARCH)/IModelParser.o $(TPPLIB) 
	$(LD) $(DEBUG) $(OPT) -o $@ $^ $(LDFLAGS)

_tpp_hostname: $(OBJ_ARCH)/tpp_hostname

$(OBJ_ARCH)/tpp_hostname: $(OBJ_ARCH)/tpp_hostname.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_run_in: $(OBJ_ARCH)/run_in

$(OBJ_ARCH)/run_in: $(OBJ_ARCH)/run_in.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_setWin32Permissions: $(OBJ_ARCH)/setWin32Permissions

$(OBJ_ARCH)/setWin32Permissions: $(OBJ_ARCH)/setWin32Permissions.o 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_XPressPeptideUpdateParser.cgi: $(OBJ_ARCH)/XPressPeptideUpdateParser.cgi

$(OBJ_ARCH)/XPressPeptideUpdateParser.cgi: $(OBJ_ARCH)/XPressPeptideUpdateParserMain.o $(OBJ_ARCH)/XPressPeptideUpdateParser.o  $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^  $(GD_LIB) $(LDFLAGS)

_XPressProteinRatioParser : $(OBJ_ARCH)/XPressProteinRatioParser 

$(OBJ_ARCH)/XPressProteinRatioParser : $(OBJ_ARCH)/XPressProteinRatioParserMain.o $(OBJ_ARCH)/XPressProteinRatioParser.o $(OBJ_ARCH)/XPressGroupPeptideParser.o  $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_XPressCGIProteinDisplayParser.cgi : $(OBJ_ARCH)/XPressCGIProteinDisplayParser.cgi 

$(OBJ_ARCH)/XPressCGIProteinDisplayParser.cgi : $(OBJ_ARCH)/XPressCGIProteinDisplayMain.o $(OBJ_ARCH)/XPressProteinRatioParser.o $(OBJ_ARCH)/XPressCGIProteinDisplay.o $(OBJ_ARCH)/XPressGroupPeptideParser.o  $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Q3ProteinRatioParser : $(OBJ_ARCH)/Q3ProteinRatioParser 

$(OBJ_ARCH)/Q3ProteinRatioParser : $(OBJ_ARCH)/Q3ProteinRatioParserMain.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^  $(LDFLAGS)

_ASAPRatioPvalueParser : $(OBJ_ARCH)/ASAPRatioPvalueParser 

$(OBJ_ARCH)/ASAPRatioPvalueParser : $(OBJ_ARCH)/ASAPRatioPvalueParserMain.o $(OBJ_ARCH)/ASAPRatioPvalueParser.o $(TPPLIB)  
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_LibraPeptideParser : $(OBJ_ARCH)/LibraPeptideParser 

$(OBJ_ARCH)/LibraPeptideParser : $(OBJ_ARCH)/LibraPeptideParserMain.o $(OBJ_ARCH)/LibraPeptideParser.o $(OBJ_ARCH)/Intensity.o $(OBJ_ARCH)/Quantitation.o $(OBJ_ARCH)/LibraConditionHandler.o $(OBJ_ARCH)/LibraResult.o $(OBJ_ARCH)/LibraSummary.o $(OBJ_ARCH)/LibraWrapper.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_LibraProteinRatioParser : $(OBJ_ARCH)/LibraProteinRatioParser 

$(OBJ_ARCH)/LibraProteinRatioParser : $(OBJ_ARCH)/LibraProteinRatioParserMain.o $(OBJ_ARCH)/LibraProteinRatioParser.o $(OBJ_ARCH)/LibraGroupPeptideParser.o $(OBJ_ARCH)/LibraConditionHandler2.o $(OBJ_ARCH)/StringConvertor.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Pep3D_xml.cgi : $(OBJ_ARCH)/Pep3D_xml.cgi

$(OBJ_ARCH)/Pep3D_xml.cgi : $(OBJ_ARCH)/cgi_Pep3D_xml.o $(OBJ_ARCH)/Pep3D_functions.o $(OBJ_ARCH)/Pep3DParser.o $(OBJ_ARCH)/BasenameParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(GD_LIB) $(LDFLAGS)

_ShowXIC.cgi : $(OBJ_ARCH)/ShowXIC.cgi 

$(OBJ_ARCH)/ShowXIC.cgi : $(OBJ_ARCH)/ShowXIC.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(GD_LIB) $(LDFLAGS)


_disCidData_xml.cgi: $(OBJ_ARCH)/disCidData_xml.cgi

$(OBJ_ARCH)/disCidData_xml.cgi: $(OBJ_ARCH)/cgi_disCidData.o $(OBJ_ARCH)/util.o $(OBJ_ARCH)/Pep3D_functions.o $(OBJ_ARCH)/SpectrumParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_getCidData_xml.cgi: $(OBJ_ARCH)/getCidData_xml.cgi

$(OBJ_ARCH)/getCidData_xml.cgi: $(OBJ_ARCH)/cgi_getCidData.o $(OBJ_ARCH)/Pep3D_functions.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_AnalysisSummaryParser.cgi : $(OBJ_ARCH)/AnalysisSummaryParser.cgi 

$(OBJ_ARCH)/AnalysisSummaryParser.cgi : $(OBJ_ARCH)/AnalysisSummaryParserMain.o $(OBJ_ARCH)/AnalysisSummaryParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_CompactParser : $(OBJ_ARCH)/CompactParser 

$(OBJ_ARCH)/CompactParser : $(OBJ_ARCH)/CompactParserMain.o $(OBJ_ARCH)/CompactParser.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Sequest2XML : $(OBJ_ARCH)/Sequest2XML 

$(OBJ_ARCH)/Sequest2XML : $(OBJ_ARCH)/Sequest2XML.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Out2XML : $(OBJ_ARCH)/Out2XML 

$(OBJ_ARCH)/Out2XML : $(OBJ_ARCH)/Out2XMLMain.o $(OBJ_ARCH)/Out2XML.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Sqt2XML : $(OBJ_ARCH)/Sqt2XML 

$(OBJ_ARCH)/Sqt2XML : $(OBJ_ARCH)/Sqt2XML.o $(OBJ_ARCH)/SimpleXMLWriter.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_CombineOut : $(OBJ_ARCH)/CombineOut 

$(OBJ_ARCH)/CombineOut : $(OBJ_ARCH)/CombineOutMain.o $(OBJ_ARCH)/CombineOut.o $(OBJ_ARCH)/Out2XML.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_Mascot2XML : $(OBJ_ARCH)/Mascot2XML 

$(OBJ_ARCH)/Mascot2XML : $(OBJ_ARCH)/MascotConverterMain.o $(OBJ_ARCH)/MascotConverter.o $(OBJ_ARCH)/MascotModification.o $(TPPLIB)  $(LIBARCHIVE)
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

# build archive library?
ifeq (${ARCH_FAMILY},mingw)
$(LIBARCHIVE):
	@if [ ! -e $(LIBARCHIVE_DIR) ]; then echo Error: libarchive source not found!; exit -1; fi;
	@if [ ! -e $(LIBARCHIVE_DIR)/.libs/libarchive.a ]; then echo building libarchive library; cd $(LIBARCHIVE_DIR); chmod 777 configure; ./configure -disable-shared; make -i clean all; fi;
        # libarchive libtool problems are not unusual, attempt to roll our own if need be
	@if [ ! -e $(LIBARCHIVE_DIR)/.libs/libarchive.a ]; then mkdir -p $(LIBARCHIVE_DIR)/.libs; ar -cr $(LIBARCHIVE_DIR)/.libs/libarchive.a $(LIBARCHIVE_DIR)/libarchive/*.o; fi;
	@cp $(LIBARCHIVE_DIR)/.libs/libarchive.a $(OBJ_ARCH)/libarchive.a
else
$(LIBARCHIVE):
	@if [ ! -e $(LIBARCHIVE_TGZ) ]; then echo Error: libarchive source TGZ not found!; exit -1; fi;
	@if [ ! -e $(LIBARCHIVE_DIR)/configure ];  then echo uncompressing libarchive library; mkdir -p $(LIBARCHIVE_DIR); cd $(LIBARCHIVE_DIR)/.. ; tar zxf $(LIBARCHIVE_TGZ); fi;
	@if [ ! -e $(LIBARCHIVE_DIR) ]; then echo Error: libarchive source not found! uncompression failed; exit -1; fi;
	@if [ ! -e $(LIBARCHIVE_DIR)/.libs/libarchive.a ]; then echo building libarchive library; cd $(LIBARCHIVE_DIR); chmod 777 configure; ./configure -disable-shared; make -i clean all; fi;
        # libarchive libtool problems are not unusual, attempt to roll our own if need be
	@if [ ! -e $(LIBARCHIVE_DIR)/.libs/libarchive.a ]; then mkdir -p $(LIBARCHIVE_DIR)/.libs; ar -cr $(LIBARCHIVE_DIR)/.libs/libarchive.a $(LIBARCHIVE_DIR)/libarchive/*.o; fi;
	@cp $(LIBARCHIVE_DIR)/.libs/libarchive.a $(OBJ_ARCH)/libarchive.a
endif


_Tandem2XML : $(OBJ_ARCH)/Tandem2XML 

$(OBJ_ARCH)/Tandem2XML : $(OBJ_ARCH)/Tandem2xml.o $(OBJ_ARCH)/TandemParamsParser.o $(OBJ_ARCH)/TandemResultsParser.o $(OBJ_ARCH)/masscalc.o $(OBJ_ARCH)/saxtandemhandler.o $(TPPLIB)  $(EXPAT_LIB)
	 $(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_comet-pepxml.cgi : $(OBJ_ARCH)/comet-pepxml.cgi 

$(OBJ_ARCH)/comet-pepxml.cgi :  $(OBJ_ARCH)/comet-pepxml.o $(TPPLIB)
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_comet-fastadb.cgi : $(OBJ_ARCH)/comet-fastadb.cgi 

$(OBJ_ARCH)/comet-fastadb.cgi :  $(OBJ_ARCH)/comet-fastadb1.o $(OBJ_ARCH)/calc_pI.o $(TPPLIB)  
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_plot-msms.cgi : $(OBJ_ARCH)/plot-msms.cgi  $(OBJ_ARCH)/plot-msms-js.cgi 

$(OBJ_ARCH)/plot-msms.cgi :  $(OBJ_ARCH)/plot-msms1.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

$(OBJ_ARCH)/plot-msms-js.cgi :  $(OBJ_ARCH)/plot-msms-js.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_dta-xml.cgi : $(OBJ_ARCH)/dta-xml.cgi 

$(OBJ_ARCH)/dta-xml.cgi :  $(OBJ_ARCH)/dta-xml.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_sequest-tgz-out.cgi : $(OBJ_ARCH)/sequest-tgz-out.cgi 

$(OBJ_ARCH)/sequest-tgz-out.cgi :  $(OBJ_ARCH)/sequest-tgz-out1.o $(TPPLIB)  $(LIBARCHIVE)
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_cometresult.cgi : $(OBJ_ARCH)/cometresult.cgi 

$(OBJ_ARCH)/cometresult.cgi : $(OBJ_ARCH)/cometresult1.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

SPECTRAST_DEPENDS= $(TPPLIB)  Search/SpectraST/*.cpp Search/SpectraST/*.hpp  Search/SpectraST/Makefile

_plotspectrast : $(OBJ_ARCH)/plotspectrast 

$(OBJ_ARCH)/plotspectrast :  $(SPECTRAST_DEPENDS)
	cd Search/SpectraST; make all 

_plotspectrast.cgi : $(OBJ_ARCH)/plotspectrast.cgi 

$(OBJ_ARCH)/plotspectrast.cgi : $(SPECTRAST_DEPENDS)
	cd Search/SpectraST; make all

_spectrast : $(OBJ_ARCH)/spectrast 

$(SPECTRAST_LIB) : $(SPECTRAST_DEPENDS)
	cd Search/SpectraST; make lib

$(OBJ_ARCH)/spectrast : $(SPECTRAST_DEPENDS)
	cd Search/SpectraST; make all

_Lib2HTML : $(OBJ_ARCH)/Lib2HTML 

$(OBJ_ARCH)/Lib2HTML : $(SPECTRAST_DEPENDS)
	cd Search/SpectraST; make all

_pep_dbcount : $(OBJ_ARCH)/pep_dbcount 

$(OBJ_ARCH)/pep_dbcount :
	make -C util $(OBJ_ARCH)/pep_dbcount SRC_ROOT='$(SRC_ROOT)'

_subsetdb : $(OBJ_ARCH)/subsetdb 

$(OBJ_ARCH)/subsetdb :
	make -C util $(OBJ_ARCH)/subsetdb SRC_ROOT='$(SRC_ROOT)'

_digestdb : $(OBJ_ARCH)/digestdb 

$(OBJ_ARCH)/digestdb :
	make -C util $(OBJ_ARCH)/digestdb SRC_ROOT='$(SRC_ROOT)'

_add_mz : $(OBJ_ARCH)/add_mz 

$(OBJ_ARCH)/add_mz :
	make -C util $(OBJ_ARCH)/add_mz SRC_ROOT='$(SRC_ROOT)'

_calculate_pi : $(OBJ_ARCH)/calculate_pi 

$(OBJ_ARCH)/calculate_pi :
	make -C util $(OBJ_ARCH)/calculate_pi SRC_ROOT='$(SRC_ROOT)'

_translateDNA2AA-FASTA : $(OBJ_ARCH)/translateDNA2AA-FASTA 

$(OBJ_ARCH)/translateDNA2AA-FASTA :
	make -C util $(OBJ_ARCH)/translateDNA2AA-FASTA SRC_ROOT='$(SRC_ROOT)'

_xinteract : $(OBJ_ARCH)/xinteract 

$(OBJ_ARCH)/xinteract : $(OBJ_ARCH)/xinteract.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_runperl: $(OBJ_ARCH)/runperl

$(OBJ_ARCH)/runperl: $(OBJ_ARCH)/runperl.o $(TPPLIB) 
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_PepXMLViewer.cgi: $(OBJ_ARCH)/PepXMLViewer.cgi

$(OBJ_ARCH)/PepXMLViewer.cgi: $(BOOST_REGEX_LIB) $(EXPAT_LIB) $(OBJ_ARCH)/TPPVersionInfo.o $(TPP_BUILD) $(PWIZ_LIB) $(BOOST_LIBS) $(GZSTREAMLIB) $(LIBARCHIVE) Visualization/PepXMLViewer/*.cxx Visualization/PepXMLViewer/*.h
	cd Visualization/PepXMLViewer; make

_indexmzXML: $(OBJ_ARCH)/indexmzXML

$(OBJ_ARCH)/indexmzXML: $(OBJ_ARCH)/TPPVersionInfo.o $(OBJ_ARCH)/libtpp.a mzXML/tools/mzXMLIndexer/*.cpp mzXML/tools/mzXMLIndexer/*.cpp
	cd mzXML/tools/mzXMLIndexer; make

_out2summary: $(OBJ_ARCH)/out2summary

$(OBJ_ARCH)/out2summary: $(OBJ_ARCH)/out2summary.o $(TPPLIB)  $(LIBARCHIVE)
	$(LD) $(DEBUG)   $(OPT) -o $@ $^ $(LDFLAGS)

_runsearch: $(OBJ_ARCH)/runsearch

$(OBJ_ARCH)/runsearch: $(OBJ_ARCH)/runsearch1.o $(TPPLIB) 
	$(LD) $(DEBUG)    $(OPT) -o $@ $^ $(LDFLAGS)

_dtafilter: $(OBJ_ARCH)/dtafilter

$(OBJ_ARCH)/dtafilter: $(OBJ_ARCH)/dtafilter1.o $(TPPLIB) 
	$(LD) $(DEBUG)    $(OPT) -o $@ $^ $(LDFLAGS)

_readmzXML: $(OBJ_ARCH)/readmzXML

$(OBJ_ARCH)/readmzXML: $(OBJ_ARCH)/readmzXML.o $(TPPLIB)
	$(LD) $(DEBUG)    $(OPT) -o $@ $^ $(LDFLAGS)

_dta2mzxml: $(OBJ_ARCH)/dta2mzxml

$(OBJ_ARCH)/dta2mzxml:
	make -C mzXML/converters/dta2mzxml

_mzParser : $(MZPARSER_BUILD)

_ramp : $(RAMP_BUILD)

$(OBJ_ARCH)/mzp_base64.mzp.o : mzp_base64.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/MSNumpress.mzp.o : MSNumpress.cpp $(SRC_ROOT)Parsers/mzParser/MSNumpress.hpp

$(OBJ_ARCH)/BasicChromatogram.mzp.o : BasicChromatogram.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/BasicSpectrum.mzp.o : BasicSpectrum.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/saxhandler.mzp.o : saxhandler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/saxmzmlhandler.mzp.o :  $(OBJ_ARCH)/MSNumpress.mzp.o $(OBJ_ARCH)/saxhandler.mzp.o  saxmzmlhandler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/saxmzxmlhandler.mzp.o :  $(OBJ_ARCH)/saxhandler.mzp.o  saxmzxmlhandler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/mz5handler.mzp.o :  mzpMz5Config.cpp  mzpMz5Structs.cpp  mz5handler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/RAMPface.mzp.o : $(OBJ_ARCH)/MSNumpress.mzp.o $(OBJ_ARCH)/saxhandler.mzp.o $(OBJ_ARCH)/saxmzxmlhandler.mzp.o  $(OBJ_ARCH)/saxmzmlhandler.mzp.o   $(OBJ_ARCH)/mz5handler.mzp.o  saxmzmlhandler.cpp  saxmzxmlhandler.cpp  saxhandler.cpp RAMPface.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/PWIZface.mzp.o : $(OBJ_ARCH)/MSNumpress.mzp.o $(OBJ_ARCH)/BasicChromatogram.mzp.o $(OBJ_ARCH)/saxhandler.mzp.o $(OBJ_ARCH)/saxmzxmlhandler.mzp.o  $(OBJ_ARCH)/saxmzmlhandler.mzp.o   $(OBJ_ARCH)/mz5handler.mzp.o  BasicChromatogram.cpp saxmzmlhandler.cpp  saxmzxmlhandler.cpp  saxhandler.cpp PWIZface.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/mzParser.mzp.o : mzParser.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/Czran.mzp.o : Czran.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/mzpMz5Config.mzp.o :  mzpMz5Config.cpp  mzpMz5Structs.cpp  mz5handler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/mzpMz5Structs.mzp.o :  mzpMz5Structs.cpp  mz5handler.cpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h

$(OBJ_ARCH)/mzParser :
	cd Parsers/mzParser; make all

clean: xtandem-clean pwiz-clean
	rm -rf $(OBJ_ARCH)/*
	rm -f *.o *.a *.exe *.cgi $(EXE) core* ../COVERAGE/$(ARCH)/* ../COVERAGE/*.o ../COVERAGE/*.exe refresh_interact/*.o $(FASTAR_DIR)/*.o $(FASTAR_DIR)/fastar/*.exe
	cd Visualization/PepXMLViewer; make clean
	cd Search/SpectraST; make clean
	cd util; make clean
	make -C mzXML/tools/mzXMLIndexer clean
	make -C mzXML/converters/dta2mzxml clean

# Isn't distclean a realclean for our implementation?
distclean: clean xtandem-clean pwiz-clean expat-clean gsl-clean
	if [ -e $(LIBARCHIVE_DIR) ]; then cd $(LIBARCHIVE_DIR); if [ -e Makefile ]; then make distclean; fi; fi
	cd ../extern; rm -rf json ; rm -rf jfreechart-1.0.9 ; rm -rf GWT

realclean : clean xtandem-clean pwiz-clean expat-realclean gsl-realclean
	if [ -e $(LIBARCHIVE_DIR) ]; then cd $(LIBARCHIVE_DIR); if [ -e Makefile ]; then make distclean; fi; fi
	cd ../extern; rm -rf json ; rm -rf jfreechart-1.0.9 ; rm -rf GWT

LGPL:
	LGPL='1' make all

opt:
	CCOPT='-O' make all

XTANDEM_SRCDIR = ../extern/xtandem/src_tpp

ifneq (${ARCH},darwin)
XTANDEM_ZLIB_LIB=$(ZLIB_LIB)
else
# on os x 10.7, make will balk at "-lz" as a build dependency
XTANDEM_ZLIB_LIB=
endif

.PHONY: xtandem tandem

xtandem tandem : $(OBJ_ARCH)/tandem

$(OBJ_ARCH)/tandem: $(EXPAT_LIB) $(XTANDEM_ZLIB_LIB) $(HDF5_LIB) $(MZPARSER_BUILD) $(OBJ_ARCH)/TPPVersionInfo.o | $(OBJ_ARCH)
	LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" make -C $(XTANDEM_SRCDIR) TANDEM_PARAMETERS_INSTALL_DIR="${TANDEM_PARAMETERS_INSTALL_DIR}" SRC_ROOT="$(SRC_ROOT)" ARCH=$(ARCH) BUILD_DIR=$(OBJ_ARCH) EXPAT_LIB=$(EXPAT_LIB) ZLIB_INCL="$(ZLIB_INCL)" ZLIB_LIB="$(ZLIB_LIB)" HDF5_INCL="$(HDF5_INCL)" HDF5_LIB="$(HDF5_LIB)" MZPARSER_LIB="$(MZPARSER_BUILD)" MZPARSER_INCL="$(SRC_ROOT)Parsers/mzParser" USER_OBJS="$(OBJ_ARCH)/TPPVersionInfo.o"

xtandem-clean:
	make -C $(XTANDEM_SRCDIR) SRC_ROOT="$(SRC_ROOT)" ARCH=$(ARCH) BUILD_DIR=$(OBJ_ARCH) clean

xtandem-debug :
	DEBUG='-g' make xtandem

#
# Comet MS/MS search engine.  Just copy binary from extern/ instead of building
# from source.  Anly only support Win32 binaries at this time
#
COMET_PACKAGE = $(SRC_ROOT)../extern/Comet/binaries
COMET_VERSION = 2014022

.PHONY: comet comet-clean

comet : $(OBJ_ARCH)/comet

ifeq ($(ARCH_FAMILY),mingw)

$(OBJ_ARCH)/comet : $(COMET_PACKAGE)/comet.$(COMET_VERSION).win32.exe
	cp -f $^ $@.exe
	cd $(OBJ_ARCH); ./comet -p; mv comet.params.new comet.params

endif
ifeq ($(ARCH_FAMILY),linux)

$(OBJ_ARCH)/comet : $(COMET_PACKAGE)/comet.$(COMET_VERSION).linux.exe
	cp -f $^ $@
	chmod a+x $@
	cd $(OBJ_ARCH); ./comet -p; mv comet.params.new comet.params

endif
ifeq ($(COMET_EXE),)

   $(warn Skipping comet installation on ARCH_FAMILY $(ARCH_FAMILY))
$(OBJ_ARCH)/comet : 

endif

comet-clean :
	rm -f $(OBJ_ARCH)/comet*



#
# End of Comet 
#

windows:  # makefile is smarter now, don't really need this target
	make all;

ifeq (${XML_ONLY},1)
install-windows: install-windows-xml
else
install-windows: install-windows-all
endif

install-windows-xml:
	if ! test -d `cygpath -u ${TPP_ROOT}`; then \
		mkdir `cygpath -u ${TPP_ROOT}`;  fi
	if ! test -d `cygpath -u ${TPP_ROOT}`/bin; then \
		mkdir `cygpath -u ${TPP_ROOT}`/bin;  fi
	if ! test -d `cygpath -u ${TPP_ROOT}`/schema; then \
		mkdir `cygpath -u ${TPP_ROOT}`/schema;  fi
	cp -f ../schema/*.xsd ../schema/*.xsl `cygpath -u ${TPP_ROOT}`/schema
	cp -f $(OBJ_ARCH)/*.exe ../perl/*.pl `cygpath -u ${TPP_ROOT}`/bin

install-windows-all: 
	cp -f ../schema/*.xsd ../schema/*.xsl $$WEBSERVER_ROOT
	if ! test -d `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin; then \
		mkdir `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin;  fi
	cp -f $(OBJ_ARCH)/*.exe $(OBJ_ARCH)/*.coeff ../perl/*.pl ../perl/*.par /cygdrive/c/cygwin/bin
	cp -f $(OBJ_ARCH)/*.cgi `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f Visualization/Comet/tryp_model.txt `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f ../CGI/*.pl `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f ../HELP_DIR/*.* `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f ../images/*.* `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f ../extern/d3/*.js `cygpath -u $$WEBSERVER_ROOT`/ISB/html/js
	sed -i 's?/tpp/cgi-bin/?/tpp-bin/?g' `cygpath -u $$WEBSERVER_ROOT`/pepXML_std.xsl
	chmod -R a+xr `cygpath -u $$WEBSERVER_ROOT`/../tpp-bin
	cp -f Visualization/Comet/cometlinks.def `cygpath -u $$WEBSERVER_ROOT`
	chmod a+r `cygpath -u $$WEBSERVER_ROOT`/cometlinks.def
	make -C Visualization/PepXMLViewer/ install-windows


#
# dependencies (incomplete)
#
ifeq (${LGPL},1)
spareparts.a : 
	cd $(FASTAR_DIR); make all
	ar -rs spareparts.a $(FASTAR_DIR)/*.o $(FASTAR_DIR)/common/*.o
endif


$(OBJ_ARCH)/ProteinProphet.o: ppProtein.h $(BOOST_REGEX_LIB)

$(OBJ_ARCH)/xinteract.o : xinteract.cxx Array.h constants.h

$(OBJ_ARCH)/tpp_hostname.o : tpp_hostname.cpp sysdepend.h

$(OBJ_ARCH)/hooks_tpp.o : hooks_tpp.cxx hooks_tpp.h sysdepend.h

$(OBJ_ARCH)/XPressCGIParser.o : Tag.h TagFilter.h Parser.h XPressCGIParser.h XPressCGIParser.cxx

$(OBJ_ARCH)/xpresscgimain.o :  XPressCGIParser.h xpresscgimain.cxx

$(OBJ_ARCH)/SpectrumParser.o : SpectrumParser.cxx SpectrumParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ASAP_structs.h ProDataComponent.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H} ResidueMass.h constants.h $(SEARCHRESULTS_H) ASAPRatio_numFns.h MixtureDistrFactory.h

$(OBJ_ARCH)/crypt.o: crypt.cxx

$(OBJ_ARCH)/ShowXIC.o: ShowXIC.cxx ShowXIC.h

$(OBJ_ARCH)/cgi_Pep3D_xml.o: cgi_Pep3D_xml.cxx Pep3D_functions.h ${TPP_MSDATA_READER_H}  util.h constants.h ASAPRatio_numFns.h Pep3DParser.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h BasenameParser.h

$(OBJ_ARCH)/Pep3D_functions.o : Pep3D_functions.cxx Pep3D_functions.h ${TPP_MSDATA_READER_H}  constants.h ASAPRatio_numFns.h

$(OBJ_ARCH)/Pep3DParser.o : Pep3DParser.cxx Pep3DParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/Pep3DParserMain.o : Pep3DParserMain.cxx Pep3DParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/cgi_getCidData.o : cgi_getCidData.cxx Pep3D_functions.h ${TPP_MSDATA_READER_H}  constants.h ASAPRatio_numFns.h

$(OBJ_ARCH)/cgi_disCidData.o : cgi_disCidData.cxx Pep3D_functions.h ${TPP_MSDATA_READER_H}  constants.h ASAPRatio_numFns.h SpectrumParser.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h ASAP_structs.h ProDataComponent.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ResidueMass.h constants.h $(SEARCHRESULTS_H)

$(OBJ_ARCH)/BasenameParser.o : BasenameParser.cxx BasenameParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/InteractParser.o : InteractParser.cxx InteractParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H} ModificationInfo.h SearchParams.h ResidueMass.h constants.h OuterTag.h

$(OBJ_ARCH)/InteractParserMain.o : InteractParserMain.cxx InteractParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H} ModificationInfo.h SearchParams.h ResidueMass.h constants.h OuterTag.h

$(OBJ_ARCH)/sequest-tgz-out1.o : sequest-tgz-out1.cxx Comet.h constants.h

$(OBJ_ARCH)/cometresult1.o : cometresult1.cxx Comet.h constants.h

$(OBJ_ARCH)/plot-msms1.o : plot-msms1.cxx AminoAcidMasses.h Comet.h constants.h

$(OBJ_ARCH)/plot-msms-js.o : plot-msms-js.cxx AminoAcidMasses.h Comet.h constants.h

$(OBJ_ARCH)/dta-xml.o : dta-xml.cpp constants.h

$(OBJ_ARCH)/spectStrct.o : spectStrct.cpp spectStrct.h

$(OBJ_ARCH)/mzParser.mzp.o : $(SRC_ROOT)Parsers/mzParser/mzParser.h  mzParser.cpp

$(OBJ_ARCH)/RAMPface.mzp.o : RAMPface.cpp saxmzxmlhandler.cpp saxhandler.cpp 

$(OBJ_ARCH)/mzp_cramp.mzp.o : mzp_cramp.cpp cramp.cpp $(SRC_ROOT)Parsers/mzParser/cramp.hpp  $(SRC_ROOT)Parsers/mzParser/mzParser.h  mzParser.cpp

$(OBJ_ARCH)/mzp_cached_ramp.mzp.o : mzp_cached_ramp.cpp $(SRC_ROOT)Parsers/mzParser/cached_ramp.h 

$(OBJ_ARCH)/tpp_tarball.o : $(LIBARCHIVE) tpp_tarball.h tpp_tarball.cpp 

$(OBJ_ARCH)/calc_pI.o : calc_pI.cxx

$(OBJ_ARCH)/comet-pepxml.o : comet-pepxml.cxx Comet.h constants.h util.h

$(OBJ_ARCH)/comet-fastadb1.o : comet-fastadb1.cxx AminoAcidMasses.h Comet.h constants.h ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Array.h Tag.h sysdepend.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h

$(OBJ_ARCH)/InterProphetMain.o: InterProphetMain.cxx InterProphetParser.cxx InterProphetParser.h InterProphet.cxx InterProphet.h KDModel.cxx KDModel.h BoolModel.cxx BoolModel.h

$(OBJ_ARCH)/RespectMain.o: RespectMain.cxx RespectParser.cxx RespectParser.h 

$(OBJ_ARCH)/RespectParser.o: RespectParser.cxx RespectParser.h 

$(OBJ_ARCH)/RespectFilter.o: RespectFilter.cxx RespectFilter.h 

$(OBJ_ARCH)/PTMProphetMain.o: PTMProphetMain.cxx PTMProphetParser.cxx PTMProphetParser.h KDModel.h

$(OBJ_ARCH)/PTMProphetParser.o: PTMProphetParser.cxx PTMProphetParser.h KDModel.h

$(OBJ_ARCH)/PTMProphet.o: PTMProphet.cxx PTMProphet.h 

$(OBJ_ARCH)/PTMProphetMpx.o: PTMProphetMpx.cxx PTMProphetMpx.h 

#$(OBJ_ARCH)/SRMProphetMain.o: SRMProphetMain.cxx SRMProphetParser.cxx SRMProphet.cxx 

$(OBJ_ARCH)/RTCalculatorMain.o: RTCalculatorMain.cxx RTCalculator.cxx RTCalculator.h RTCatalog.cxx RTCatalog.h

$(OBJ_ARCH)/GradientProgram.o: GradientProgram.cxx GradientProgram.h

$(OBJ_ARCH)/InterProphetParser.o: InterProphetParser.cxx InterProphetParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h InterProphet.cxx InterProphet.h MixtureModel.cxx MixtureModel.h

$(OBJ_ARCH)/InterProphet.o: InterProphet.h SearchHit.h InterProphet.cxx Array.h sysdepend.h constants.h  KDModel.h KDModel.cxx BoolModel.cxx BoolModel.h Tag.h MixtureModel.cxx MixtureModel.h
$(OBJ_ARCH)/SearchHit.o: SearchHit.h SearchHit.cxx

$(OBJ_ARCH)/KDModel.o: KDModel.h KDModel.cxx Array.h sysdepend.h constants.h Fit.h

$(OBJ_ARCH)/BoolModel.o: BoolModel.h BoolModel.cxx Array.h sysdepend.h constants.h Fit.h

$(OBJ_ARCH)/PeptideProphetMain.o : PeptideProphetMain.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h $(MIXTUREDISTRS_H) SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) MixtureModel.h $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Parser.h TagFilter.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/PeptideProphetParser.o : PeptideProphetParser.cxx PeptideProphetParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h ProteolyticEnzyme.h

$(OBJ_ARCH)/PeptideProphetParserMain.o : PeptideProphetParserMain.cxx MixtureDistrFactory.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(SEARCHRESULTS_H) $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) $(DISCRIMFUNCTIONS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Parser.h TagFilter.h pICalculator.h RTCalculator.h PeptideProphetParser.h MixtureModel.h Spectrum.h OrderedResult.h PeptideProphetOptions.h ProteolyticEnzyme.h

$(OBJ_ARCH)/PeptideProphetOptions.o : PeptideProphetOptions.cxx PeptideProphetOptions.h

$(OBJ_ARCH)/ModelParser.o : ModelParser.cxx ModelParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h PeptideProphetParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) pICalculator.h RTCalculator.h ProteolyticEnzyme.h

$(OBJ_ARCH)/ModelParserMain.o : ModelParserMain.cxx ModelParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h PeptideProphetParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h ProteolyticEnzyme.h

$(OBJ_ARCH)/IModelParser.o : IModelParser.cxx IModelParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h PeptideProphetParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h ProteolyticEnzyme.h

$(OBJ_ARCH)/IModelParserMain.o : IModelParserMain.cxx IModelParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h PeptideProphetParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) pICalculator.h RTCalculator.h ProteolyticEnzyme.h

$(OBJ_ARCH)/MixtureModel.o : MixtureModel.cxx MixtureModel.h $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Parser.h TagFilter.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/OrderedResult.o : OrderedResult.cxx OrderedResult.h

$(OBJ_ARCH)/Spectrum.o : Spectrum.cxx Spectrum.h

$(OBJ_ARCH)/ContinuousMultimixtureDistr.o : ContinuousMultimixtureDistr.cxx $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/DecayContinuousMultimixtureDistr.o : DecayContinuousMultimixtureDistr.cxx $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/DiscreteMixtureDistr.o : DiscreteMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/GlycMixtureDistr.o : GlycMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/PhosphoMixtureDistr.o : PhosphoMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ICATMixtureDistr.o : ICATMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MassDifferenceDiscrMixtureDistr.o : MassDifferenceDiscrMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/IsoMassDiffDiscrMixtureDistr.o : IsoMassDiffDiscrMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MzDifferenceDiscrMixtureDistr.o : MzDifferenceDiscrMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h SpectraSTResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MixtureDistr.o : MixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MixtureDistrFactory.o : MixtureDistrFactory.cxx MixtureDistrFactory.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(SEARCHRESULTS_H) $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) $(DISCRIMFUNCTIONS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Parser.h TagFilter.h pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/NMCMixtureDistr.o : NMCMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/NTTMixtureDistr.o : NTTMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/pIMixtureDistr.o : pIMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h pICalculator.h 

$(OBJ_ARCH)/RTMixtureDistr.o : RTMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h pICalculator.h 

$(OBJ_ARCH)/VariableOffsetMassDiffDiscrMixtureDistr.o : VariableOffsetMassDiffDiscrMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/AccurateMassDiffDiscrMixtureDistr.o : AccurateMassDiffDiscrMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/VariableOffsetpIMixtureDistr.o : VariableOffsetpIMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h pICalculator.h 

$(OBJ_ARCH)/KernelDensityPIMixtureDistr.o : KernelDensityPIMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h pICalculator.h 

$(OBJ_ARCH)/KernelDensityRTMixtureDistr.o : KernelDensityRTMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h RTCalculator.h 

$(OBJ_ARCH)/NonParametricDistribution.o : NonParametricDistribution.cxx $(DISTRIBUTIONS_H) ContinuousDistribution.cxx sysdepend.h constants.h Tag.h Array.h Fit.h

$(OBJ_ARCH)/Fit.o : Fit.cxx Fit.h

$(OBJ_ARCH)/ContinuousDistribution.o : ContinuousDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/DiscreteDistribution.o : DiscreteDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/Distribution.o : Distribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/ExtremeValueDistribution.o : ExtremeValueDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/GammaDistribution.o : GammaDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/GaussianDistribution.o : GaussianDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/GeneralizedGaussianDistribution.o : GeneralizedGaussianDistribution.cxx $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h Array.h

$(OBJ_ARCH)/DiscriminantFunction.o : DiscriminantFunction.cxx DiscriminantFunction.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/DiscrimValMixtureDistr.o : DiscrimValMixtureDistr.cxx $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) SequestResult.h

$(OBJ_ARCH)/ToftofAbbrevSequestDiscrimFunction.o : ToftofAbbrevSequestDiscrimFunction.cxx ToftofAbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h $(SEARCHRESULTS_H) SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h

$(OBJ_ARCH)/AbbrevSequestDiscrimFunction.o : AbbrevSequestDiscrimFunction.cxx AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h

$(OBJ_ARCH)/SequestDiscrimFunction.o : SequestDiscrimFunction.cxx SequestDiscrimFunction.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h

$(OBJ_ARCH)/ProbIDDiscrimFunction.o : ProbIDDiscrimFunction.cxx ProbIDDiscrimFunction.h DiscriminantFunction.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ProbIDResult.h

$(OBJ_ARCH)/ProbIDDiscrimValMixtureDistr.o : ProbIDDiscrimValMixtureDistr.cxx $(DISCRIMVALMIXTUREDISTRS_H) $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SequestResult.h ProbIDDiscrimFunction.h ProbIDResult.h $(DISTRIBUTIONS_H)

$(OBJ_ARCH)/MascotDiscrimFunction.o : MascotDiscrimFunction.cxx MascotDiscrimFunction.h DiscriminantFunction.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h MascotResult.h MascotScoreParser.h Parser.h TagFilter.h

$(OBJ_ARCH)/MascotDiscrimValMixtureDistr.o : MascotDiscrimValMixtureDistr.cxx $(DISCRIMVALMIXTUREDISTRS_H) $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SequestResult.h MascotDiscrimFunction.h MascotResult.h MascotScoreParser.h Parser.h TagFilter.h

$(OBJ_ARCH)/MascotScoreParser.o : MascotScoreParser.cxx MascotScoreParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/CometDiscrimFunction.o : CometDiscrimFunction.cxx CometDiscrimFunction.h DiscriminantFunction.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h CometResult.h

$(OBJ_ARCH)/CometDiscrimValMixtureDistr.o : CometDiscrimValMixtureDistr.cxx $(DISCRIMVALMIXTUREDISTRS_H) $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SequestResult.h CometDiscrimFunction.h CometResult.h

$(OBJ_ARCH)/SpectraSTDiscrimFunction.o : SpectraSTDiscrimFunction.cxx SpectraSTDiscrimFunction.h DiscriminantFunction.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SpectraSTResult.h

$(OBJ_ARCH)/SpectraSTDiscrimValMixtureDistr.o : SpectraSTDiscrimValMixtureDistr.cxx $(DISCRIMVALMIXTUREDISTRS_H) $(MIXTUREDISTRS_H) Array.h $(DISTRIBUTIONS_H) sysdepend.h constants.h Tag.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h DiscriminantFunction.h AbbrevSequestDiscrimFunction.h SequestDiscrimFunction.h SequestResult.h SpectraSTDiscrimFunction.h SpectraSTResult.h

$(OBJ_ARCH)/runperl.o : runperl.cxx

$(OBJ_ARCH)/Option.o : Option.cxx Option.h constants.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/XPressGroupPeptideParser.o : XPressGroupPeptideParser.cxx XPressGroupPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/XPressProteinRatioParser.o : XPressProteinRatioParser.cxx XPressProteinRatioParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h XPressGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/XPressProteinRatioParserMain.o : XPressProteinRatioParserMain.cxx XPressProteinRatioParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h XPressGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h 

#$(OBJ_ARCH)/XPressPeptideUpdateParser.o : XPressPeptideUpdateParser.cxx XPressPeptideUpdateParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h pICalculator.h RTCalculator.h gd.c gd.h

$(OBJ_ARCH)/XPressPeptideUpdateParserMain.o : XPressPeptideUpdateParserMain.cxx  ${TPP_MSDATA_READER_H} constants.h XPressPeptideUpdateParser.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h Option.h MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/XPressPeptideParser.o : XPressPeptideParser.cxx XPressPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ModificationInfo.h SearchParams.h

$(OBJ_ARCH)/XPressPeptideParserMain.o : XPressPeptideParserMain.cxx XPressPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ModificationInfo.h SearchParams.h

$(OBJ_ARCH)/XPressCGIProteinDisplay.o : XPressCGIProteinDisplay.cxx XPressCGIProteinDisplay.h constants.h XPressGroupPeptideParser.h util.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/XPressCGIProteinDisplayMain.o : XPressCGIProteinDisplayMain.cxx XPressCGIProteinDisplay.h constants.h XPressGroupPeptideParser.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/RatioParser.o : RatioParser.cxx RatioParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/LibraGroupPeptideParser.o : LibraGroupPeptideParser.cxx LibraGroupPeptideParser.h LibraConditionHandler2.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/LibraProteinRatioParser.o : LibraProteinRatioParser.cxx LibraProteinRatioParser.h LibraConditionHandler2.h StringConvertor.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h LibraGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/LibraProteinRatioParserMain.o : LibraProteinRatioParserMain.cxx  LibraProteinRatioParser.cxx  LibraProteinRatioParser.h LibraConditionHandler2.cpp $(OBJ_ARCH)/LibraProteinRatioParser.o LibraConditionHandler2.h StringConvertor.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h LibraGroupPeptideParser.cxx  LibraGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  MixtureModel.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h $(DISCRIMFUNCTIONS_H) $(SEARCHRESULTS_H) $(DISCRIMVALMIXTUREDISTRS_H) MascotScoreParser.h Spectrum.h OrderedResult.h PeptideProphetOptions.h MixtureDistrFactory.h  pICalculator.h RTCalculator.h 

$(OBJ_ARCH)/Intensity.o : Intensity.cpp Intensity.hpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h Quantitation.hpp  ${TPP_MSDATA_READER_H}

$(OBJ_ARCH)/LibraConditionHandler.o : LibraConditionHandler.cpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/LibraConditionHandler2.o : LibraConditionHandler2.cpp LibraConditionHandler2.h

$(OBJ_ARCH)/StringConvertor.o : StringConvertor.cpp StringConvertor.h

$(OBJ_ARCH)/LibraPeptideParser.o : LibraPeptideParser.cxx LibraPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  LibraConditionHandler.hpp typedefs.hpp LibraWrapper.hpp LibraResult.hpp Intensity.hpp Quantitation.hpp LibraSummary.hpp

$(OBJ_ARCH)/LibraPeptideParserMain.o : LibraPeptideParserMain.cxx LibraPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  LibraConditionHandler.hpp typedefs.hpp LibraWrapper.hpp LibraResult.hpp Intensity.hpp Quantitation.hpp LibraSummary.hpp

$(OBJ_ARCH)/LibraResult.o : LibraResult.cpp LibraResult.hpp Intensity.hpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h Quantitation.hpp  ${TPP_MSDATA_READER_H}

$(OBJ_ARCH)/LibraSummary.o : LibraSummary.cpp LibraSummary.hpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/LibraWrapper.o : LibraWrapper.cpp LibraWrapper.hpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h LibraResult.hpp Intensity.hpp Quantitation.hpp  ${TPP_MSDATA_READER_H} LibraSummary.hpp

$(OBJ_ARCH)/Quantitation.o : Quantitation.cpp Quantitation.hpp LibraConditionHandler.hpp typedefs.hpp Tag.h Array.h sysdepend.h constants.h  ${TPP_MSDATA_READER_H}

$(OBJ_ARCH)/UniquePeptide.o : UniquePeptide.cxx UniquePeptide.h

$(OBJ_ARCH)/PvalueModel.o : PvalueModel.cxx PvalueModel.h constants.h ASAP_structs.h

$(OBJ_ARCH)/Normalization.o : Normalization.cxx Normalization.h ASAP_structs.h constants.h

$(OBJ_ARCH)/ASAPRatio_numFns.o : ASAPRatio_numFns.cxx ASAPRatio_numFns.h constants.h

$(OBJ_ARCH)/ASAPRatio_pepFns.o : ASAPRatio_pepFns.cxx ASAPRatio_pepFns.h constants.h

$(OBJ_ARCH)/ASAPRatio_txtFns.o : ASAPRatio_txtFns.cxx ASAPRatio_txtFns.h

$(OBJ_ARCH)/ASAPRatioPvalueParser.o : ASAPRatioPvalueParser.cxx ASAPRatioPvalueParser.h Parser.h util.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAP_structs.h PvalueModel.h Normalization.h

$(OBJ_ARCH)/ASAPRatioPvalueParserMain.o : ASAPRatioPvalueParserMain.cxx ASAPRatioPvalueParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAP_structs.h PvalueModel.h Normalization.h

$(OBJ_ARCH)/ASAPProteinRatio.o : ASAPProteinRatio.cxx ASAPProteinRatio.h ASAPRatioMSMSSeqData.h Array.h constants.h ModificationInfo.h Tag.h sysdepend.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ASAPRatioPeptideParser.h Parser.h TagFilter.h ASAP_structs.h

$(OBJ_ARCH)/ASAPRatioGroupPeptideParser.o : ASAPRatioGroupPeptideParser.cxx ASAPRatioGroupPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ASAPProteinRatio.h ASAPRatioMSMSSeqData.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h ASAPRatioPeptideParser.h ASAP_structs.h UniquePeptide.h

$(OBJ_ARCH)/ASAPRatioMSMSSeqData.o : ASAPRatioMSMSSeqData.cxx ASAPRatioMSMSSeqData.h Array.h constants.h ModificationInfo.h Tag.h sysdepend.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ASAPRatioProteinRatioParser.o : ASAPRatioProteinRatioParser.cxx ASAPRatioProteinRatioParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAPRatioGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  ASAPProteinRatio.h ASAPRatioMSMSSeqData.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h ASAPRatioPeptideParser.h ASAP_structs.h UniquePeptide.h ASAPRatioPvalueParser.h PvalueModel.h Normalization.h

$(OBJ_ARCH)/ASAPRatioProteinRatioParserMain.o : ASAPRatioProteinRatioParserMain.cxx ASAPRatioProteinRatioParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAPRatioGroupPeptideParser.h Option.h ${TPP_MSDATA_READER_H}  ASAPProteinRatio.h ASAPRatioMSMSSeqData.h ModificationInfo.h SearchParams.h ResidueMass.h constants.h ASAPRatioPeptideParser.h ASAP_structs.h UniquePeptide.h ASAPRatioPvalueParser.h PvalueModel.h Normalization.h

$(OBJ_ARCH)/ASAPRatioPeptideParser.o : ASAPRatioPeptideParser.cxx ASAPRatioPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ModificationInfo.h SearchParams.h

$(OBJ_ARCH)/ASAPRatioPeptideParserMain.o : ASAPRatioPeptideParserMain.cxx ASAPRatioPeptideParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ModificationInfo.h SearchParams.h

$(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.o : ASAPRatioPeptideCGIDisplayParser.cxx ASAPRatioPeptideCGIDisplayParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  MixtureDistrFactory.h

$(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParserMain.o : ASAPRatioPeptideCGIDisplayParserMain.cxx ASAPRatio_txtFns.h ASAPRatio_numFns.h constants.h ASAPRatio_pepFns.h ASAPRatioPeptideCGIDisplayParser.h Parser.h Tag.h Array.h sysdepend.h TagFilter.h Option.h ${TPP_MSDATA_READER_H}  ASAPRatioPeptideUpdateParser.h

$(OBJ_ARCH)/ASAPRatioPeptideUpdateParser.o : ASAPRatioPeptideUpdateParser.cxx ASAPRatioPeptideUpdateParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Option.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/ASAPCGIDisplay2Main.o : ASAPCGIDisplay2Main.cxx ASAPCGIParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAP_structs.h Normalization.h ASAPRatioProteinCGIDisplayParser.h ProDataComponent.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(SEARCHRESULTS_H) ASAPRatio_numFns.h ASAPCGIDisplayParser.h ASAPRatio_txtFns.h

$(OBJ_ARCH)/ASAPCGIDisplayParser.o : ASAPCGIDisplayParser.cxx ASAPCGIDisplayParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAP_structs.h

$(OBJ_ARCH)/ASAPCGIParser.o : ASAPCGIParser.cxx ASAPCGIParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h Ratio.h ASAP_structs.h Normalization.h

$(OBJ_ARCH)/ASAPRatioProteinCGIDisplayParser.o : ASAPRatioProteinCGIDisplayParser.cxx ASAPRatioProteinCGIDisplayParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ASAP_structs.h ProDataComponent.h SearchResult.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(SEARCHRESULTS_H) ASAPRatio_numFns.h

ifeq (${LGPL},1)
$(OBJ_ARCH)/RefreshParser.o : RefreshParser.cxx RefreshParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h 

$(OBJ_ARCH)/RefreshParserMain.o : RefreshParserMain.cxx RefreshParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h 
else
$(OBJ_ARCH)/RefreshParser.o : RefreshParser.cxx RefreshParser.h kwset.h obstack.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h 

$(OBJ_ARCH)/RefreshParserMain.o : RefreshParserMain.cxx RefreshParser.h kwset.h obstack.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h 
endif

$(OBJ_ARCH)/RTCatalogParserMain.o : RTCatalog.cxx RTCatalogParser.cxx RTCatalogParserMain.cxx RTCatalogParser.h RTCatalog.h

$(OBJ_ARCH)/MzXML2Search.o : MzXML2Search.cxx ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/ramp_base64.o : ramp_base64.cpp 

$(OBJ_ARCH)/random_access_gzFile.o : random_access_gzFile.cpp 

$(OBJ_ARCH)/ramp.o : ramp.cpp $(SRC_ROOT)Parsers/ramp/ramp.h  constants.h

$(OBJ_ARCH)/cramp.o : cramp.cpp $(SRC_ROOT)Parsers/ramp/ramp.h  constants.h

$(OBJ_ARCH)/cached_ramp.o : cached_ramp.cpp $(SRC_ROOT)Parsers/ramp/ramp.h  constants.h

$(OBJ_ARCH)/OuterTag.o : OuterTag.cxx OuterTag.h Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/Parser.o : Parser.cxx Parser.h Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/Tag.o : Tag.cxx Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/TagFilter.o : TagFilter.cxx TagFilter.h Tag.h Array.h sysdepend.h constants.h

$(OBJ_ARCH)/TagListComparator.o : TagListComparator.cxx TagListComparator.h Tag.h Array.h sysdepend.h constants.h ${TPP_MSDATA_READER_H}

$(OBJ_ARCH)/DatabaseParser.o : DatabaseParser.cxx DatabaseParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/DatabaseParserMain.o : DatabaseParserMain.cxx DatabaseParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/CompactParser.o : CompactParser.cxx CompactParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/CompactParserMain.o : CompactParserMain.cxx CompactParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/AnalysisSummaryParser.o : AnalysisSummaryParser.cxx AnalysisSummaryParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/AnalysisSummaryParserMain.o : AnalysisSummaryParserMain.cxx AnalysisSummaryParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h

$(OBJ_ARCH)/pICalculator.o : pICalculator.cxx pICalculator.h ModificationInfo.h Array.h Tag.h sysdepend.h constants.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h

$(OBJ_ARCH)/RTCalculator.o : RTCalculator.cxx RTCalculator.h RTCatalog.h RTCatalog.cxx pICalculator.h ModificationInfo.h Array.h Tag.h sysdepend.h constants.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h

$(OBJ_ARCH)/Sequest2XML.o : Sequest2XML.cxx SequestResult.h SequestOut.h SequestHit.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/SequestOut.o : SequestOut.cxx SequestOut.h SequestHit.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/SequestHit.o : SequestHit.cxx SequestHit.h SequestOut.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/Out2XML.o : Out2XMLMain.cxx Out2XML.cxx SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/Sqt2XML.o : Sqt2XML.cxx SimpleXMLWriter.cpp SimpleXMLWriter.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/CombineOut.o : CombineOutMain.cxx CombineOut.cxx CombineOut.h Out2XML.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/CombineOut.o : CombineOutMain.cxx CombineOut.cxx CombineOut.h Out2XML.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/CombineOutMain.o : CombineOutMain.cxx CombineOut.cxx Out2XML.h SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h SequestParams.h ModifiedResidueMass.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h

$(OBJ_ARCH)/SequestParams.o : SequestParams.cxx SequestParams.h SearchParams.h constants.h sysdepend.h Array.h Tag.h ModificationInfo.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/CometResult.o : CometResult.cxx CometResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MascotResult.o : MascotResult.cxx MascotResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ProbIDResult.o : ProbIDResult.cxx ProbIDResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/SpectraSTResult.o : SpectraSTResult.cxx SpectraSTResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ProDataComponent.o : ProDataComponent.cxx ProDataComponent.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h $(SEARCHRESULTS_H)

$(OBJ_ARCH)/SearchResult.o : SearchResult.cxx SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/SequestResult.o : SequestResult.cxx SequestResult.h SearchResult.h sysdepend.h constants.h Tag.h Array.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/SearchParams.o : SearchParams.cxx SearchParams.h constants.h sysdepend.h Array.h Tag.h ModificationInfo.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/MascotConverter.o : MascotConverter.cxx MascotConverter.h Array.h util.h sysdepend.h constants.h SpectrumPeak.h ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Tag.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h MascotModification.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h Parser.h

$(OBJ_ARCH)/MascotConverterMain.o : MascotConverterMain.cxx MascotConverter.h Array.h sysdepend.h constants.h SpectrumPeak.h ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Tag.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h MascotModification.h pICalculator.h RTCalculator.h $(MIXTUREDISTRS_H) $(DISTRIBUTIONS_H) SearchResult.h Parser.h

$(OBJ_ARCH)/MascotModification.o : MascotModification.cxx MascotModification.h sysdepend.h constants.h

$(OBJ_ARCH)/Comet2xml.o : Comet2xml.cxx Comet.h constants.h AminoAcidMasses.h ${TPP_MSDATA_READER_H}  ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Array.h Tag.h sysdepend.h ModificationInfo.h SearchParams.h Option.h ResidueMass.h constants.h Parser.h

$(OBJ_ARCH)/Tandem2xml.o :  Tandem2xml.cxx TandemParamsParser.h TandemResultsParser.h ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h Tag.h TagFilter.h ModificationInfo.h SearchParams.h masscalc.h saxtandemhandler.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/TandemParamsParser.o : TandemParamsParser.cxx TandemResultsParser.h ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Parser.h Tag.h TagFilter.h ModificationInfo.h SearchParams.h masscalc.h saxtandemhandler.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/TandemResultsParser.o : TandemResultsParser.cxx ProteolyticEnzymeFactory.h util.h ProteolyticEnzyme.h Parser.h Tag.h TagFilter.h ModificationInfo.h SearchParams.h masscalc.h saxtandemhandler.h ${TPP_MSDATA_READER_H} 

$(OBJ_ARCH)/masscalc.o :  masscalc.cxx  masscalc.h

$(OBJ_ARCH)/saxtandemhandler.o : saxtandemhandler.cxx saxtandemhandler.h

$(OBJ_ARCH)/mascot_summary.o : mascot_summary.cxx

$(OBJ_ARCH)/runcompare.o : runcompare.c constants.h

$(OBJ_ARCH)/ProteolyticEnzyme.o : ProteolyticEnzyme.cxx ProteolyticEnzyme.h Array.h Tag.h sysdepend.h constants.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ProteolyticEnzymeMain.o : ProteolyticEnzymeMain.cxx ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Array.h Tag.h sysdepend.h constants.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ProteolyticEnzymeFactory.o : ProteolyticEnzymeFactory.cxx ProteolyticEnzymeFactory.h ProteolyticEnzyme.h Array.h Tag.h sysdepend.h constants.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/EnzymeDigestionParser.o : EnzymeDigestionParser.cxx EnzymeDigestionParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ProteolyticEnzymeFactory.h

$(OBJ_ARCH)/EnzymeDigestionParserMain.o : EnzymeDigestionParserMain.cxx EnzymeDigestionParser.h Parser.h Tag.h Array.h sysdepend.h constants.h TagFilter.h ProteolyticEnzyme.h ModificationInfo.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h ProteolyticEnzymeFactory.h

$(OBJ_ARCH)/AspNEnzymeDigestion.o : AspNEnzymeDigestion.cxx AspNEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/ChymotrypticEnzymeDigestion.o : ChymotrypticEnzymeDigestion.cxx ChymotrypticEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/CNBrEnzymeDigestion.o : CNBrEnzymeDigestion.cxx CNBrEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/Elastase.o : Elastase.cxx Elastase.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/EnzymeDigestion.o : EnzymeDigestion.cxx EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/EnzymeSpecificity.o : EnzymeSpecificity.cxx EnzymeSpecificity.h EnzymeDigestion.h sysdepend.h constants.h TrypticEnzymeDigestion.h GluCEnzymeDigestion.h GluC_bicarbEnzymeDigestion.h ChymotrypticEnzymeDigestion.h Elastase.h NonspecificEnzymeDigestion.h TrypChymAspnEnzymeDigestion.h MultipleEnzymeDigestion.h Array.h AspNEnzymeDigestion.h CNBrEnzymeDigestion.h TrypticCNBrEnzymeDigestion.h

$(OBJ_ARCH)/GluCEnzymeDigestion.o : GluCEnzymeDigestion.cxx GluCEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/GluC_bicarbEnzymeDigestion.o : GluC_bicarbEnzymeDigestion.cxx GluC_bicarbEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/MultipleEnzymeDigestion.o : MultipleEnzymeDigestion.cxx MultipleEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h Array.h

$(OBJ_ARCH)/NonspecificEnzymeDigestion.o : NonspecificEnzymeDigestion.cxx NonspecificEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/TrypChymAspnEnzymeDigestion.o : TrypChymAspnEnzymeDigestion.cxx TrypChymAspnEnzymeDigestion.h MultipleEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h Array.h TrypticEnzymeDigestion.h ChymotrypticEnzymeDigestion.h AspNEnzymeDigestion.h

$(OBJ_ARCH)/TrypticCNBrEnzymeDigestion.o : TrypticCNBrEnzymeDigestion.cxx TrypticCNBrEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/TrypticEnzymeDigestion.o : TrypticEnzymeDigestion.cxx TrypticEnzymeDigestion.h EnzymeDigestion.h sysdepend.h constants.h

$(OBJ_ARCH)/get_random_number.o : get_random_number.cxx

$(OBJ_ARCH)/util.o : util.cxx

$(OBJ_ARCH)/win32_system.o : win32_system.cxx sysdepend.h

$(OBJ_ARCH)/ResidueMass.o : ResidueMass.cxx ResidueMass.h constants.h

$(OBJ_ARCH)/ModifiedResidueMass.o : ModifiedResidueMass.cxx ModifiedResidueMass.h constants.h ModificationInfo.h Array.h Tag.h sysdepend.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

$(OBJ_ARCH)/ModificationInfo.o : ModificationInfo.cxx ModificationInfo.h Array.h Tag.h sysdepend.h constants.h SearchParams.h Option.h ${TPP_MSDATA_READER_H}  ResidueMass.h constants.h

# $(OBJ_ARCH)/FileUtils.o : FileUtils.cpp FileUtils.hpp

# $(OBJ_ARCH)/Peptide.o : Peptide.cpp Peptide.hpp

# $(OBJ_ARCH)/ProgressCount.o : ProgressCount.cpp ProgressCount.hpp

# $(OBJ_ARCH)/SpectraSTLib.o : SpectraSTLib.cpp  SpectraSTLib.hpp  SpectraSTLibIndex.hpp  SpectraSTPeptideLibIndex.hpp  SpectraSTLibImporter.hpp  FileUtils.hpp Peptide.hpp

# $(OBJ_ARCH)/SpectraSTLibIndex.o : SpectraSTLibIndex.cpp  SpectraSTLibIndex.hpp  SpectraSTLibEntry.hpp  FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTLibEntry.o : SpectraSTLibEntry.cpp  SpectraSTLibEntry.hpp  SpectraSTPeakList.hpp  FileUtils.hpp Peptide.hpp  

# $(OBJ_ARCH)/SpectraSTPeakList.o : SpectraSTPeakList.cpp  SpectraSTPeakList.hpp  SpectraSTSimScores.hpp  SpectraSTSearchParams.hpp  FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTLibImporter.o : SpectraSTLibImporter.cpp SpectraSTLibImporter.hpp  SpectraSTLib.hpp  SpectraSTMspLibImporter.hpp

# $(OBJ_ARCH)/SpectraSTMspLibImporter.o : SpectraSTMspLibImporter.cpp SpectraSTMspLibImporter.hpp  SpectraSTLibImporter.hpp FileUtils.hpp Peptide.hpp

# $(OBJ_ARCH)/SpectraSTXHunterLibImporter.o : SpectraSTXHunterLibImporter.cpp SpectraSTXHunterLibImporter.hpp  SpectraSTLibImporter.hpp FileUtils.hpp Peptide.hpp

# $(OBJ_ARCH)/SpectraSTSearchTask.o : SpectraSTSearchTask.cpp  SpectraSTSearchTask.hpp  SpectraSTLib.hpp SpectraSTSearchOutput.hpp  SpectraSTMspSearchTask.hpp  SpectraSTMzXMLSearchTask.hpp FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTMspSearchTask.o : SpectraSTMspSearchTask.cpp SpectraSTMspSearchTask.hpp SpectraSTSearchTask.hpp SpectraSTSearch.hpp SpectraSTQuery.hpp SpectraSTPeakList.hpp FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTMzXMLSearchTask.o : SpectraSTMzXMLSearchTask.cpp SpectraSTMzXMLSearchTask.hpp SpectraSTSearchTask.hpp SpectraSTSearch.hpp SpectraSTQuery.hpp SpectraSTPeakList.hpp FileUtils.hpp cramp.hpp ramp.h SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTDtaSearchTask.o : SpectraSTDtaSearchTask.cpp SpectraSTDtaSearchTask.hpp SpectraSTSearchTask.hpp SpectraSTSearch.hpp SpectraSTQuery.hpp SpectraSTPeakList.hpp FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTCandidate.o : SpectraSTCandidate.cpp  SpectraSTCandidate.hpp  SpectraSTLibEntry.hpp  FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTQuery.o : SpectraSTQuery.cpp SpectraSTQuery.hpp SpectraSTPeakList.hpp FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTSearch.o : SpectraSTSearch.cpp  SpectraSTSearch.hpp  SpectraSTLib.hpp SpectraSTCandidate.hpp  SpectraSTSearchOutput.hpp  SpectraSTQuery.hpp SpectraSTLibEntry.hpp  FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTSearchOutput.o : SpectraSTSearchOutput.cpp SpectraSTSearchOutput.hpp  SpectraSTSearchParams.hpp  SpectraSTSimScores.hpp  SpectraSTTxtSearchOutput.hpp  SpectraSTXlsSearchOutput.hpp  SpectraSTPepXMLSearchOutput.hpp  FileUtils.hpp

# $(OBJ_ARCH)/SpectraSTTxtSearchOutput.o : SpectraSTTxtSearchOutput.cpp SpectraSTTxtSearchOutput.hpp  SpectraSTSearchOutput.hpp Peptide.hpp

# $(OBJ_ARCH)/SpectraSTXlsSearchOutput.o : SpectraSTXlsSearchOutput.cpp SpectraSTXlsSearchOutput.hpp  SpectraSTSearchOutput.hpp Peptide.hpp

# $(OBJ_ARCH)/SpectraSTPepXMLSearchOutput.o : SpectraSTPepXMLSearchOutput.cpp SpectraSTPepXMLSearchOutput.hpp  SpectraSTSearchOutput.hpp Peptide.hpp  SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTPeptideLibIndex.o : SpectraSTPeptideLibIndex.cpp SpectraSTPeptideLibIndex.hpp  SpectraSTLibEntry.hpp  FileUtils.hpp  Peptide.hpp

# $(OBJ_ARCH)/SpectraSTMzLibIndex.o : SpectraSTMzLibIndex.cpp SpectraSTMzLibIndex.hpp SpectraSTLibIndex.hpp FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTSimScores.o : SpectraSTSimScores.cpp SpectraSTSimScores.hpp

# $(OBJ_ARCH)/SpectraSTSearchParams.o : SpectraSTSearchParams.cpp SpectraSTSearchParams.hpp FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTCreateParams.o : SpectraSTCreateParams.cpp SpectraSTCreateParams.hpp FileUtils.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/SpectraSTMain.o : SpectraSTMain.cpp SpectraSTLib.hpp  SpectraSTLibEntry.hpp  SpectraSTLibIndex.hpp  SpectraSTSearchTask.hpp  SpectraSTSearchParams.hpp  SpectraSTCreateParams.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/plotspectrast.o : plotspectrast.cpp SpectraSTLibEntry.hpp SpectraSTQuery.hpp SpectraSTPeakList.hpp cramp.hpp SpectraSTConstants.hpp

# $(OBJ_ARCH)/plotspectrast_cgi.o : plotspectrast_cgi.cpp SpectraSTLibEntry.hpp SpectraSTQuery.hpp SpectraSTPeakList.hpp cramp.hpp SpectraSTConstants.hpp

$(OBJ_ARCH)/runsearch1.o : runsearch1.cpp

$(OBJ_ARCH)/dtafilter1.o : dtafilter1.cpp

$(OBJ_ARCH)/readmzXML.o : readmzXML.cpp

$(OBJ_ARCH)/out2summary.o : out2summary.cpp

configure-linux: 
	@echo "configure target is obsolete, install dirs are now configured by creating Makefile.config.incl, see Makefile.incl for details"


ifeq (${XML_ONLY},1)
install-linux: install-linux-xml
else
install-linux: install-linux-all
endif

install-linux-all: install-linux-xml
	# Create Directories
	mkdir -p ${CGI_DIR}
	mkdir -p ${ETC_DIR}
	mkdir -p ${HELP_DIR}
	# HELP_DIR is the same as HTML_DIR for default installations
	if [ ! -e $(HTML_DIR) ]; then mkdir -p ${HTML_DIR}; fi;
	# HELP_DIR is the same as HTML_DIR for default installations
	if [ ! -e $(HTML_DIR)/images ]; then mkdir -p ${HTML_DIR}/images; fi;

	# Call make recursively
	make -C ../CGI/ install
	make -C ../COVERAGE/ install
	make -C ../HELP_DIR/ install
	make -C ../HTML/ install
	make -C ../images/ install
	#PepXMLViewer
	make -C Visualization/PepXMLViewer/ install-linux
	# Lorikeet Spectrum Viewer
	make -C Visualization/Comet/plot-msms/ install-linux


	# Copy all source executables and configuration files to their location
	cp -f $(OBJ_ARCH)/AnalysisSummaryParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/ASAPCGIDisplay.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/ASAPRatioPeptideCGIDisplayParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/comet-pepxml.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/comet-fastadb.cgi ${CGI_DIR}
	cp -f Visualization/Comet/cometlinks.def ${ETC_DIR}
	cp -f Visualization/Comet/tryp_model.txt ${HELP_DIR}
	cp -f $(OBJ_ARCH)/disCidData_xml.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/getCidData_xml.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/ModelParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/iModelParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/ShowXIC.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/Pep3D_xml.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/plot-msms.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/plot-msms-js.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/dta-xml.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/sequest-tgz-out.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/cometresult.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/xpress-prophet-update.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/XPressCGIProteinDisplayParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/XPressPeptideUpdateParser.cgi ${CGI_DIR}
	cp -f $(OBJ_ARCH)/plotspectrast.cgi ${CGI_DIR}
	cp -f ../extern/d3/*.js ${HTML_DIR}/js
	chmod a+x ${CGI_DIR}*
	chmod -R a+rw ${CGI_USERS_DIR}
	chmod a+r ${HELP_DIR}*

install-linux-xml:
	# Create Directories
	mkdir -p ${TPP_ROOT}
	mkdir -p ${BIN_DIR}
	mkdir -p ${CGI_DIR}
	mkdir -p ${SCHEMA_DIR}
	mkdir -p ${HTML_DIR}js
	mkdir -p ${LIB_DIR}
	# Copy all source executables and configuration files to their location
	cp -f $(OBJ_ARCH)/ASAPRatioPeptideParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/ASAPRatioProteinRatioParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/ASAPRatioPvalueParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/batchcoverage ${BIN_DIR}
	cp -f $(OBJ_ARCH)/CompactParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/DatabaseParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/EnzymeDigestionParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/InteractParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/LibraPeptideParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/LibraProteinRatioParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Mascot2XML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/PeptideProphetParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/InterProphetParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/RespectParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/ProteinProphet ${BIN_DIR}
	cp -f $(OBJ_ARCH)/PTMProphetParser ${BIN_DIR}

	cp -f ../extern/d3/*.js ${HTML_DIR}/js
	cp -rf ../HTML/ProteoGrapher ${HTML_DIR}

#	cp -f $(OBJ_ARCH)/StatUtilities.pm ${BIN_DIR}
	cp -f $(OBJ_ARCH)/calctppstat.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/StatUtilities.pm ${CGI_DIR}
	cp -f $(OBJ_ARCH)/calctppstat.pl ${CGI_DIR}
	cp -f $(OBJ_ARCH)/tpp_hostname ${BIN_DIR}
	cp -f $(OBJ_ARCH)/tpp_hostname ${CGI_DIR}
	cp -f $(OBJ_ARCH)/SSRCalc3.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/RTCalc ${BIN_DIR}	
	cp -f $(OBJ_ARCH)/RTCalc.coeff ${PARAMS_DIR}	
	# SSRCalc3.par doesn't need to be rewriten and is in the src tree, not build stage dir
	cp -f ../perl/SSRCalc3.par ${PARAMS_DIR}
	cp -f $(OBJ_ARCH)/run_marimba.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/filterMRM.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/min_sort.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/renamedat.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/replaceall.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/updatepaths.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/ProphetModels.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/decoyFastaGenerator.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/compareProts.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/compareProts_ClusterHM.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/get_prots.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/ProtProphModels.pl ${BIN_DIR}
#	cp -f $(OBJ_ARCH)/tpp_models.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/RefreshParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/MzXML2Search ${BIN_DIR}
	cp -f $(OBJ_ARCH)/runperl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Sequest2XML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Out2XML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Sqt2XML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/CombineOut ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Tandem2XML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/xinteract ${BIN_DIR}
	cp -f $(OBJ_ARCH)/XPressPeptideParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/XPressProteinRatioParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Q3ProteinRatioParser ${BIN_DIR}
	cp -f $(OBJ_ARCH)/spectrast ${BIN_DIR}
	cp -f $(OBJ_ARCH)/plotspectrast ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Lib2HTML ${BIN_DIR}
	cp -f $(OBJ_ARCH)/runsearch ${BIN_DIR}
	cp -f $(OBJ_ARCH)/dtafilter ${BIN_DIR}
	cp -f $(OBJ_ARCH)/readmzXML ${BIN_DIR} 
	cp -f $(OBJ_ARCH)/indexmzXML ${BIN_DIR} 
	cp -f $(OBJ_ARCH)/dta2mzxml ${BIN_DIR}
	cp -f $(OBJ_ARCH)/msconvert ${BIN_DIR}
	cp -f $(OBJ_ARCH)/idconvert ${BIN_DIR}
#	cp -f $(OBJ_ARCH)/comet ${BIN_DIR}
	cp -f $(OBJ_ARCH)/out2summary ${BIN_DIR} # to be retired in favor of out2xml
	cp -f $(OBJ_ARCH)/pep_dbcount ${BIN_DIR}
	cp -f $(OBJ_ARCH)/digestdb ${BIN_DIR}
	cp -f $(OBJ_ARCH)/subsetdb ${BIN_DIR}
	cp -f $(OBJ_ARCH)/translateDNA2AA-FASTA ${BIN_DIR}
	cp -f $(OBJ_ARCH)/calculate_pi ${BIN_DIR}
	cp -f $(OBJ_ARCH)/add_mz ${BIN_DIR}
	cp -f $(OBJ_ARCH)/decoyFASTA ${BIN_DIR}
	cp -f $(OBJ_ARCH)/tpplib_perl.pm ${CGI_DIR}
#	cp -f $(OBJ_ARCH)/tpplib_perl.pm ${BIN_DIR}
#	cp -f $(OBJ_ARCH)/exporTPP.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/createChargeFile.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/mergeCharges.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/fileDownloader.pl ${BIN_DIR}
	cp -f $(OBJ_ARCH)/Mayu.pl ${BIN_DIR}
	cp -rf $(OBJ_ARCH)/lib/Mayu ${LIB_DIR}

	# copying tandem executable and support files to installed bin directory
	cp -f $(OBJ_ARCH)/tandem ${BIN_DIR}
	cp -f $(OBJ_ARCH)/isb_default_input_kscore.xml ${PARAMS_DIR}
	cp -f $(OBJ_ARCH)/isb_default_input_native.xml ${PARAMS_DIR}
	cp -f $(OBJ_ARCH)/tandem_params.xml ${PARAMS_DIR}
	cp -f $(OBJ_ARCH)/taxonomy.xml ${PARAMS_DIR}

	# replace the default_input.xml path in Tandem's params file
	#sed -i 's?_DEFAULT_INPUT_LOCATION_/?${BIN_DIR}?g' ${BIN_DIR}tandem_params.xml

	# copying comet executable 
	# cp -f $(OBJ_ARCH)/comet ${BIN_DIR}

	cp -f ../schema/msms_analysis3.dtd ${SCHEMA_DIR}
	cp -f ../schema/pepXML_std.xsl ${SCHEMA_DIR}
	cp -f ../schema/pepXML_v*.xsd ${SCHEMA_DIR}
	cp -f ../schema/protXML_v*.xsd ${SCHEMA_DIR}
	chmod g+x ${BIN_DIR}*
	chmod a+r ${SCHEMA_DIR}*
# DO NOT DELETE

# -- Rule for outputting important variables and their values
.PHONY: info
info :
	@echo "TPP Makefile"
	@echo
	@echo " SRC_ROOT = $(SRC_ROOT)"
	@echo " OBJ_ARCH = $(OBJ_ARCH)"
	@echo
	@echo "TPP_ROOT = $(TPP_ROOT)"
	@echo " TPP_WEB = $(TPP_WEB)"
	@echo "    XSLT_PROC = $(XSLT_PROC)"
	@echo "CGI_USERS_DIR = $(CGI_USERS_DIR)"
	@echo "TPP_MSDATA_READER_BUILD = $(TPP_MSDATA_READER_BUILD)"
	@echo
