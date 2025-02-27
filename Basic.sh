#!/bin/bash
filename=$(ls -lt "/mnt/ebe/AmpliconSequencingONT" | grep '^d' | head -n 1 | awk '{print $9}')

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

guppy_basecaller -i /mnt/ebe/AmpliconSequencingONT/$filename/fast5 -s /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2 -c dna_r10.4.1_e8.2_400bps_sup.cfg -x auto --do_read_splitting

echo "##########################################"
echo "#### Barcoding the fastq files         ###"
echo "##########################################"

# notification command 
curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage" \
     -d chat_id="$chat_id" \
     -d text="Basecalling done, staring the demultiplexing"

guppy_barcoder -i /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2/pass/ -s /mnt/ebe/AmpliconSequencingONT/$filename/fastq_guppy_6.3.8_8.2_barcodes
