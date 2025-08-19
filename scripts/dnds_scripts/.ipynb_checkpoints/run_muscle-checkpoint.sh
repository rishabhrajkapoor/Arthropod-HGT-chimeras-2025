#!/bin/bash
cd $1
singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h4ac6f70_3 muscle -align concatenated_prot.fasta -output MSA_concatenated_prot.fasta 