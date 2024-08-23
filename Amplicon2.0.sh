#!/bin/bash

read -p "Please enter the name of the experiment (be sure to tipe well):" filename

echo "##########################################"
echo "### conection to server                ###"
echo "##########################################"

password1="-Col1996"                                                                                                  
sshpass -p "$password1" ssh ocol0007@ebe-gpu01.hpda.ulb.ac.be

echo "##########################################"
echo "### making the folders                 ###"
echo "##########################################"

mkdir /mnt/ebe/AmpliconSequencingONT/$filename
mkdir /mnt/ebe/AmpliconSequencingONT/$filename/fast5
exit

echo "##########################################"
echo "### downloading the data              ###"
echo "##########################################"

password2="026502925"

echo "where is the data located"
options=("p2-post" "min-post" "Quit")

# Display the options and prompt for a choice
select choice in "${options[@]}"; do
    case $choice in
        "p2-post")
            echo "You selected p2-post"
            echo "connecting to p2-solo" 
            sshpass -p "$password2" ssh promethion@10.141.4.16

            echo "transfering the fail" 
            sshpass -p "$password1" scp /var/lib/minknow/data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5 

            echo "transfering the pass" 
            sshpass -p "$password1" scp /var/lib/minknow/data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5 
            break
            ;;
        "min-post")
            echo "You selected min-post"
            echo "downloading from mini-post"
            sshpass -p "$password2" ssh promethion@10.141.4.16

            echo "transfering the fail" 
            sshpass -p "$password1" scp data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5 

            echo "transfering the pass" 
            sshpass -p "$password1" scp data/$filename/*/*/fast5_fail/*.fast5 ocol0007@ebe-gpu01.hpda.ulb.ac.be:/mnt/ebe/AmpliconSequencingONT/$filename/fast5 
            
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
exit 

echo "##########################################"
echo "#### reconecting to the server         ###"
echo "##########################################"

password1="-Col1996"                                                                                                  
sshpass -p "$password1" ssh ocol0007@ebe-gpu01.hpda.ulb.ac.be
screen -r -d Basecalling$
cd /mnt/ebe/AmpliconSequencingONT/$filename/
 #bbash Amplicon.sh 
