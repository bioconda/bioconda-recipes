# csh/tcsh configuration file for Gromacs.

##########################################################
# This is the real configuration part. We will use the 
# saved Gromacs variables from GMXRC.csh to identify what
# to remove. Because of this we don't need a separate
# deactivate script for each different CPU optimisation.
##########################################################

# zero possibly unset vars to avoid warnings
if (! $?LD_LIBRARY_PATH) setenv LD_LIBRARY_PATH ""
if (! $?PKG_CONFIG_PATH) setenv PKG_CONFIG_PATH ""
if (! $?PATH) setenv PATH ""
if (! $?MANPATH) setenv MANPATH ""
if (! $?GMXLDLIB) setenv GMXLDLIB ""
if (! $?GMXBIN) setenv GMXBIN ""
if (! $?GMXMAN) setenv GMXMAN ""

# remove previous gromacs part from ld_library_path
set tmppath = ""
foreach i ( `echo $LD_LIBRARY_PATH | sed "s/:/ /g"` )
  if ( "$i" != "$GMXLDLIB" ) then
    if ("${tmppath}" == "") then
      set tmppath = "$i"
    else
      set tmppath = "${tmppath}:$i"
    endif
  endif
end
setenv LD_LIBRARY_PATH $tmppath

# remove previous gromacs part from PKG_CONFIG_PATH
set tmppath = ""
foreach i ( `echo $PKG_CONFIG_PATH | sed "s/:/ /g"` )
  if ( "$i" != "$GMXLDLIB/pkgconfig" ) then
    if ("${tmppath}" == "") then
      set tmppath = "$i"
    else
      set tmppath = "${tmppath}:$i"
    endif
  endif
end
setenv PKG_CONFIG_PATH $tmppath

# remove gromacs stuff from binary path
set tmppath = ""
foreach i ( `echo $PATH | sed "s/:/ /g"` )
  if ( "$i" != "$GMXBIN" ) then
    if ("${tmppath}" == "") then
      set tmppath = "$i"
    else
      set tmppath = "${tmppath}:$i"
    endif
  endif
end
setenv PATH $tmppath

# and remove stuff from manual path
set tmppath = ""
foreach i ( `echo $MANPATH | sed "s/:/ /g"` )
  if ( "$i" != "$GMXMAN" ) then 
    if ("${tmppath}" == "") then
      set tmppath = "$i"
    else
      set tmppath = "${tmppath}:$i"
    endif
  endif
end
setenv MANPATH $tmppath

# and now unset all the GROMACS specific environment variables
unsetenv GMXPREFIX 
unsetenv GMXBIN 
unsetenv GMXLDLIB 
unsetenv GMXMAN 
unsetenv GMXDATA 
unsetenv GMXTOOLCHAINDIR 
unsetenv GROMACS_DIR 
unsetenv GMX_FONT

# Read completions if we understand it (i.e. have tcsh)
# Currently disabled, since the completions don't work with the new
# gmx binary with subcommands.
# Contributions to get the functionality back are welcome.
#if { complete >& /dev/null } then
#  if ( -f $GMXBIN/completion.csh ) source $GMXBIN/completion.csh
#endif
