#####################################################
# Create Modelsim library and compile design files. #
#####################################################

# Create a library for working in
vlib work

set tb_dir ../Hardware_templates/tb
set v_dir ../Hardware_templates/v

# Compile Test Benches
vlog -quiet $tb_dir/layer_modules/*.v
vlog -quiet $tb_dir/components/*.v
vlog -quiet $tb_dir/components/shift_reg/*.v

# Compile Source Files
vlog -quiet $v_dir/layer_modules/*.v
vlog -quiet $v_dir/components/*.v
vlog -quiet $v_dir/components/shift_reg/*.v
vlog -quiet $v_dir/components/megafunctions/*_signed.v

quit
