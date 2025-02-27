#!/bin/bash

echo "Please enter the experiment name:"
read filename
echo "The experiment is, $filename!"

ssh "ocol0007@ebe-gpu01.hpda.ulb.ac.be" "mkdir -p '/mnt/ebe/AmpliconSequencingONT/$filename/fast5'"

scp /var/lib/minknow/data/$filename/*/*/fast5_fail/unclassified/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5
scp /var/lib/minknow/data/$filename/*/*/fast5_pass/unclassified/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5
scp /var/lib/minknow/data/$filename/*/*/fast5_skip/unclassified/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5
