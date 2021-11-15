# Plot low qual SNV distributions
# Dr Zoe A Dyson (zoe.dyson@lshtm.ac.uk)
# Last updated November 15th 2021

# Import required packages
library(vcfR)
library(tidyverse)
library(ggplot2)
library(patchwork)

# Set up 'not in operator'
`%notin%` <- Negate(`%in%`)

# Import and reformat vcf file into table
vcf <- read.vcfR("B457_merged.filtered.bcf.vcf",
                 verbose = TRUE )
vcf2 <- tbl_df(vcf@fix)


# Import regions to exclude
regions <- read_tsv("CT18_repeats_phages_excluded_regions.tsv",
                      col_names=F) %>% type_convert()

# build vector of excluded regions
all_excuded_regions <- NULL
for (region in 1:nrow(regions)){
  all_excuded_regions <- c(all_excuded_regions, c(as.integer(regions[region,1]):as.integer(regions[region,2])))
}


vcf3 <- vcf2  %>%
  filter(as.numeric(POS) < 4809037) %>%
  filter(ALT %in% c("A","G","T","C")) %>%
  filter(FILTER == "LowQual") %>%
  filter(!grepl("INDEL", INFO)) %>%
  # Extract and create a new column for DP4 from INFO
  mutate(DP4=sub(".*?DP4=(.*?);.*", "\\1",
                 INFO)) %>%
  # Split DP4 across 4 columns
  separate(DP4, c("DP4_fwd_ref","DP4_rev_ref",
                  "DP4_fwd_alt","DP4_rev_alt"),
           sep=",") %>%
  # Calculate the total proportion of reads mapped
  # to each SNV
  mutate(total_DP4=(as.numeric(DP4_fwd_ref)+
                      as.numeric(DP4_rev_ref)+
                      as.numeric(DP4_fwd_alt)+
                      as.numeric(DP4_rev_alt))) %>%
  # Determine proportion of reads mapped to ref and alt
  mutate(prop_ref=
           as.numeric(((as.numeric(DP4_fwd_ref)+
                          as.numeric(DP4_rev_ref))/
                         as.numeric(total_DP4))),
         prop_alt=
           as.numeric(((as.numeric(DP4_fwd_alt)+
                          as.numeric(DP4_rev_alt))/
                         as.numeric(total_DP4)))) %>%
  # Try to pick up hets 
  mutate(AD=sub(".*?AD=(.*?);.*", "\\1",
                 INFO)) %>%
  # Split AD across 2 columns
  separate(AD, c("AD1","AD2"),sep=",") %>%
  # Get hets
  mutate(max_AD = pmax(AD1, AD2)) %>%
  mutate(het_calc = as.integer(max_AD)/as.integer(total_DP4)) %>%
  mutate(is_het = ifelse(het_calc < 0.9,"Het","Hom")) %>%
  filter(is_het=="Het") %>%
  arrange(as.numeric(POS)) %>%
  type_convert()


# plot low qual SNVs before exclusion
plot_points <- vcf3 %>%
  ggplot(aes(x=POS, y=prop_ref), colour="black") + 
  geom_point(alpha = 0.1, size=2) + 
  geom_point(aes(x=POS, y=prop_alt), colour="red",alpha = 0.1, size=2) + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic() + 
  ggtitle("All LowQual SNVs") + 
  ylab("Proportion of reads mapped") + 
  xlab("Position in reference")

plot_pos_depth <- vcf3 %>%
  ggplot(aes(x=POS,y=total_DP4), colour="black") + 
  geom_point() + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic()  + 
  ggtitle("All LowQual SNVs") + 
  xlab("Position in reference") +
  ylab("Read depth")

plot_pos <- vcf3 %>%
  ggplot(aes(x=POS), colour="black") + 
  geom_histogram(bins=200) + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic() + 
  ggtitle("All LowQual SNVs")+ 
  xlab("Position in reference") +
  ylab("Number of SNVs called")

# remove SNVs in excluded regions
vcf4 <- vcf3 %>%
  filter(as.integer(POS) %notin% all_excuded_regions)

# plot low qual SNVs after exclusion
plot_points_excluded <- vcf4 %>%
  ggplot(aes(x=POS, y=prop_ref), colour="black") + 
  geom_point(alpha = 0.1, size=2) + 
  geom_point(aes(x=POS, y=prop_alt), colour="red",alpha = 0.1, size=2) + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic()  + 
  ggtitle("Non-excluded LowQual SNVs") + 
  ylab("Proportion of reads mapped") + 
  xlab("Position in reference")

plot_pos_excluded <- vcf4 %>%
  ggplot(aes(x=POS), colour="black") + 
  geom_histogram(bins=200) + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic()  + 
  ggtitle("Non-excluded LowQual SNVs") + 
  xlab("Position in reference") +
  ylab("Number of SNVs called")

plot_pos_depth_excluded <- vcf4 %>%
  ggplot(aes(x=POS,y=total_DP4), colour="black") + 
  geom_point() + 
  scale_x_continuous(limits=c(0,4809037)) + 
  theme_classic()  + 
  ggtitle("Non-excluded LowQual SNVs") + 
  xlab("Position in reference") +
  ylab("Read depth")

# Arrange plots
plot_points/plot_pos_depth/plot_pos|plot_points_excluded/plot_pos_depth_excluded/plot_pos_excluded
