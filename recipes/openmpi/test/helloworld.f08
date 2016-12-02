program main

  use mpi_f08
  implicit none

  integer :: provided,  size, rank, len
  character (len=MPI_MAX_PROCESSOR_NAME) :: name

  call MPI_Init_thread(MPI_THREAD_MULTIPLE, provided)

  call MPI_Comm_rank(MPI_COMM_WORLD, rank)
  call MPI_Comm_size(MPI_COMM_WORLD, size)
  call MPI_Get_processor_name(name, len)

  write(*, '(2A,I2,A,I2,3A)') &
       'Hello, World! ', &
       'I am process ', rank, &
       ' of ', size, &
       ' on ', name(1:len), '.'

  call MPI_Finalize()

end program main
