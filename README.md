# GHRU_SNV_Stats_Generator
GHRU SNV Quality Stats Generator provides summaries of high and low quality SNV calls from the GHRU mapping pipeline


## Cluster modules to load (and command to load them) before running script:

```
module load bsub.py/0.42.1

module load bcftools/1.2--h02bfda8_4

module load samtools/0.1.19--h94a8ba4_6
```

## Example usage (running from command prompt):
```
python2 GHRU_SNV_Stats_Generator.py --bcf *.bcf --excluded_regions CT18_repeats_phages_excluded_regions.tsv  --chromosome_size 4809037 --output_prefix test --save_high_lowqual False
```

## Example useage (batch submission to lsf):
```
bash run_bcf_batches.sh Wong2015_Tanzania
```

## What is in this repo?
**GHRU_SNV_Stats_Generator.py** - python script for extracting high (PASS) and low (LowQual) SNV calls from bcf files produced by the GHRU mapping pipeline.&nbsp;

**CT18_repeats_phages_excluded_regions.tsv** - Phage and repeat regions normally excluded from phylogenetic analysis of S. Typhi (CT18: accession no. AL513382).&nbsp;

**run_ghru_snv_stats_in_batches.sh** - wrapper script for batch submission of jobs via lsf cluster system.&nbsp;

**Plot_Low_Qual_SNV_Distribution.R** - example R plotting script - visualises the distribution of low qual SNV calls throughout the reference sequence both before an after the removal of those falling within repetitive and phage regions (normally excluded for phylogenetic analysis).&nbsp;




## Notes for selecting subsets to analyse:
```
while read file; do ln -s /lustre/scratch118/infgen/team216/jk27/typhinet/*/ghru_mapping/filtered_bcfs/${file}.filtered.bcf ./; done<ids.txt
```
Where ids.txt is a plain text file (e.g. created with nano) where one lane id is given per line.
