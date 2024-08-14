##########################################
#### Basecalling from the fast5 folder ###
##########################################

module load guppy/gpu-6.3.8_linux64

guppy_basecaller -i ./fast5 -s ./fastq_guppy_6.3.8_8.2 -c dna_r10.4.1_e8.2_400bps_sup.cfg -x auto

##########################################
#### Barcoding the fastq files         ###
##########################################

guppy_barcoder -i fastq_guppy_6.3.8_8.2/pass/ -s fastq_guppy_6.3.8_8.2_barcodes

##########################################
#### Using amplicon sorter             ###
##########################################

cd fastq_guppy_6.3.8_8.2_barcodes

(for i in {1..96}; do cat $(printf 'barcode%02d\n' $i)/*.fastq > $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -ho -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -min 200 -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); rm $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; done) & disown

read -p "Do you want to proceed with the command? (yes/no): " answer

if [[ "$answer" == "yes" ]]; then
    # Put your command here
    echo "Executing the command..."
    ##########################################
    #### Using hairsplitter                ###
    ##########################################

    for i in {1..96}; do python /mnt/ebe/Hairsplitter/hairsplitter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d_consensussequences\n' $i).fasta -f $(printf 'barcode%02d\n' $i)/$(printf 'fastq_runid_*_0\n' $i).fastq -o $(printf 'barcode%02d\n' $i)/$(printf 'hairsplitter_barcode%02d\n' $i) -F -x amplicon; done

    ##########################################
    #### put all in one file               ###
    ##########################################

    for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'hairsplitter_barcode%02d\n' $i`/hairsplitter_final_assembly.fasta >> alldatahairsplitted.fasta ;done

elif [[ "$answer" == "no" ]]; then
    echo "merging without hairsplitter."
    for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`_consensussequences.fasta >> alldata1-96.fasta ;done
else
    echo "Invalid input. Please enter 'yes' or 'no'."
fi

