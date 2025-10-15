# Arthropod HGT-chimeras

---
This repository contains scripts used to infer chimeric HGT genes in the manuscript "Evolutionary innovation through fusion of sequences from across the tree of life." Input and output data are available in the accompanying Dryad repository (https://doi.org/10.5061/dryad.t1g1jwtdz).  

# Dependencies 

Except where otherwise noted in the below table, all bioinformatics software was accessed via Singularity images distributed by the BioContainers project (https://biocontainers.pro/) on the Harvard Faculty of Arts and Sciences Research Computing cluster.  

| Software or Algorithm | Version      | URL |
|------------------------|--------------|-----|
| MMseqs                 | v2:14.7e284  | https://biocontainers.pro/ |
| BLAST                 | v2.13.0     | https://www.ncbi.nlm.nih.gov/books/NBK279690/  |
| SeqKit                 | v2.9.0       | https://biocontainers.pro/ |
| DIAMOND                | v2.0.15      | https://biocontainers.pro/ |
| HMMER                  | v3.3.2       | https://biocontainers.pro/ |
| MUSCLE                 | v5.1         | https://biocontainers.pro/ |
| trimAl                 | v1.4.1       | https://biocontainers.pro/ |
| IQ-TREE                | v2.2.0.3     | https://biocontainers.pro/ |
| Minimum ancestor deviation rooting (mad.py) | – | https://www.mikrobio.uni-kiel.de/de/ag-dagan/ressourcen |
| iTOL webserver and API | –            | https://github.com/iBiology/iTOL; https://itol.embl.de/ |
| NetworkX               | v2.8.8       | https://github.com/networkx/networkx |
| NCBI Genome Data Viewer| –            | https://www.ncbi.nlm.nih.gov/gdv/ |
| PAL2NAL                | v14.1        | https://biocontainers.pro/ |
| PAML                   | v4.10.6      | https://biocontainers.pro/ |
| statsmodels            | v0.14.0      | https://www.statsmodels.org/stable/index.html |
| InterProScan webserver | release 5.75-106.0 | https://www.ebi.ac.uk/interpro/search/sequence/ |
| DeepGO-SE              | –            | https://github.com/bio-ontology-research-group/deepgo2 |
| NCBI Conserved Domain Database (Batch CD-Search) | – | https://www.ncbi.nlm.nih.gov/Structure/bwrpsb/bwrpsb.cgi |
| CENSOR web application | –            | https://www.girinst.org/censor/ |
| matplotlib             | v3.9.2       | https://matplotlib.org/ |
| seaborn                | v0.13.2      | https://seaborn.pydata.org/ |
| NumPy                  | v1.26.4      | https://numpy.org/ |
| SciPy                  | v1.7.3       | https://scipy.org/ |
| Biopython              | v1.83        | https://biopython.org/ |
| Python                 | v3.6         | https://www.python.org/ |
| ete3                   | v3.1.2       | https://pypi.org/project/ete3/ |
| Python Imaging Library (PIL/Pillow) | v9.1.1 | https://pypi.org/project/pillow/ |
| pyMSAviz               | v0.4.2       | https://moshi4.github.io/pyMSAviz/ |
| fpdf                   | v1.7.2       | https://pypi.org/project/fpdf/ |
|SRA toolkit | v.3.1.0 | https://biocontainers.pro/ |
|Trim Galore | v.0.6.9 | https://biocontainers.pro/ |
|DESeq2  | v.1.46.0 | https://biocontainers.pro/ |
|Subread | v.2.0.6 | https://biocontainers.pro/ |




# Scripts
This folder contains scripts for the HGT-chimera detection pipeline. They are described below in the order that they are run.

## Input Data Processing
### download_genomes.py
Downloads 319 RefSeq and 197 GenBank genome annotations (as found in SI Table 1 of the manuscript). Calls the helper script `download_genome.sh` on each genome to access the NCBI FTP website.  
### extract_cds_by_scaffold_len.sh
Using GFFs, protein FASTAs, and genomic FASTAs of downloaded RefSeq genomes, excludes protein encoded by genes on scaffolds <100,000 bp in length. Requires seqkit.  
### concat_and_edit_fasta_headers.sh 
Appends the genome accession to the beginning of every protein name (separated by a ";") for ease of access. Then concatenates all protein FASTAs to make `concatenated_filtered_proteins.fa`. Repeated by `concat_and_edit_fasta_headers_all_arthropod.sh` to add GenBank genomes to make a secondary search set of arthropod proteins including all RefSeq proteins (including those excluded in the previous step) and GenBank proteins (`all_arthropod_concatenated_proteins.fa`).  
### mmseq2_makedb.sh
Prepares a MMseqs2 database from `concatenated_filtered_proteins.fa` in preparation for clustering.  
### mmseqs2_cluster80.sh
Performs clustering on the `concatenated_filtered_proteins.fa` db (e < 1e-3, coverage > .80), outputs representative sequence:member sequence mapping to `mmseq_combined_output.tsv` and the representative sequences to `mmseq_cluster_representatives.fasta`.

## Search Database Setup
### download_nr.sh
Downloads the NR protein FASTA file from NCBI.  
### download_tax.sh
Downloads NCBI taxonomy files for indexing DIAMOND db.  
### make_diamond_db.sh
Makes a DIAMOND indexed database (`nr.dmnd`) from full NR.  
### make_arthropod_diamond_database.sh
Makes an arthropod-only DIAMOND indexed database (`arthropod_db.dmnd`) from `all_arthropod_concatenated_proteins.fa`.  
### download_blast_db.sh
Uses BLAST+ to download a pre-indexed BLAST db of NR, used for sequence retrieval.  

## DIAMOND Blast Inference Chimera
### split_fasta_run_diamond_round1.py
Splits `mmseq_cluster_representatives.fasta` into 4 FASTAs and runs DIAMOND BLASTp on each in parallel by calling the helper script `scripts/run_diamond_round1_on_split_fastas.sh`.  
### split_diamond_round1_outputs.sh 
Splits the BLASTp output TSV by query accession and stores the results in `round1_diamond_split_outputs`. Calls the helper script `split_blast_table.sh.`  
### run_diamond_on_missing_sequences.ipynb
Runs DIAMOND on 11 HGT-chimeras from a previous pipeline run that were excluded from `mmseq_cluster_representatives.fasta`, along with any sequences in `mmseq_cluster_representatives.fasta` that failed to produce DIAMOND hits in the first run of `run_diamond_round1_on_split_fastas.sh`. Calls the helper scripts `split_blast_table.sh` and `run_diamond_round1_on_missing_fasta.sh`.  
### interval_demarcation_round1.py
Performs a modified version of the interval demarcation algorithm from https://doi.org/10.1371/journal.pcbi.1005889 on round 1 BLASTp results. Assigns preliminary "Meta" or "HGT" annotations to intervals depending on the taxonomic distribution of BLASTp hits.  
### split_intervals_round1.py
Using the results of interval demarcation, identifies putative HGT-chimeras with ≥1 HGT AND ≥1 Meta interval. Outputs `split_intervals.fasta` with each HGT-chimera interval ±10 amino acid residues as a separate sequence, with headers labeled as `genome accession;protein accession;annotation_(interval start,interval stop).` Also splits outputs into separated TSVs by query, stored in `round2_diamond_output_split`.  
### run_diamond_round2.sh
Runs round 2 DIAMOND BLASTp with demarcated intervals (`split_intervals.fasta`) as queries against NR.  
### run_diamond_round2_arthropod.sh
Runs round 2 DIAMOND BLASTp with demarcated intervals (`split_intervals.fasta`) as queries against custom database of arthropod proteins (`all_arthropod_concatenated_proteins`). Also splits outputs into separated TSVs by query, stored in `round2_diamond_output_arthropod`.  
### process_blast_round2.ipynb
Processes round 2 DIAMOND BLAST hits vs NR to confirm "Meta" or "HGT" annotations of each interval. Subsequently, HGT-chimeras in which non-arthropod hits to adjacent series of "HGT" and "Meta" intervals are found are filtered out. The remaining HGT-chimeras are output to a pickled dictionary and `.txt` file.  
### blast_plot_combined_one_two.py
Plots BLASTp plots for round 1 and 2 BLAST searches, showing taxonomic origin, aligned region against query, and e-value for all non-arthropod hits.  
### combine_blastplots_to_pdf.py
Combines BLASTp plots to make a PDF (only for 104 final representative primary chimeras).

## HMMER-based Inference
### build_hmms_from_round2blast.ipynb
Builds profile HMMs from arthropod BLAST hits for each interval separately. It then calls scripts to run `hmmsearch` vs the custom database of arthropod proteins (`all_arthropod_concatenated_proteins.fa`) and NR. Outputs are stored in the `hmmbuild` directory, with structure `protein_accession/interval/data.` Helper scripts are described below:  
### remove_redundant_seqs.awk
AWK script to remove any redundant sequences from interval FASTA before running MUSCLE alignment.  
### hmmbuild_muscle.sh
Runs MUSCLE with default parameters on `sub_seq.fasta`, a FASTA with the sub-interval of each hit.  
### hmmbuild_muscle_super5.sh
Runs MUSCLE with super5 for MSAs that failed to run due to a time-out error with standard MUSCLE.  
### concat_hmms.sh
Concatenates multiple profile HMMs into one file for submission to `hmmsearch`. Accepts a list of `~` delimited file paths.  
### hmmsearch_array.sbatch
Runs `hmmsearch` vs NR in a parallelized job array on profile HMMs in the `concatenated_hmms` directory.  
### hmmsearch_vs_arthropoda.sh
Runs `hmmsearch` vs customized arthropod protein database `all_arthropod_concatenated_proteins.fa`.  
### split_hmmer_csv.sh
Splits HMMER domtblout outputs into separated TSVs for each query.  

## Ankyrin Repeat and Transposable Element Filters
### transposable_element_and_ankyrin_repeat_filters.ipynb
Processes outputs from the webservers of NCBI CD-search and CENSOR (URLs in notebooks) to exclude ankyrin repeats and metazoan transposable elements (overlapping with HGT intervals).

## Orthologous Clustering and Phylogenetic Dataset Construction 
### extract_taxonomically_filtered_accessions.ipynb
Contains scripts to extract arthropod protein accessions from NR, used for subsequent filtering in phylogenetic database construction.  
### add_suppressed_aedes_albopictus_hmmsearch.ipynb
Add a secondary HGT-chimera of XP_021699539.1 recovered in the first pipeline iteration run on *A. albopictus* annotation release GCF_006496715.1, but later marked as an lncRNA in the *A. albopictus* annotation release available at the time of writing. We confirmed its expression and sequence via RT-PCR and Sanger sequencing after the first iteration, so manually added XP_029735553.1 back for consideration as a secondary HGT-chimera of XP_021699539.1.  
### hmmsearch_analysis_and_clustering.ipynb
Processes `hmmsearch` results into TSVs with headers. Then uses `hmmsearch` and BLAST results to identify secondary HGT-chimeras, perform orthologous clustering, verify secondary chimeras via interval BLAST search, and output a table of verified clusters with taxonomic information.  
### diamond_secondary.sh
Searches intervals of putative secondary chimeras vs NR with DIAMOND BLASTp. Called by `hmmsearch_analysis_and_clustering.ipynb.`  
### phylogenetic_dataset_construction.ipynb
Constructs FASTAs for phylogenetic inference on each separated interval using BLAST or `hmmsearch` results, then calls the helper scripts `align_iq_pipe.sh` or `align_iq_pipe_long.sh` to execute MUSCLE, trimAl, and IQ-TREE for tree inference.  
### root_annotate_upload_trees.ipynb
Executes scripts to root maximum likelihood trees via minimum ancestor deviation (using `mad.py` obtained from https://www.nature.com/articles/s41559-017-0193), annotate the files with iTOL annotation files for taxonomic labels, and upload to iTOL with the iTOL Python API.

## Downstream Analysis of HGT-Chimeras
### HGT_phylogenetic_origins.ipynb
Identifies taxa of sister and cousin branches to facilitate manual tree inspection; identifies likely donors and symbiont donors of HGT intervals (Figure 2A-B).  
### taxonomic_distribution_tables_and_figures.ipynb
Tabulates, analyzes, and plots data on the taxonomic distribution of HGT-chimeras. Used to generate SI Tables 1-6, Figure 1, and SI Figures 4-5.  
### analysis_of_cluster3.ipynb
Runs phylogenetic analysis on whole-protein alignments of representatives of cluster 3 for investigation of the hypothesis of inter-arthropod transfer.  
### within_genome_parent_analysis.ipynb
Performs 3 analyses related to the duplication-based chimera origin hypothesis:  
1. BLASTp-based within genome duplicate search (using the helper scripts `make_diamond_protein_db.sh` and `run_diamond_query.sh`),  
2. tree-based within genome relative search,  
3. tree-based search for other arthropod species with non-chimeric arthropods.  
### GC_codon.ipynb
Performs computations of GC content and codon use within HGT- and metazoan-intervals and compares them to an empirical background distribution generated by sampling. Generates associated plots.  
### expression_support.ipynb
Obtains expression support for HGT-chimeras by querying NCBI for the percentage of each transcript that is ab initio and a 'full'/'partial' expression support label.  
### PCR_alignments.ipynb
Obtains MSAs of translations of RT-PCR sequencing products with their respective RefSeq/GenBank predicted protein accessions (SI Text 2), using the helper script `pcr_align.sh.`  
### dnds_whole_gene_and_partition.ipynb
Runs dN/dS analysis on whole gene/CDS sequences, as well as partitioned analyses comparing HGT- and non-HGT-derived codons.  
### branch_model.ipynb
Runs branch-specific dN/dS models to test the hypothesis of neofunctionalization following chimera formation.  
### dnds_scripts
Contains the following helper scripts/files called by `dnds_whole_gene_and_partition.ipynb` and `branch_model.ipynb` to execute dN/dS analyses with PAML:  
#### run_muscle.sh
Runs MUSCLE to obtain a protein multiple sequence alignment (when only 2 chimeras are aligned per cluster).  
#### run_iqtree_dnds_pipe.sh
Runs MUSCLE, trimAl, and IQ-TREE to obtain maximum likelihood gene trees for dN/dS computation.  
#### run_pal2nal.sh
Runs PAL2NAL to obtain a codon alignment using both an input nucleotide CDS FASTA (`concatenated_nuc.fasta`) and a computed protein MSA (`MSA_concatenated_prot.fasta`).  
#### run_paml_m0.sh
Runs codeml in PAML to obtain gene/CDS-wide dN/dS estimates using the control file `m0.ctl`, seqfile `pal2nal.paml`, tree file `tree.newick`. Outputs `paml_output.out`.  
#### run_fixed_paml_whole_gene.sh
Runs codeml in PAML to obtain gene/CDS-wide likelihood estimates under the null hypothesis that dN/dS=1, using the control file `fm0.ctl`, seqfile `pal2nal.paml`, tree file `tree.newick`. Outputs `paml_output.out`.  
#### run_pal2nal_codon.sh
Runs PAL2NAL to output a "codon"-formatted codon alignment, rather than PAML output as in `run_pal2nal.sh`. This output format is used to compute the coordinates of the HGT interval for partitioned/fix-site models.  
#### run_partition_paml.sh
Runs codeml in PAML using partition/fixed site models, using the configuration file `m2.ctl` for the null model that assumes a single dN/dS value across sites and the file `m4.ctl` that permits different dN/dS values across sites.  
#### run_branch_paml.sh
Runs codeml in PAML using branch models, using the configuration file `0ch.ctl` for the null model that assumes a single dN/dS value across branches and the file `bch.ctl` for the model that permits different dN/dS values by branch.  
#### differential_expression.ipynb
Runs differential expression analysis on Eurytemora RNA-Seq data, calling the helper script `rna_pipe_paired.R`. Also should execute `deseq2eurytemora.R` after downloading and processing read data for differential expression analysis.
