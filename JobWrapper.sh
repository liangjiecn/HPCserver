#!/bin/sh
# This wrapper script is intended to support independent execution.
# This script uses the following environment variables set by the submit MATLAB code:
# MATLAB_Function - the MATLAB args to use
# WORKDIR - the working path
source $HOME/.bashrc
echo "Hello"
echo "Starting job"
module load  matlab
cd $MATLAB_WORKDIR 
matlab -nodisplay -nodesktop -nosplash -r $MATLAB_FUN 
echo "test Done"
echo "Done with job"
