#!/bin/bash
n=$1

dir="/n/netscratch/extavour_lab/Everyone/Rishabh/TSA_copepod/"
cd $dir
mkdir -p TSA_transdec
mkdir -p TSA_transdec/$n
singularity exec /cvmfs/singularity.galaxyproject.org/t/r/transdecoder:5.7.1--pl5321hdfd78af_0 TransDecoder.LongOrfs -t "$n.1.fasta" --output_dir "TSA_transdec"/$n --complete_orfs_only
singularity exec /cvmfs/singularity.galaxyproject.org/t/r/transdecoder:5.7.1--pl5321hdfd78af_0  TransDecoder.Predict -t  "$n.1.fasta" --output_dir "TSA_transdec"/$n