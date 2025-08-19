#!/bin/bash
cd $1/$2
LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 singularity exec /cvmfs/singularity.galaxyproject.org/p/a/pal2nal:14.1--pl526_0 pal2nal.pl MSA_concatenated_prot.fasta concatenated_nuc.fasta -nomismatch -nogap -output paml > "pal2nal.paml"