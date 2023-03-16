#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=0:10:00
#PBS -l filesystems=home:grand
#PBS -l select=8
#PBS -l place=scatter
#PBS -N pnetcdf-writes
# export all variables to this script
#PBS -V


cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
# Testing I/O performance, not trying to mimmic an application.  Only need a
# few clients to saturate the link
NRANKS_PER_NODE=32
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

OUTPUT=/grand/radix-io/scratch/$USER/pnetcdf

# darshan gives us helpful insights:
module list
export DARSHAN_LOG_DIR_PATH=`pwd`
export LD_PRELOAD=$DARSHAN_RUNTIME_ROOT/lib/libdarshan.so

export  MPICH_MPIIO_TIMERS=1
export  MPICH_MPIIO_STATS=1

# simple comparison of two approaches:
# in the first, we fire off collective routines after computation
# in the second, after each comptation phase there is a non-blocking write
# the computation is variable on each process,so we should see a big benefit
# from the non-blocking operationsj

rm -f ${OUTPUT}/pnetcdf-*.nc

mpiexec -n ${NTOTRANKS} -ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
    ../pnetcdf-write ${OUTPUT}/pnetcdf-write-${NTOTRANKS}.nc

mpiexec -n ${NTOTRANKS} -ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
    ../pnetcdf-write-nb ${OUTPUT}/pnetcdf-write-nb-${NTOTRANKS}.nc
