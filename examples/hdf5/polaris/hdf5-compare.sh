#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=0:10:00
#PBS -l filesystems=home:grand
#PBS -l select=8
#PBS -l place=scatter
#PBS -N hdf5-compare
# export all variables to this script
#PBS -V


cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=32
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

OUTPUT=/grand/radix-io/scratch/$USER/hdf5

# darshan gives us helpful insights:
module list
export DARSHAN_LOG_DIR_PATH=`pwd`
export LD_PRELOAD=$DARSHAN_RUNTIME_ROOT/lib/libdarshan.so

export  MPICH_MPIIO_TIMERS=1
export  MPICH_MPIIO_STATS=1

rm -f ${OUTPUT}/*.h5

mpiexec -n ${NTOTRANKS} -ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
    ../h5par-comparison ${OUTPUT}/output-default.h5

mpiexec -n ${NTOTRANKS} -ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
    ../h5par-comparison-collio ${OUTPUT}/output-collio.h5

mpiexec -n ${NTOTRANKS} -ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth \
    ../h5par-comparison-collmd ${OUTPUT}/output-collmd.h5
