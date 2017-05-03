#!/bin/bash
# This script runs all of the testbenches and prints the output to stdout


# The modelsim vsim executable path
VSIM=~/altera/15.0/modelsim_ase/linuxaloem/vsim

# Load Desin
$VSIM -batch -do load_files.do
# add testbenches here, seperate with spaces
TESTBENCHES=(adder_tree_32bit_tb mult_adder_tb ram_sr_tb\
  parallel_out_sr_tb layer_sr_tb dense_sr_tb convolution_2D_tb\
  convolution_25D_tb dense_2D_tb dense_25D_tb relu_tb bias_tb\
  requantize_tb mult_8bit_signed_tb add_8bit_signed_tb add_32bit_signed_tb)

# inlude any extra libraries needed in the braces after the -L, seperate with commas
for i in ${TESTBENCHES[@]}; do
  # print blank lines for clarity
  echo -e '\n\n'

  # use this line for jsut one liberary
  $VSIM -batch -quiet $i -do "run -all; quit"  -L 220model_ver

  # Uncomment and add extra libraries in the braces with no spaces. Comment out line above
  #$VSIM -batch $i -do "run -all; quit"  -L\ {220model_ver,<NEW_LIBRARY_HERE>}

done
