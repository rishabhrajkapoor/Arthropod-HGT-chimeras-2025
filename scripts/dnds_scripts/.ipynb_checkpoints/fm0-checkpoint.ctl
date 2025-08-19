seqfile = pal2nal.paml
treefile = tree.newick
outfile = fix_omega_paml_output.out
noisy = 0              * How much rubbish on the screen
verbose = 1              * More or less detailed report

seqtype = 1              * Data type
ndata = 1           * Number of data sets or loci
icode = 0              * Genetic code 
cleandata = 1              * Remove sites with ambiguity data?

model = 0         * Models for ω varying across lineages
NSsites = 0          * Models for ω varying across sites
CodonFreq = 7        * Codon frequencies
estFreq = 0        * Use observed freqs or estimate freqs by ML
clock = 0          * Clock model
fix_omega = 1         * Estimate or fix omega
omega = 1        * Initial or fixed omega