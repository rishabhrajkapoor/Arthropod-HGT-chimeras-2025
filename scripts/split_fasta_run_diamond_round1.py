from Bio import SeqIO
import subprocess

##load fasta of mmseqs2-clustered inputs
sequences = list(SeqIO.parse('/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/outputs/mmseq_cluster_representatives.fasta', "fasta"))

total_seqs = len(sequences)
num_files = 4
seqs_per_file = total_seqs // num_files
extra_seqs = total_seqs % num_files

current = 0

subprocess.run(['mkdir','/n/netscratch/extavour_lab/Everyone/Rishabh/split_input_fastas'])

##split the fasta into 4 and run diamond in parallel on each 
for i in range(num_files):
    filename = f"/n/netscratch/extavour_lab/Everyone/Rishabh/split_input_fastas/{i}.fasta"
    with open(filename, "w") as output_handle:
        end = current + seqs_per_file + (1 if i < extra_seqs else 0)
        SeqIO.write(sequences[current:end], output_handle, "fasta")
        current = end
    print(f"Written {filename}")
    subprocess.run(['sbatch', 'scripts/run_diamond_round1_on_split_fastas.sh',i])


