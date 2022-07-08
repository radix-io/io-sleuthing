# I/O sleuthing:

Thanks for checking out our course on I/O performance.  We've given a
high-level survey of parallel I/O at SC for many years.  We've also had a
chance to go into a little more detail at the ATPESC training program's "Data
and I/O" day.   In this course, however, we are going to have a chance to
really dig into I/O performance to understand why we see the performance we do.

## Outline

- Introduction:
  - overview of the day
  - terminology and technologies
- System overview
  - Walk through storage and networking features of systems we're using
- Simulation I/O
  - Describe a non-trivial I/O kernel
  - Execute on exemplar machine
- Machine Learning I/O
  - Describe a non-trivial I/O kernel
  - Execute on exemplar machine
- Benchmarking
  - establishing the ground truths
  - single node benchmarking
  - parallel benchmakring
  - benchmarking pitfalls
- I/O libraries
- Analysis
  - Darshan DXT data
  - py-darshan

## Tools

- We can generate and observe lots of access patterns with the IOR benchmark
- 'fio' is a useful tool for single-node tuning
- The Darshan I/O characterization tool will give us initial reports with
  options to drill into access patterns and create our own querries.


## Venue

We are running the workshop at Argonne National Laboratory.  Specific room
still to be determined based on pre-registration numbers.

## Materials

Talk will be recorded.  Once we have videos edited we will post links to them
here.
