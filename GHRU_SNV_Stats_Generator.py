#!/usr/bin/env python
#
# GHRU SNV Quality Stats Generator
# Dr Zoe A. Dyson (zoe.dyson@lshtm.ac.uk)
#

# Import required packages
from argparse import (ArgumentParser, FileType)
import os, sys, re, collections, operator

# Version number
__version__='0.0.1'

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

	return parser.parse_args()


# main function
def main():
	args = parse_args()

	# Output summary file with header
	output_snv_summary = open("Summary.csv", "w")
	output_snv_summary.write("File \t PASS \t LowQual \t Percent_LowQual \n")

	# Open bcf file
	for bcf in args.bcf:
				# Convert bcf to vcf and make vcf file
				os.system("bcftools view " + bcf + " | bcftools view > " + bcf + ".vcf")

				# Set counters to zero
				good_snv_count = 0
				bad_snv_count = 0

				# Open created vcf file
				bcf_file = open(bcf + ".vcf", 'r')

				# Extract good/bad SNV calls & ratio
				for line in bcf_file:
					if not line.startswith('#'):
						x = line.rstrip().split()
						if int(x[1]) <= args.chromosome_size:
							if (x[6]=="PASS"):
								good_snv_count = good_snv_count + 1
							if (x[6]=="LowQual"):
								bad_snv_count = bad_snv_count + 1
				good_bad_percent = (float(bad_snv_count)/float(good_snv_count))*100

				# Close file for buffering
				bcf_file.close()
				# delete temp vcf file
				os.system("rm " + bcf + ".vcf")
				# Output summary data
				output_snv_summary.write(bcf + '\t' + 
					str(good_snv_count) + '\t' + str(bad_snv_count) + '\t' + str(good_bad_percent) + '\n')
	output_snv_summary.close()

# call main function
if __name__ == '__main__':
	main()
