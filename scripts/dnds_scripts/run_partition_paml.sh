#!/bin/bash
#SBATCH -p shared # Partition to submit to (comma separated)
#SBATCH -J paml # Job name
#SBATCH -n 2 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 10G
#SBATCH -t 01-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL

cp dnds/$1/tree.newick  dnds/$1/$2/tree.newick

cd dnds/$1/$2

singularity exec /cvmfs/singularity.galaxyproject.org/p/a/paml:4.10.6--h031d066_1 codeml  "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/dnds_scripts/m2.ctl"

singularity exec /cvmfs/singularity.galaxyproject.org/p/a/paml:4.10.6--h031d066_1 codeml "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/dnds_scripts/m4.ctl"
