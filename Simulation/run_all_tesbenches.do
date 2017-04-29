##################################
# A very simple modelsim do file #
##################################

# 1) Create a library for working in
vlib work

# 2) Compile the half adder
vcom -93 -explicit -work work convolution_25D_tb.v

# 3) Load it for simulation
vsim Hardware/template/tb/layer_modules/convolution_25D_tb

# 4) Open some selected windows for viewing
view structure
view signals
view wave

# 5) Show some of the signals in the wave window
add wave *

# 6) Set some test patterns

# 7) Run the simulation for 40 ns
run -all
