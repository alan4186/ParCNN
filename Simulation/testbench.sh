#!/bin/bash
# This script runs all of the testbenches and prints the output to stdout


# The modelsim vsim executable path
VSIM=~/altera/15.0/modelsim_ase/linuxaloem/vsim

# Load Desin
$VSIM -batch -do load_files.do

# use this line for jsut one liberary
$VSIM -batch -quiet $1 -do "run -all; quit"  -L 220model_ver

# Uncomment and add extra libraries in the braces with no spaces.
# Comment out line above
#$VSIM -batch $1 -do "run -all; quit"  -L\ {220model_ver,<NEW_LIBRARY_HERE>}
