program main
  implicit none
  include 'netcdf.inc'
  integer iret, ncid
  
  print*, maxncdim
  iret = nf_open('monitor.cdf', NF_WRITE, ncid)
  iret = nf_close(ncid)
end program main
