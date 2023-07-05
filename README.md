# I/O sleuthing:

Tuning an application's I/O and tuning for compute or memory share similar
characteristics, but I/O tuning introduces some unique challenges.  We will examine a
typical high performance computing (HPC) system and its storage.  Through
benchmarks, I/O kernels, and characterization tools we will build up the kind
of mental model of a system's I/O performance that can help us find solutions
to I/O performance problems when we encounter them.

We've given a high-level survey of parallel I/O at SC for many years.  We've
also had a chance to go into a little more detail at the ATPESC training
program's "Data and I/O" day.   In this half day workshop, however, we are
going to have a chance to go into more detail about tuning parameters and
workloads.  We will also cover some of the tools and resources we can use to
understand why we see the performance we do.

## Venue (Where/When)

We are running the workshop at Argonne National Laboratory.  Building 241, room D-172.

Monday 20 March from Noon to 3:15 pm

## Outline

Noon to 3:30 pm
(All times US Central)

- Introduction [(Video)](https://youtu.be/fDi_hSHynmk) [(Slides)](presentation/io-sleuthing-intro.pdf)
  - Challenges
  - terminology and technologies
- File system [(Video)](https://youtu.be/fDi_hSHynmk?t=1065) [(Slides)](presentation/io-sleuthing-storage.pdf)
  - Walk through storage and networking features of exemplar system
- Benchmarking [(Video)](https://youtu.be/fDi_hSHynmk?t=1572) [(Slides)](presentation/io-sleuthing-benchmarking.pdf)
  - challenges of I/O benchmarking
  - the IOR benchmark
  - Lustre + striping
- Characterizing I/O with Darshan [(Video)](https://youtu.be/iHX7xsfpE44?t=313) [(Slides)](presentation/io-sleuthing-darshan-survey.pdf)
- Break
- Analysis of I/O with Darshan [(Video)](https://youtu.be/iHX7xsfpE44?t=1572) [(Slides)](presentation/io-sleuthing-darshan-analysis.pdf)
- MPI-IO: the core of the simulation I/O stack [(Video)](https://youtu.be/kDKn4eYUg9A?t=5) [(Slides)](presentation/io-sleuthing-mpiio.pdf)
- I/O libraries
  - Parallel-NetCDF [(Video)](https://youtu.be/B3NNyk1UpLo?t=729) [(Slides)](presentation/io-sleuthing-pnetcdf.pdf)
  - HDF5 [(Video)](https://youtu.be/B3NNyk1UpLo?t=1561)  [(Slides)](presentation/io-sleuthing-hdf5.pdf)
- Machine Learning I/O [(Video)](https://youtu.be/sW1GRK25CM8) [(Slides)](presetation/io-sleuthing-ML-and-closing.pdf)
  - Describe a non-trivial I/O kernel
  - Execute on exemplar machine

## Tools and Libraries

- [IOR](https://github.com/hpc/ior): We can generate and observe lots of access
  patterns with the IOR benchmark
- [Darshan](https://www.mcs.anl.gov/research/projects/darshan/): The Darshan
  I/O characterization tool will give us initial reports with
  options to drill into access patterns and create our own queries.
- [ROMIO](https://wordpress.cels.anl.gov/romio/): We talk a lot about Cray
  MPICH tuning parameters.  Cray has done a lot of work on top of ROMIO.  Some
  of the options discussed won't apply to non-Cray systems, but a lot of the
  important ideas like data sieving and two-phase collective buffering are
  found in ROMIO and in turn in MPICH or OpenMPI.  do.
- [Parallel-NetCDF](https://github.com/Parallel-NetCDF/PnetCDF) and
  [HDF5](https://www.hdfgroup.org/solutions/hdf5/):  High level I/O libraries
  targeting applications.


## Materials

- The full [Slide presentation](presentation/IO-sleuthing-BSSW.pdf)
- [Video recording](https://www.youtube.com/playlist?list=PLGj2a3KTwhRZSKVy-ZrjarFuW-coqS7F9) of the talk.
