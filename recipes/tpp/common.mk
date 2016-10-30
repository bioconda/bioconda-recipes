# -*- Makefile -*-
# vim: set ft=make ts=8 sw=8 sts=8 noet:
#
# Copyright (C) 2014 Institute for Systems Biology
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Institute for Systems Biology
# 401 Terry Avenue North
# Seattle, WA  98109  USA
#
# $Id: common.mk 7421 2016-10-11 19:05:09Z real_procopio $

#
# Common make rules and variables included by Makefiles throughout the TPP
# source for building TPP.  To override any of these values place the rules 
# and/or variable assignments in a separate "site.mk" file which gets included
# at the end of this file.
#

ifndef _TPP_COMMON_MK
_TPP_COMMON_MK := 1

# Disable implicit suffix rules and built-in rules 
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules

# Default rule (the first seen) is always "help"
.PHONY  : default
default : help


# -- COMMON SETTINGS -----------------------------------------------------------

# TPP source locations. Default to the directory this file is in
SRC_DIR  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TPP_EXT  := $(SRC_DIR)/extern
TPP_SRC  := $(SRC_DIR)/src
TPP_PERL := $(SRC_DIR)/perl

# TPP build locations.  Defaults are all based off of BUILD_DIR
BUILD_DIR = $(SRC_DIR)/build/$(SYSTEM)-$(ARCH)
BUILD_OBJ = $(BUILD_DIR)/artifacts
BUILD_SRC = $(BUILD_DIR)/artifacts

BUILD_BIN = $(BUILD_DIR)/bin
BUILD_CFG = $(BUILD_DIR)/conf
BUILD_CGI = $(BUILD_DIR)/cgi-bin
BUILD_INC = $(BUILD_DIR)/include
BUILD_LIB = $(BUILD_DIR)/lib
BUILD_LIC = $(BUILD_DIR)/lic
BUILD_LOG = $(BUILD_DIR)/log
BUILD_MAN = $(BUILD_DIR)/man
BUILD_WWW = $(BUILD_DIR)/html
BUILD_XSD = $(BUILD_DIR)/schema
BUILD_USR = $(BUILD_DIR)/users
BUILD_PARAMS = $(BUILD_DIR)/parameters


# TPP install locations
ifeq ($(OS),Windows_NT)
INSTALL_DIR = /c/TPP
else
INSTALL_DIR = /usr/local/tpp
endif
INSTALL_BIN = $(INSTALL_DIR)/bin
INSTALL_CFG = $(INSTALL_DIR)/conf
INSTALL_CGI = $(INSTALL_DIR)/cgi-bin
INSTALL_LIB = $(INSTALL_DIR)/lib
INSTALL_LIC = $(INSTALL_DIR)/lic
INSTALL_LOG = $(INSTALL_DIR)/log
INSTALL_MAN = $(INSTALL_DIR)/man
INSTALL_WWW = $(INSTALL_DIR)/html
INSTALL_XSD = $(INSTALL_DIR)/schema
INSTALL_USR = $(INSTALL_DIR)/users

# Default home directory, same as installation directory
ifeq ($(OS),Windows_NT)
# TODO: look at this again
TPP_HOME = $(shell cmd //c echo $(INSTALL_DIR) | sed 's%\\%/%g')
else
TPP_HOME = $(INSTALL_DIR)
endif

# Default location for data and default parameters
TPP_DATADIR = $(TPP_HOME)/data
INSTALL_PARAMS = $(TPP_DATADIR)/params

TPP_PORT = 10401

# Default base URL for all TPP URLs
# (Do not prefix with a '/' as it gets mangeled by MinGW/MSYS)
TPP_BASEURL = tpp

# Default Base URL to data directory 
# (Do not prefix with a '/' as it gets mangeled by MinGW/MSYS)
TPP_DATAURL = tpp/data

# Set MZ5_SUPPORT if you want to build TPP with HDF5 to support parsing of
# files in MZ5 format
MZ5_SUPPORT := 

# Set LGPL_SUPPORT if you want to build a LGPL version of TPP, otherwise TPP
# will include GPL software and hence itself will be GPL. ** DEPRECATED **
#LGPL_SUPPORT :=

# Set true if you want debugging compiler/linking flags set
# DEBUG := true


# -- TARGET --------------------------------------------------------------------
#
# Determine details about what platform we are targeting the build for. The 
# following variables are filled in based on the target:
#
# ARCH      The build machine architecture targeted (i686, x86_64)
# VENDOR    The distributor of the kernel software and package management 
#           system the build is targeted for (e.g. redhat, ubuntu, mingw32, w64)
# SYSTEM    The target kernel/system (linux, darwin, mingw32)
# OS        The host operating system TPP is being built on. One of Linux, 
#           Windows_NT, or Darwin
#
# There are a number of ways for deducing this depending on the system you are
# on and what you are building for. For TPP's usual platforms here are the 
# common ways and values reported:
#
#                    Red Hat Enterprise  MinGW/MinGW-64      OS X/Darwin
# ${OS}                                  Windows_NT          ?
# uname              Linux               MINGW32_NT-6.1      Darwin
# uname -s           Linux               MINGW32_NT-6.1      Darwin
# uname -o           GNU/Linux           Msys                Darwin
# uname -m           x86_64              i686                x86_64
# uname -p           x86_64              unknown             i386
# uname -i           x86_64              unknown             <error>
# gcc -dumpmachine   x86_64-redhat-linux mingw32 |           i686-apple-darwin11
#                                        i686-w64-mingw32 |
#                                        x86_64-w64-mingw32
#
# We'll use the current platform's <arch>-<vendor>-<os> triplet as reported by
# the gcc compiler for the build information.  (And of course msys/mingw32 
# doesn't report it as a triplet.)
#
ARCH := x86_64
VENDOR := unknown
SYSTEM := linux-gnu
TARGET := x86_64-unknown-linux-gnu

# Fill in the details
ifneq (,$(findstring linux, $(TARGET)))
   OS := Linux
else ifneq (,$(findstring darwin, $(TARGET)))
   OS := Darwin
else ifneq (,$(findstring mingw, $(TARGET)))
   OS := $(OS)
else ifneq (,$(findstring msys, $(TARGET)))
   OS := $(OS)
else
   $(error Unable to determine target platform using $$(CXX) -dumpmachine)
endif


#-- VERSION --------------------------------------------------------------------
#
# TPP version and build identification
#

# Load TPP_VERSION and TPP_RELEASE from version file
include $(SRC_DIR)/VERSION.mk

# Load BUILD_DATE, BUILD_SVNREV from build id file only
# if the file exists.  Including it if it does not will 
# cause make to run the rule that remakes it.
# TODO: fix this
BUILD_DATE   := xxxx
BUILD_SVNVER := xxxx 
ifneq (,$(wildcard $(BUILD_DIR)/BUILD.mk))
include $(BUILD_DIR)/BUILD.mk
else
BUILD_DATE = $(shell date '+%Y%m%d%H%M')
	ifndef TPPSVNREV
		BUILD_SVNVER = $(shell (svn info $(SRC_DIR) --show-item revision 2>/dev/null || echo 'exported') | sed 's/\s//g')
	else
		BUILD_SVNVER = $(TPPSVNREV)
	endif
endif

# Assign TPP_BUILDID the version and build identification
TPP_BUILDID ?= TPP v$(TPP_VERSION) $(TPP_RELEASE), Build $(BUILD_DATE)-$(BUILD_SVNVER) ($(OS)-$(ARCH))

# -- COMPILER DETAILS  ---------------------------------------------------------
#
# Compiler and common compiler flags

CXX      := g++
CXXFLAGS ?=

#DEBUG = 1
# Debug or optimize?
CXXFLAGS += $(if $(DEBUG),-g -DDEBUG,-O2) 

# Turn all warnings into errors but ignore deprecated function calls for now
# as they are treated as errors and can't be be ignored by the 
# option -Wno-errors=deprecated.
#
# TODO: remove the deprecated calls
CXXFLAGS += -Wno-deprecated

# Always include large file support
CXXFLAGS += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE

# Make a LGPL instead of GPL version of TPP (deprecated)
CXXFLAGS += $(if $(LGPL_SUPPORT),-D__LGPL__)

# Include MZ5 support in mzParser (requires HDF5 libraries)
CXXFLAGS += $(if $(MZ5_SUPPORT),-DMZP_MZ5)

# TODO: get rid of this if possible
CXXFLAGS += -DTPPLIB

# Include headers from TPP source
CXXFLAGS += -I$(TPP_SRC)

# Include headers for external dependencies 
CXXFLAGS += -I$(BUILD_DIR)/include

# System specific
ifeq ($(OS),Linux)
   CXXFLAGS += -D__LINUX__
   # compile with position independent code to allow for library inclusion
   CXXFLAGS += -fPIC
endif
ifeq ($(OS),MingW)
   CXXFLAGS += -D__MINGW__ -D_USE_32BIT_TIME_T -D_GLIBCXX_USE_WCHAR_T
endif
ifeq ($(OS),Darwin)
   CXXFLAGS += -D__LINUX__ -ftemplate-depth=256
endif


# -- LINKER DETAILS  -----------------------------------------------------------
#
# Linker and common linker flags

LD = g++
LDFLAGS += $(if $(DEBUG),,-s)     # Strip executables
LDFLAGS += -L$(BUILD_DIR)/lib     # Include external deps not already on system

ifeq ($(SYSTEM), mingw32)
   LDFLAGS += -static
endif


#ifneq ($(ARCH),darwin)
   # on os x 10.7, make will balk at "-lz" as a build dependency
#   LDFLAGS += $(ZLIB_LIB)
#endif

# TPP libraries
LIBTPP       := $(BUILD_DIR)/lib/libtpp.a
LIBSPECTRAST := $(BUILD_DIR)/lib/libspectrast.a
LIBMZPARSER  := $(BUILD_DIR)/lib/libmzparser.a

# TPP external dependencies
BOOST_CXXFLAGS := 
BOOST_LDFLAGS  := -lboost_iostreams -lboost_regex -lboost_filesystem \
                  -lboost_system -lboost_thread -lboost_serialization -lpthread
ifeq ($(VENDOR),w64)
   # Link against Windows Sockets API to get gethostname() and related functions
   BOOST_LDFLAGS += -lws2_32
else
   # Link against POSIX realtime extensions library
   BOOST_LDFLAGS += -lrt
endif

BZIP2_CXXFLAGS :=
BZIP2_LDFLAGS  := -lbz2

EXPAT_CXXFLAGS := 
EXPAT_LDFLAGS  := -lexpat 

FANN_CXXFLAGS :=
FANN_LDFLAGS  := -lfann

GD_CXXFLAGS :=
ifeq ($(SYSTEM),mingw32)
   # Compile for static Linux library instead of Windows DLL
   GD_CXXFLAGS += -DBGDWIN32 -DNONDLL
endif
GD_LDFLAGS := -lgd -lpng

LZO2_LDFLAGS :=
ifeq ($(SYSTEM),mingw32)
   # Compile for static Linux library instead of Windows DLL
   LZO2_LDFLAGS += -llzo2
endif


GSL_CXXFLAGS := 
GSL_LDFLAGS  := -lgsl -lgslcblas

GZSTREAM_CXXFLAGS :=
GZSTREAM_LDFLAGS  := -lgzstream

ifneq ($(MZ5_SUPPORT),)
HDF5_CXXFLAGS := 
HDF5_LDFLAGS  := -lhdf5_cpp -lhdf5
endif

LIBARCHIVE_CXXFLAGS := 
LIBARCHIVE_LDFLAGS  := -larchive

MZPARSER_CXXFLAGS := -I$(TPP_SRC)/Parsers/mzParser $(HDF_CXXFLAGS) $(EXPAT_CXXFLAGS)
MZPARSER_LDFLAGS  := $(LIBMZPARSER) $(HDF5_LDFLAGS) $(EXPAT_LDFLAGS) -lz

MSTOOLKIT_CXXFLAGS := -I$(TPP_EXT)/MSToolkit/include 
MSTOOLKIT_LDFLAGS  := -lmstoolkitlite 

MSTK_PATH = $(TPP_EXT)/MSToolkit
MSTK_OBJDIR := $(BUILD_OBJ)/MSToolkit

HARDKLOR_CXXFLAGS := -I$(TPP_EXT)/Hardklor
HARDKLOR_LDFLAGS  := -lhardklor 

HKLR_PATH = $(TPP_EXT)/Hardklor
HKLR_OBJDIR := $(BUILD_OBJ)/Hardklor


PNG_CXXFLAGS := 
PNG_LDFLAGS  := -lpng

PWIZ_CXXFLAGS := -I$(TPP_EXT)/ProteoWizard/pwiz-src $(BOOST_CXXFLAGS)
PWIZ_LDFLAGS  := -lpwiz

ifeq ($(VENDOR),w64)
   WINSOCK_LDFLAGS := -lws2_32
endif

ZLIB_CXXFLAGS =
ZLIB_LDFLAGS  = -lz


# TODO: fix? Include all of the dependences for the TPP library (except Boost)
# TODO: change TPPLIB name to LIBTPP or just TPP?
TPPLIB_CXXFLAGS := -I$(TPP_SRC) $(MZPARSER_CXXFLAGS) $(GZSTREAM_CXXFLAGS) $(PWIZ_CXXFLAGS) 
TPPLIB_LDFLAGS  := $(LIBTPP) $(MZPARSER_LDFLAGS) $(GZSTREAM_LDFLAGS) $(PWIZ_LDFLAGS)


# -- HELP ----------------------------------------------------------------------
#
# Rule which outputs a short summary on the targets available to the user.
# Should always be the first rule in the Makefile to ensure that if no targets
# are provided on the command line it is invoked.
#
.PHONY: help 

help ::
	@echo
	@echo "Usage: make target ... [ DEFINES ...]"
	@echo
	@echo "Makefile for building the Trans-Proteomic Pipeline (TPP)"
	@echo
	@echo "Global targets:"
	@echo "   help          Prints this message"
	@echo "   info          Prints build details at this directory level"
	@echo "   fullinfo      Prints extended build details at this directory level"
	@echo "   all           Make all build products at this directory level"
	@echo "   clean         Remove all intermediate build products at this level"
	@echo


# -- INFO ----------------------------------------------------------------------
#
# Rules for displaying the Makefile variables and values
#
.PHONY: info fullinfo

info ::
	@echo
	@echo "  ARCH = $(ARCH)"
	@echo "VENDOR = $(VENDOR)"
	@echo "SYSTEM = $(SYSTEM)"
	@echo "    OS = $(OS)"
	@echo
	@echo "TPP_VERSION = $(TPP_VERSION)"
	@echo "TPP_RELEASE = $(TPP_RELEASE)"
	@echo "TPP_BUILDID = $(TPP_BUILDID)"
	@echo
	@echo "    SRC_DIR = $(SRC_DIR)"
	@echo "  BUILD_DIR = $(BUILD_DIR)"
	@echo "INSTALL_DIR = $(INSTALL_DIR)"
	@echo
	@echo "   TPP_HOME = $(TPP_HOME)"
	@echo "TPP_DATADIR = $(TPP_DATADIR)"
	@echo "TPP_BASEURL = $(TPP_BASEURL)"
	@echo "TPP_DATAURL = $(TPP_DATAURL)"
	@echo
	@echo " MZ5_SUPPORT $(if $(MZ5_SUPPORT),is enabled,is not enabled)"
ifdef LGPL_SUPPORT
	@echo "LGPL_SUPPORT $(if $(LGPL_SUPPORT),is enabled,is not enabled)"
endif
	@echo

fullinfo :: info
	@echo "Additional common information:"
	@echo "   BUILD_BIN = $(BUILD_BIN)"
	@echo "   BUILD_CGI = $(BUILD_CGI)"
	@echo "   BUILD_LIB = $(BUILD_LIB)"
	@echo "   BUILD_MAN = $(BUILD_MAN)"
	@echo "   BUILD_OBJ = $(BUILD_OBJ)"
	@echo "   BUILD_WWW = $(BUILD_WWW)"
	@echo "   BUILD_SRC = $(BUILD_SRC)"
	@echo
	@echo "   INSTALL_BIN = $(INSTALL_BIN)"
	@echo "   INSTALL_CGI = $(INSTALL_CGI)"
	@echo "   INSTALL_LIB = $(INSTALL_LIB)"
	@echo "   INSTALL_WWW = $(INSTALL_WWW)"
	@echo
	@echo "        CXX = $(CXX)"
	@echo "   CXXFLAGS = "$(CXXFLAGS)
	@echo "    LDFLAGS = $(LDFLAGS)"
	@echo


#-- BUILD --------------------------------------------------------------------
#

# Make build/staging directories. Should be used as a "order-only" prerequisite
# (prefixed with a "|" ) on any build rules.
$(BUILD_DIR)/ :
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_BIN)
	mkdir -p $(BUILD_CFG)
	mkdir -p $(BUILD_CGI)
	mkdir -p $(BUILD_INC)
	mkdir -p $(BUILD_LIB)
	mkdir -p $(BUILD_LIC)
	mkdir -p $(BUILD_LOG)
	mkdir -p $(BUILD_OBJ)
	mkdir -p $(BUILD_WWW)
	mkdir -p $(BUILD_SRC)

$(BUILD_BIN)/ :
	mkdir -p $(BUILD_BIN)

$(BUILD_LIC)/ :
	mkdir -p $(BUILD_LIC)


# -- UTILITY -------------------------------------------------------------------
#
# Some general useful make variables and macros

# Always can use a force
.PHONY: .FORCE
.FORCE:

# Macros for using special characters in recipes/variables
null  :=
space := $(null) #
comma := ,
define nl


endef

# The following macro and rule can be used as a "order-only" prequisite in order
# to create the target's parent directory if it doesn't already exist.  Used by
# including the macro as a order-only prerequisite as so:
#
#    parent/child.o : | $(MKDIR)
#
# which will create the directory "parent" if it doesn't exist.
#
.SECONDEXPANSION:
.SECONDARY:

MKDIR = $$(@D)/.d

%/.d : 
	mkdir -p $*
	touch $@

.PRECIOUS: %/.d

# Convert a unix path to a windows path (on mingw)
winpath=$(shell \
   if [ -f "$1" ]; then \
      echo "$$(cd "$(dir $1)" && pwd -W)/$(notdir $1)" | sed -e 's|/|\\\\|g'; \
   elif [ -d "$1" ]; then \
      echo "$$(cd "$1" && pwd -W)" | sed -e 's|/|\\|g'; \
   else \
      echo "$1" | sed -e 's|^/\(.\)/|\1:\\|g' -e 's|/|\\|g'; \
   fi)


# The user has explicitly enabled quiet compilation.
ifeq ($(V),0)
    quiet = @printf "$1 $(notdir $@)\n"; $($(shell echo $1 | sed -e s'/ .*//'))
    Q=@
else
    quiet = $($(shell echo $1 | sed -e s'/ .*//'))
endif

# Report directory of Makefile currently being processed (excludes this one and
# only works before any includes)
MAKEDIR = $(patsubst %/,%,$(dir $(abspath $(lastword $(filter-out %common.mk,$(MAKEFILE_LIST))))))


# -- SITE ---------------------------------------------------------------------
#
# Include any site specific overrides
-include $(SRC_DIR)/site.mk

# Make sure users didn't put anything silly in the site.mk
ifneq (,$(findstring \,$(TPP_HOME)))
   $(error Error: use forward '/' not back '\' slashes in TPP_HOME)
endif
ifneq (,$(findstring \,$(TPP_DATADIR)))
   $(error Error: use forward '/' not back '\' slashes in TPP_DATADIR)
endif

endif		# _TPP_COMMON_MK
