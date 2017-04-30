##################################
# A very simple modelsim do file #
##################################

# 1 Create a library for working in
vlib work

# 2 Compile verilog files
set tb_dir ../Hardware_templates/tb
set v_dir ../Hardware_templates/v

# 2.1 Compile Test Benches
vlog $tb_dir/layer_modules/*.v
vlog $tb_dir/components/*.v
vlog $tb_dir/components/shift_reg/.v

# 2.2 Compile Source Files
vlog $v_dir/layer_modules/*.v
vlog $v_dir/components/*.v
vlog $v_dir/components/shift_reg/*.v
vlog $v_dir/components/megafunctions/*_signed.v


# 3 Load A Test Bench for Simulation
vsim convolution_25D_tb -L 220model_ver

# 4 Open some selected windows for viewing
#view structure
#view signals
#view wave

# 5 Show some of the signals in the wave window
#add wave *

run -all

vsim dense_2D_tb -L 220model_ver
