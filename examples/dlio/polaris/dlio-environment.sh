# source this to pick up DLIO settings common to 'generate' and 'train'

DLIO=${HOME}/src/dlio_benchmark

export PYTHONPATH=${DLIO}:$PYTHONPATH
python -m venv ${DLIO}/venv-polaris
source ${DLIO}/venv-polaris/bin/activate
