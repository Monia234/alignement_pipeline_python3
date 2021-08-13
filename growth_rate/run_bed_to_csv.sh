#!/bin/bash

# Prepare Wochenende bam files for the bed to csv script (input for reproduction determiner)
# Links input files from one higher directory. Converts bam to bed.
# Filter out mouse human and mito chromosomes.
# Author: Sophia Poertner, 2021
# Usage1: conda activate wochenende
# Usage2: bash run_bed_to_csv.sh input.bam

# Bugs: if you experience problems, try deleting the growth_rate folder and running get_wochenende.sh again.

echo "Version 0.15 of run_bed_to_csv.sh"

# Changelog
# 0.15 - unlink files at end
# 0.14 - simplify naming, bugfixes
# 0.13 - add usage, correct runbatch_bed_to_csv.sh SLURM submission
# 0.12 - get input file from sbatch script for speedup
# 0.11 - link in bam, bam.txt and bai files, unlink later
# 0.10 - remove bedtools binary and use conda bedtools

# check if input exists
count_bam=`ls -1 ../*calmd.bam 2>/dev/null | wc -l`
count_bai=`ls -1 ../*calmd.bam.bai 2>/dev/null | wc -l`
count_bam_txt=`ls -1 ../*calmd.bam.txt 2>/dev/null | wc -l`

if [ $count_bam != 0 ]  && [ $count_bai != 0 ]  && [ $count_bam_txt != 0 ]
  then
  # link bam, bai and bam.txt files found by ls command to current directory
  #$1 is the input bam file given as the first argument
  ln -s $1 .
  ln -s ${1%bam}bam.txt .
  ln -s ${1%bam}bam.bai .
  #ls *
  bam=${1/..\//}

  bedtools bamtobed -i "$bam" > "${bam%.bam}.bed"

  bed="${bam%.bam}.bed"
  # filter - exclude mouse, human, mito chromosomes
  grep -v "^chr" "$bed" | grep -v "^1_1_1" > "${bed%.bed}.filt.bed"
  filtBedFile="${bed%.bed}.filt.bed"
  echo "INFO: Starting bed to csv for file $filtBedFile"
  # following line causes core dumps if the correct conda environment with pandas etc is not activated
  python3 bed_to_pos_csv.py -i $filtBedFile -p .

  # cleanup
  #rm "$bed"  # remove temp file
  if [[ ! -d "${bed%.bed}_subsamples" ]]
    then
    mkdir "${bed%.bed}_subsamples"
  fi

  csv_count=$(ls -1 "${bed%.bed}"*.csv 2>/dev/null | wc -l)
  if [[ $csv_count != 0 ]]
      then
      mv "${bed%.bed}"*.csv "${bed%.bed}_subsamples"
  fi
  echo "INFO: Completed file $bed"

  # echo "cleanup: unlink bam, bai and bam.txt files"
  # unlink bam, txt and bai files
  unlink $1
  unlink ${1%bam}bam.txt
  unlink ${1%bam}bam.bai
else
  echo "ERROR: no bam.txt and bai found for input bam. Can't convert to pos.csv"
fi