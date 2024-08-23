#!/bin/bash

# setting up the proper environment and screen 
conda activate amplicon_sorter
cd /mnt/ebe/AmpliconSequencingONT/

# instroducing the necessary information

read -p "Please enter the name of the experiment (be sure to tipe well):" filename
mkdir $filename
mkdir $filename/fast5

# retrieveing the data from the sequencer 

echo "##########################################"
echo "### Downloading the files              ###"
echo "##########################################"

password="026502925"

echo "Please choose an option from the list below:"

options=("p2-post" "min-post" "Quit")

# Display the options and prompt for a choice
select choice in "${options[@]}"; do
    case $choice in
        "p2-post")
            echo "You selected p2-post"
            echo "downloading from P2 solo post" 
            sshpass -p "$password" scp promethion@10.141.4.16/var/lib/minknow/data/$filename/*/*/fast5_fail/*.fast5 /$filename/fast5
            sshpass -p "$password" scp promethion@10.141.4.16/var/lib/minknow/data/$filename/*/*/fast5_pass/*.fast5 /$filename/fast5
            break
            ;;
        "min-post")
            echo "You selected min-post"
            echo "downloading from mini-post"
            sshpass -p "$password" scp minit@10.141.4.15/data/$filename/*/*/fast5_fail/*.fast5 /$filename/fast5
            sshpass -p "$password" scp minit@10.141.4.15/data/$filename/*/*/fast5_pass/*.fast5 /$filename/fast5
            break
            ;;
        "Quit")
            echo "Exiting the script."
            exit 0
            ;;
        *)  # Default case if no valid option is chosen
            echo "Invalid option. Please try again."
            ;;
    esac
done

# Basecalling and barcoding of the data set 

echo "##########################################"
echo "#### Basecalling from the fast5 folder ###"
echo "##########################################"

cd $filename

module load guppy/gpu-6.3.8_linux64

guppy_basecaller -i ./fast5 -s ./fastq_guppy_6.3.8_8.2 -c dna_r10.4.1_e8.2_400bps_sup.cfg -x auto

echo "##########################################"
echo "#### Barcoding the fastq files         ###"
echo "##########################################"

guppy_barcoder -i fastq_guppy_6.3.8_8.2/pass/ -s fastq_guppy_6.3.8_8.2_barcodes

echo "##########################################"
echo "#### Using amplicon sorter             ###"
echo "##########################################"

cd fastq_guppy_6.3.8_8.2_barcodes

(for i in {1..96}; do cat $(printf 'barcode%02d\n' $i)/*.fastq > $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -ho -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -min 200 -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); rm $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; done) 

# doing the Hairsplitter if necessar 

read -p "Do you want use hairsplitter? (yes/no): " answer

if [[ "$answer" == "yes" ]]; then
    
    echo "Executing the command..."
    echo "##########################################"
    echo "#### Using hairsplitter                ###"
    echo "##########################################"

    for i in {1..96}; do python /mnt/ebe/Hairsplitter/hairsplitter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d_consensussequences\n' $i).fasta -f $(printf 'barcode%02d\n' $i)/$(printf 'fastq_runid_*_0\n' $i).fastq -o $(printf 'barcode%02d\n' $i)/$(printf 'hairsplitter_barcode%02d\n' $i) -F -x amplicon; done

    echo "##########################################"
    echo "#### put all in one file               ###"
    echo "##########################################"

    for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'hairsplitter_barcode%02d\n' $i`/hairsplitter_final_assembly.fasta >> alldatahairsplitted.fasta ;done

elif [[ "$answer" == "no" ]]; then
    echo "merging without hairsplitter."
    for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`_consensussequences.fasta >> alldata1-96.fasta ;done
else
    echo "Invalid input. Please enter 'yes' or 'no'."
fi

