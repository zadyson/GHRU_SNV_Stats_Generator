#!/bin/bash

NAG=$#

if [ $NAG -ne 1 ]
then
  exit;
fi

DATASET=$1

mkdir $DATASET
cd $DATASET

for bcf in  /lustre/scratch118/infgen/team216/jk27/typhinet/$DATASET/ghru_mapping/filtered_bcfs/*.bcf
do
  bsub.py 1 python2 ../GHRU_SNV_Stats_Generator/GHRU_SNV_Stats_Generator.py  --bcf $bcf --excluded_regions ../GHRU_SNV_Stats_Generator/CT18_repeats_phages_excluded_regions.tsv --chromosome_size 4809037 --output_prefix $(basename -- $bcf) --save_high_lowqual False
  sleep 1
done
