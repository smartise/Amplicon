
#!/bin/bash

filename=$(ls -lt --time=ctime "/data" | grep '^d' | head -n 1 | awk '{print $NF}')

echo "the taken file is $filemname"

ssh "ocol0007@ebe-gpu01.hpda.ulb.ac.be" "mkdir -p '/mnt/ebe/AmpliconSequencingONT/$filename/fast5'"

scp data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5
scp data/$filename/*/*/fast5_pass/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5

ssh "ocol0007@ebe-gpu01.hpda.ulb.ac.be" 'bash /srv/home/ocol0007/Amplicon/Amplicon.sh '$filename''