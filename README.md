# GHRU_SNV_Stats_Generator
GHRU SNV Quality Stats Generator provides summaries of high and low quality SNV calls from the GHRU mapping pipeline

## What is in this repo?
**GHRU_SNV_Stats_Generator.py** - python script for extracting high (PASS) and low (LowQual) SNV calls from bcf files produced by the GHRU mapping pipeline (available at: https://gitlab.com/cgps/ghru/pipelines/snp_phylogeny/).  Output is a tsv file of PASS and LowQual SNVs both inside and outside excluded reigons (e.g. repetitive and prophage reigons normally exlcuded for phylogentic analyses).  &nbsp;

#### Example output:
```
column -t example_snv_qc_summary.tsv
File                      PASS  LowQual  Percent_LowQual  Hets  Percent_Hets   Non-excluded_PASS  Non-excluded_LowQual  Non-excluded_percent_LowQual  Non-excluded_Hets  Non-excluded_percent_Hets
23584_2#44.filtered.bcf   782   202      25.831202046     17    2.17391304348   485                7                     1.44329896907                 2                  0.412371134021
B457_merged.filtered.bcf  533   184      34.521575985     27    5.06566604128   374                44                    11.7647058824                 7                  1.87165775401
```

**CT18_repeats_phages_excluded_regions.tsv** - Phage and repeat regions normally excluded from phylogenetic analysis of S. Typhi (CT18: accession no. AL513382).&nbsp;

**run_ghru_snv_stats_in_batches.sh** - wrapper script for batch submission of jobs via lsf cluster system.&nbsp;

**Plot_Low_Qual_SNV_Distribution.R** - example R plotting script - visualises the distribution of low qual SNV calls throughout the reference sequence both before an after the removal of those falling within repetitive and phage regions (normally excluded for phylogenetic analysis).&nbsp;

#### Example plot from above R code
- Note that '--save_high_lowqual True' must be used with the above python script to save compatible vcf files (converted from bcf) for use with the R script. The default is 'False' as the files can be very large (~700Mb).  It may be worth changing the percentage cutoff (10% non-excluded lowqual SNVs) in the code for saving vcfs depending on the QC issue being diagnosed.  Red points indicate the alternative allele, black points indicate the reference allele.
- For other more sophisticatd vcf visualisation options please see: https://github.com/zadyson/SNV_plotter 
![image](https://user-images.githubusercontent.com/8507671/141830554-76c78c17-7d90-427f-9fba-efd2e816455f.png)



## Example usage and key information

### Cluster modules (and dependancies) to load before running the script:

```
module load bsub.py/0.42.1

module load bcftools/1.2--h02bfda8_4

module load samtools/0.1.19--h94a8ba4_6
```
- Note bsub.py is only required if submitting batches of jobs to the Sanger lsf cluster system.  


### Example usage (running from command prompt):
```
python2 GHRU_SNV_Stats_Generator.py --bcf *.bcf --excluded_regions CT18_repeats_phages_excluded_regions.tsv  --chromosome_size 4809037 --output_prefix test --save_high_lowqual False
```

### Example useage (batch submission to lsf):
```
bash run_bcf_batches.sh Wong2015_Tanzania
```

#### Suggestions for selecting subsets of a larger dataset to analyse
```
while read file; do ln -s /lustre/scratch118/infgen/team216/jk27/typhinet/*/ghru_mapping/filtered_bcfs/${file}.filtered.bcf ./; done<ids.txt
```
- Where ids.txt is a plain text file (e.g. created with nano) where one lane id is given per line.
