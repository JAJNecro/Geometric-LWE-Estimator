#!/bin/bash -l

# Give the job a name
#SBATCH --job-name="rlwe_ebdd"

# Set the number of nodes (Physical Computers)
#SBATCH --nodes=1

# Set the number of cores needed
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

# Set the amount of memory required
#SBATCH --mem-per-cpu=2gb

# Set stdout/stderr
#SBATCH --output="rlwe_ebdd.out.%j"
#SBATCH --error="rlwe_ebdd.err.%j"

# Set expected wall time for the job (format = hh:mm:ss)
#SBATCH --time=18:00:00

# Set quality of service level (useful for obtaining GPU resources)
#SBATCH --qos=default

# Turn on mail notifications for job failure and completion
#SBATCH --mail-type=END,FAIL

## No more SBATCH commands after this point ##

# Load slurm modules (needed software)
# Source scripts for loading modules in bash
. /usr/share/Modules/init/bash
. /etc/profile.d/ummodules.sh

module add Python3
module add sage

# Define and create unique scratch directory for this job
SCRATCH_DIRECTORY=/scratch0/${USER}/${SLURM_JOBID}
mkdir -p ${SCRATCH_DIRECTORY}
cd ${SCRATCH_DIRECTORY}

# Copy code to the scratch directory
cp -r ${SLURM_SUBMIT_DIR}/geometricLWE ${SCRATCH_DIRECTORY}

# Run code

OUTFILE=ebdd_cluster-${SLURM_JOBID}.log
RESULTS=ebdd_cluster.csv

cd geometricLWE/ebdd_cluster
sage --pip install --upgrade pip
sage --pip install pandas
sage ebdd_cluster.sage 100 1 > ${OUTFILE}

# Copy outputs back to home directory
cp ${OUTFILE} ${SLURM_SUBMIT_DIR}
cp ${RESULTS} ${SLURM_SUBMIT_DIR}

# Remove code files
cd ${SLURM_SUBMIT_DIR}
rm -rf ${SCRATCH_DIRECTORY}

# Finish the script
exit 0
