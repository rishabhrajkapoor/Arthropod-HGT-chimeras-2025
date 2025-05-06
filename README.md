
Arthropod HGT-chimeras.
---
# scripts
This folder contains scripts for the HGT-detection pipeline. They are described below in the order that they are run.

## input data processing
### download_genomes.py
Downloads 319 RefSeq and 197 genbank genome annotations (as found in SI table I of the manuscript). Calls the helper script download_genome.sh on each genome to access the NCBI ftp website.
### extract_cds_by_scaffold_len.sh
Using gffs, protein fastas, and genomic fastas of downloaded RefSeq genomes, excludes protein encoded by genes on scaffolds<100,000 bp in length. Requires seqkit.
### concat_and_edit_fasta_headers.sh 
Appends the genome accession to the beginning of every protein name (separated by a ";") for ease of access. Then concatenates all protein fastas to make "concatenated_filtered_proteins.fa" Repeated by concat_and_edit_fasta_headers_all_arthropod.sh to add genbank genomes to make a secondary search set of arthropod proteins included all RefSeq proteins (including those excluded in the previous step) and genbank proteins ("all_arthropod_concatenated_proteins.fa").
### mmseq2_makedb.sh
Prepares a mmseqs2 database from concatenated_filtered_proteins.fa in preparation for clustering. 
### mmseqs2_cluster80.sh
Performs clustering on the concatenated_filtered_proteins.fa db (e<1e-3, coverage>.80), outputs representative sequence:member sequence mapping to mmseq_combined_output.tsv and the representative sequences to mmseq_cluster_representatives.fasta.



