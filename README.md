# GHRU_SNV_Stats_Generator
GHRU SNV Quality Stats Generator provides summaries of high and low quality SNV calls from the GHRU mapping pipeline

## What is in this repo?
**GHRU_SNV_Stats_Generator.py** - python script for extracting high (PASS) and low (LowQual) SNV calls from bcf files produced by the GHRU mapping pipeline (available at: https://gitlab.com/cgps/ghru/pipelines/snp_phylogeny/).  Output is a tsv file of PASS and LowQual SNVs both inside and outside excluded reigons (e.g. repetitive and prophage reigons normally exlcuded for phylogentic analyses).  &nbsp;

#### Example output:
```
column -t example_snv_qc_summary.tsv

File                                 PASS    LowQual  Percent_LowQual  Non-excluded_PASS  Non-excluded_LowQual  Non-excluded_percent_LowQual
10060_5#21.filtered.bcf              562     239      42.5266903915    471                35                    7.43099787686
10071_3#74.filtered.bcf              558     239      42.8315412186    471                42                    8.91719745223
10209_5#27.filtered.bcf              369     256      69.3766937669    269                70                    26.0223048327
10561_2#28.filtered.bcf              307     267      86.9706840391    218                106                   48.623853211
10561_2#34.filtered.bcf              312     218      69.8717948718    216                59                    27.3148148148
13566_1#17.filtered.bcf              442     173      39.1402714932    189                2                     1.0582010582
22420_1#100.filtered.bcf             581     143      24.6127366609    384                4                     1.04166666667
22420_1#88.filtered.bcf              542     158      29.1512915129    379                3                     0.791556728232
23099_8#14.filtered.bcf              316     235      74.3670886076    216                4                     1.85185185185
23099_8#15.filtered.bcf              324     180      55.5555555556    216                4                     1.85185185185
23584_2#12.filtered.bcf              779     200      25.6739409499    481                9                     1.8711018711
23584_2#19.filtered.bcf              780     192      24.6153846154    481                8                     1.6632016632
23584_2#37.filtered.bcf              788     188      23.8578680203    482                10                    2.07468879668
```


**CT18_repeats_phages_excluded_regions.tsv** - Phage and repeat regions normally excluded from phylogenetic analysis of S. Typhi (CT18: accession no. AL513382).&nbsp;

**run_ghru_snv_stats_in_batches.sh** - wrapper script for batch submission of jobs via lsf cluster system.&nbsp;

**Plot_Low_Qual_SNV_Distribution.R** - example R plotting script - visualises the distribution of low qual SNV calls throughout the reference sequence both before an after the removal of those falling within repetitive and phage regions (normally excluded for phylogenetic analysis).&nbsp;

#### Example plot from above R code
- Note that '--save_high_lowqual True' must be used with the above python script to save compatible vcf files (converted from bcf) for use with the R script. The default is 'False' as the files can be very large (~700Mb).  It may be worth changing the percentage cutoff (10% non-excluded lowqual SNVs) in the code for saving vcfs depending on the QC issue being diagnosed.
- For other more sophisticatd vcf visualisation options please see: https://github.com/zadyson/SNV_plotter 
![image](https://user-images.githubusercontent.com/8507671/141644457-7f01fa9c-bc63-4ea9-b455-7f0cac2391a8.png)


## Key information

### Cluster modules to load (and command to load them) before running script:

```
module load bsub.py/0.42.1

module load bcftools/1.2--h02bfda8_4

module load samtools/0.1.19--h94a8ba4_6
```

### Example usage (running from command prompt):
```
python2 GHRU_SNV_Stats_Generator.py --bcf *.bcf --excluded_regions CT18_repeats_phages_excluded_regions.tsv  --chromosome_size 4809037 --output_prefix test --save_high_lowqual False
```

### Example useage (batch submission to lsf):
```
bash run_bcf_batches.sh Wong2015_Tanzania
```

#### Notes for selecting subsets to analyse:
```
while read file; do ln -s /lustre/scratch118/infgen/team216/jk27/typhinet/*/ghru_mapping/filtered_bcfs/${file}.filtered.bcf ./; done<ids.txt
```
- Where ids.txt is a plain text file (e.g. created with nano) where one lane id is given per line.
