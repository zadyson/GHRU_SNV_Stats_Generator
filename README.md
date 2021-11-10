# GHRU_SNV_Stats_Generator
GHRU SNV Quality Stats Generator provides summaries of high and low quality SNV calls from the GHRU mapping pipeline


## Sanger modules to load (and command to load them) before running script:

module load bcftools/1.2--h02bfda8_4

module load samtools/0.1.19--h94a8ba4_6


## Example usage:

python2 GHRU_SNV_Stats_Generator.py --bcf ./bcfs/*.bcf --excluded_regions CT18_repeats_phages_excluded_regions.tsv  --chromosome_size 4809037 --output_prefix Collection_Name



## Notes for selecting subsets to analyse:

while read file; do ln -s /lustre/scratch118/infgen/team216/jk27/typhinet/*/ghru_mapping/filtered_bcfs/${file}.filtered.bcf ./; done<ids.txt
