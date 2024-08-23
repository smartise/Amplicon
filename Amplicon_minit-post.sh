
#!/bin/bash

read -p "Please enter the name of the experiment (be sure to tipe well):" filename

ssh "ocol0007@ebe-gpu01.hpda.ulb.ac.be" "mkdir -p '/mnt/ebe/AmpliconSequencingONT/$filename/fast5'"

scp data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5
scp data/$filename/*/*/fast5_pass/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5

ssh "ocol0007@ebe-gpu01.hpda.ulb.ac.be" 'bash /srv/home/ocol0007/Amplicon/Amplicon.sh '$filename''