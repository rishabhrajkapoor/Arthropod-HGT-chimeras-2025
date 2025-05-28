#!/bin/bash
cd $1

singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h9f5acd7_2 muscle -align sub_seq.fasta -output MSA_sub_seq.fasta
