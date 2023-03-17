#!/bin/bash -l
#PBS -A CSC250STDM12
#PBS -k doe
#PBS -l walltime=0:10:00
#PBS -l filesystems=home:grand
#PBS -l select=4
#PBS -l place=scatter
#PBS -N dlio-generate
# export all variables to this script
#PBS -V

cd ${PBS_O_WORKDIR}
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=4
NDEPTH=1
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

export DARSHAN_LOG_DIR_PATH=`pwd`
export LD_PRELOAD=${DARSHAN_RUNTIME_ROOT}/lib/libdarshan.so

source ./dlio-environment.sh
mpiexec -n ${NTOTRANKS} python ${DLIO}/src/dlio_benchmark.py workload=unet3d \
	++workload.workflow.generate_data=True \
	++workload.workflow.train=False \
	++dataset.data_folder=/grand/radix-io/scratch/robl/dlio/data/unet3d/ \
	++checkpoint.checkpoint_folder=/grand/radix-io/scratch/robl/dlio/data/unet3d/ \
	++workload.dataset.num_files_train=64
