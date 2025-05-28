#!/bin/bash
##runs hmmbuild on a MSA at directory $1. Extracts hmm name as the directory name
cd $1
last_part=$(echo "$1" | awk -F'/' '{print $NF}')
singularity exec /cvmfs/singularity.galaxyproject.org/h/m/hmmer:3.3.2--he1b5a44_0 hmmbuild  -n $last_part sub_seq.hmm MSA_sub_seq.fasta 