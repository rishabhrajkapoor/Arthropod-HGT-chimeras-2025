
# Arthropod HGT-chimeras.
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


## search database setup
### download_nr.sh
downloads the nr protein fasta file from NCBI
### download_tax.sh
download NCBI taxonomy files for indexing diamond db
### make_diamond_db.sh
make diamond indexed database ("nr.dmnd") from full NR
### make_arthropod_diamond_database.sh
make arthropod-only diamond indexed database ("arthropod_db.dmnd") from "all_arthropod_concatenated_proteins.fa"
### download_blast_db.sh
uses blast+ to download a pre-indexed blast db of nr, used for sequence retrieval 

## DIAMOND blast inference chimera
### split_fasta_run_diamond_round1.py
splits mmseq_cluster_representatives.fasta into 4 fastas and runs DIAMOND blastp on each in parallel by calling the helper script 'scripts/run_diamond_round1_on_split_fastas.sh'
### split_diamond_round1_outputs.sh 
splits the blast output tsv by query accession and stores the results in round1_diamond_split_outputs. Calls the helper script "split_blast_table.sh."
### run_diamond_on_missing_sequences.ipynb
runs diamond on 11 hgt-chimeras from a previous pipeline run that were excluded from mmseq_cluster_representatives.fasta, along with any sequences in mmseq_cluster_representatives.fasta that failed to produce diamond hits in the first run of run_diamond_round1_on_split_fastas.sh. Calls the helper scripts  "split_blast_table.sh" and "run_diamond_round1_on_missing_fasta.sh"
### interval_demarcation_round1.py
Performs a modified version of the interval demarcation algorithm from https://doi.org/10.1371/journal.pcbi.1005889 on round 1 blast results. Assigns preliminary "Meta" or "HGT" annotations to intervals depending on the taxonomic distribution of blast hits.
### split_intervals_round1.py
using the results of interval demarcation, identifies putative chimeras with >=1 HGT AND >=1 Meta interval. Outputs "split_intervals.fasta" with each  HGT-chimera interval +/-10 amino acid residues as a separate sequence, with headers labeled as "genome accession;protein accession;annotation_(interval start,interval stop)."  Also splits outputs into separated tsvs by query, stored in "round2_diamond_output_split"
### run_diamond_round2.sh
runs round 2 DIAMOND blast with demarcated intervals ("split_intervals.fasta") as queries against NR.
### run_diamond_round2_arthropod.sh
runs round 2 DIAMOND blast with demarcated intervals ("split_intervals.fasta") as queries against custom database of arthropod proteins ("all_arthropod_concatenated_proteins"). Also splits outputs into separated tsvs by query, stored in round2_diamond_output_arthropod
### process_blast_round2.ipynb
This notebook processes round 2 diamond blast hits vs NR to confirm "Meta" or "HGT" annotations of each interval. Subsequently, chimeras in which non-arthropod hits to adjacent series of "HGT" and "Meta" intervals are found are filtered out. The remaining HGT-chimeras are output to a pickled dictionary and .txt file.

## HMMER-based inference
### build_hmms_from_round2blast.ipynb
This notebook builds profile HMMs from arthropod blast hits for each interval separately. It then calls scripts to run hmmsearch vs the custom database of arthropod proteins ("all_arthropod_concatenated_proteins.fa") and NR. Outputs are stored in the "hmmbuild" directory, with structure protein_accession/interval/data. Helper scripts are described below:
### remove_redundant_seqs.awk
awk script to remove any redundant sequences from interval fasta before running MUSCLE alignment.
### hmmbuild_muscle.sh
runs MUSCLE with default parameters on "sub_seq.fasta", a fasta with with the sub-interval of each hit.
### hmmbuild_muscle_super5.sh
Runs MUSCLE with super5 for MSAs that failed to run due to a time-out error with standard MUSCLE. 
### concat_hmms.sh
concatenates multiple profile hmms into one file for submission to hmmsearch. accepts a list of ~ delimited file paths.
### hmmsearch_array.sbatch
runs hmmsearch vs NR in a parallelized job array on profile hmms in the "concatenated_hmms" directory 
### hmmsearch_vs_arthropoda.sh
runs hmmsearch vs customized arthropod protein database "all_arthropod_concatenated_proteins.fa"
### split_hmmer_csv.sh
splits hmmer domtblout outputs into separated tsvs for each query

## Ankyrin repeat and transposable element filters
### transposable_element_and_ankyrin_repeat_filters.ipynb
This notebook processes outputs from the webservers of NCBI CD-search and CENSOR (urls in notebooks) to exclude ankyrin repeats and metazoan transposable elemnts (overlapping with HGT intervals).

## Orthologous clustering and phylogenetic dataset construction 
### extract_taxonomically_filtered_accessions.ipynb
notebook contains scripts to extract arthropod protein accessions from NR, used for subsequent filtering in phylogenetic database construction
### add_suppresed_aedes_albopictus_hmmsearch.ipynb
Add a secondary chimera  of XP_021699539.1 recovered in the first pipeline iteration run on A. albopictus annotation release GCF_006496715.1, but was later marked as a lncRNA in the current A.albopictus annotation release. We confirmed its expression and sequence via RT-PCR and Sanger sequencing after the first iteration, so manually added XP_029735553.1 back for consideration as a secondary chimera of XP_021699539.1.
### hmmsearch_analysis_and_clustering.ipynb
Processes hmmsearch results into tsvs with headers. Then uses hmmsearch and blast results to identify secondary chimeras, perform orthologous clustering, verify secondary chimeras via interval blast search, and output a table of verified clusters with taxonomic information.
### diamond_secondary.sh
Searches intervals of putative secondary chimeras vs NR with DIAMOND BLASTP. Called by "hmmsearch_analysis_and_clustering.ipynb."
### phylogenetic_dataset_construction.ipynb
Constructs fastas for phylogenetic inference on each separated interval using blast or hmmsearch results, then calls the helper scripts "align_iq_pipe.sh" or "align_iq_pipe_long.sh" to execulte MUSCLE, trimal and iq-tree for tree inference. 
### root_annotate_upload_trees.ipynb
Executes scripts to root maximum likelihood trees via minimum ancestor deviation (using mad.py obtained from https://www.nature.com/articles/s41559-017-0193), annotate the files with iTOL annotation files for taxonomic labels, and upload to iTOl with the itol python api.
