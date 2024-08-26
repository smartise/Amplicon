#!/bin/bash
echo "Please enter the experiment name:"
read filename
echo "The experiment is, $filename!"

#notification ID 
bot_token="7502468804:AAFZwmUtgoRW7oowd3cEKikPQ5M2QTIckLQ"
chat_id="7541017945"

# instroducing the necessary information
echo "##########################################"
echo "#### Basecalling from the fast5 folder ###"
echo "##########################################"

# notification command 
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="starting the basecalling"


module load guppy/gpu-6.3.8_linux64

guppy_basecaller -i /mnt/ebe/AmpliconSequencingONT/$filename/fast5 -s /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2 -c dna_r10.4.1_e8.2_400bps_sup.cfg -x auto

echo "##########################################"
echo "#### Barcoding the fastq files         ###"
echo "##########################################"

# notification command 
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="Basecalling done, staring the demultiplexing"

guppy_barcoder -i /mnt/ebe/AmpliconSequencingONT/$filenamefastq_guppy_6.3.8_8.2/pass/ -s /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2_barcodes

echo "##########################################"
echo "#### Using amplicon sorter             ###"
echo "##########################################"

# notification command 
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="demultiplexing done, starting the amplicon_sorter"
     
cd /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2_barcodes

(for i in {1..96}; do cat $(printf 'barcode%02d\n' $i)/*.fastq > $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -ho -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); python3 amplicon_sorter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq -min 200 -np 40 -o $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i); rm $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i).fastq; done) 

for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`/`printf 'barcode%02d\n' $i`_consensussequences.fasta >> data.fasta ;done

# doing the Hairsplitter 
conda activate hairsplitter

# notification command 
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="amplicon done, doing the hairsplitter"
  

for i in {1..96}; do python /mnt/ebe/Hairsplitter/hairsplitter.py -i $(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d\n' $i)/$(printf 'barcode%02d_consensussequences\n' $i).fasta -f $(printf 'barcode%02d\n' $i)/$(printf 'fastq_runid_*_0\n' $i).fastq -o $(printf 'barcode%02d\n' $i)/$(printf 'hairsplitter_barcode%02d\n' $i) -F -x amplicon; done

#putting all into one file 
for i in {1..96}; do cat `printf 'barcode%02d\n' $i`/`printf 'hairsplitter_barcode%02d\n' $i`/hairsplitter_final_assembly.fasta >> hairsplitteddata.fasta ;done

# Send a notification message to Telegram
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="The script has finished running on the server. you can now download the files "