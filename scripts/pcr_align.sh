#!/bin/bash
cd PCR_result_alignments/"$1"
singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h9f5acd7_2 muscle -align "protein.fa" -output MSA_protein.fa -threads 30 