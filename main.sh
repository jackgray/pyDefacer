#!/bin/env bash
'''
USAGE:

  ./main.sh /path/to/main/bids/directory [bids]

  use second position argument to specify "bids" or leave blank for flat structured derivatives folder (pseudo bids)
    - retains directory structure if input has bids structure

'''

is_bids=$2
bidsdir=$1
derivatives_dir=${bidsdir}/derivatives/sub-*/ses-1*
mkdir -p $derivatives_dir
artifacts_dir=${bidsdir}/artifacts
mkdir -p $artifacts_dir

count=0
list=$(find ${derivatives_dir} -type f -name "*.nii*" ) #| tr " " "\n")
printf "\n${list}\n\n"
while IFS=' ' read -ra ITEMS; do
  for f in "${ITEMS[@]}"; do
    echo $f
    ((total_count++))

    if [[ "$is_bids" == 'bids' ]]; then
      subj=$(echo ${f} | rev | cut -d'/' -f 4 | rev | tr -d 'sub-' )
      echo subj: $subj
      ses=$(echo ${f} | rev | cut -d'/' -f 3 | rev | tr -d 'ses-')
      echo ses: $ses
      outdir=${artifacts_dir}/sub-${subj}/ses-${ses}/anat
      mkdir -p $outdir
    else outdir=${artifacts_dir}
    fi
    file="${outdir}/$(echo $f | cut -d"." -f 1 | rev | cut -d"/" -f 1 | rev )-defaced.nii.gz"
    if [[ ! -f "$file" ]]; then
          printf "\nExporting as $file"	
          
          pydeface --verbose --debug $f --outfile $file
          
          # # remove file from derivatives if successful (output file exists and is more than 5mb)
          # if [[ -f "$file" ]] && (( $(wc -c < "${file}") > 5000000 )); then
          #   printf "\nDefacing was successful. Removing ${f}\n"
          #   subj_folder=${derivatives_dir}/*subj*
          #   ses_folder=${subj_folder}/ses-${ses}*
          #   # rm -r $(find ${derivatives_dir} -type d -name ses-${subj}
          #   # delete subj folder if dir is empty
          #   # if (( $(ls ${subj_folder} | wc -l ) == 0)); then
          #   #   rm -r ${subj_folder}
          #   # else printf "\nUnprocessed sessions are still in this folder:\n $(ls ${subj_folder})\n"
          #   # fi
          # fi
          ((deface_count++))
    else
        printf "\nDefaced file ${file} already exists. Skipping.\n"
    fi
	# mv $f ./done
    printf "\n$f" >> ${derivatives_dir}/defaced.tsv
  done
done <<< "${list}"    # followback function puts list into ITEMS array separated by the temporarily assigned IFS
    
printf "\nScanned $total_count files in total. \nDefaced $deface_count of them.\n\n\n
