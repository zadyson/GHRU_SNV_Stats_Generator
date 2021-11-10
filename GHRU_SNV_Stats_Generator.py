#!/usr/bin/env python
#
# GHRU SNV Quality Stats Generator
# Dr Zoe A. Dyson (zoe.dyson@lshtm.ac.uk)
#
# Documentation - https://github.com/zadyson/GHRU_SNV_Stats_Generator
#
# Dependencies:
#	 SAMtools and bcftools are required.
#
# Last modified - November 10th, 2021
#

# Import required packages
from argparse import (ArgumentParser, FileType)
import os, sys, re, collections, operator

# Version number
__version__='0.0.3'

# Set up argument parser 
def parse_args():
	"Parse the input arguments, use '-h' for help"
	parser = ArgumentParser(description='Quality stats for SNVs called by GHRU mapping pipeline')
	parser.add_argument('--version', action='version', version='GHRU SNV Quality Stats Generator v' + __version__,
		help="Show version number and exit")
	parser.add_argument('--bcf', nargs='+', type=str, required=True,
		help='File path to bcf(s) to be analysed')
	parser.add_argument('--chromosome_size', type=int, required=True,
		help='Size of reference chromsome')
	parser.add_argument('--output_prefix', type=str, required=True,
		help='Output file prefix')

	return parser.parse_args()


# main function
def main():
	args = parse_args()

	# Get location of script
	pwd = os.getcwd()

	# Output summary file with header
	output_snv_summary = open(args.output_prefix  + "_snv_qc_summary.tsv", "w")
	output_snv_summary.write("File \t PASS \t LowQual \t Percent_LowQual \n")

	# Open bcf file
	for bcf in args.bcf:
				# Convert bcf to vcf and make temp vcf file in script directory
				os.system("bcftools view " + bcf + " | bcftools view > " + pwd + "/" + os.path.basename(bcf) + ".vcf")

				# initiate counter variables to zero
				pass_snv_count = 0
				lowqual_snv_count = 0
				lowqual_percent = 0

				# Open created vcf file
				bcf_file = open(pwd + "/" + os.path.basename(bcf) + ".vcf", 'r')

				# Extract PASS/LowQual SNV calls & ratio
				for line in bcf_file:
					# Ignore header lines
					if not line.startswith('#'):
						# Ignore indels
						if "INDEL" not in line:
							x = line.rstrip().split()
							# Ignore reference alleles
							if x[4]!=".":
								# Ingore concatenated sequences (e.g. plasmids)
								if int(x[1]) <= args.chromosome_size:
									# Count PASS and LowQual SNVs
									if (x[6]=="PASS"):
										pass_snv_count = pass_snv_count + 1
									if (x[6]=="LowQual"):
										lowqual_snv_count = lowqual_snv_count + 1

				# Get percentage of low quality SNVs
				lowqual_percent = (float(lowqual_snv_count)/float(pass_snv_count))*100

				# Close file for buffering
				bcf_file.close()

				# delete temp vcf file
				os.system("rm " + pwd + "/" + os.path.basename(bcf) + ".vcf")

				# Output summary data
				output_snv_summary.write(os.path.basename(bcf) + '\t' + 
					str(pass_snv_count) + '\t' + str(lowqual_snv_count) + '\t' + str(lowqual_percent) + '\n')

	# Close output file for buffering
	output_snv_summary.close()

# call main function
if __name__ == '__main__':
	main()
