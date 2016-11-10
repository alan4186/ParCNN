module top(
  input clock, 
  input reset,

  // video inputs
  
  // hex outputs

);

// wire declaratations

// window wires
wire [`WINDOW_VECTOR_BITWIDTH:0] window_content;
wire shift_left;
wire shift_up;

// multiply adder wires
wire [`X_COORD_BITWIDTH:0] ma_x_coord;
wire [`Y_COORD_BITWIDTH:0] ma_y_coord;
wire [`NUM_KERNELS-1:0] fm_pixel_vector; // one pixel from the end of each multiply adder tree
wire [`NUM_KERNELS-1:0] rectified_vector; // one pixel from the output of each rect-linear module 

// feature map RAM buffer wires
wire [`FM_ADDR_BITWIDTH:0] fm_wr_addr;

// reg declarations

// parameters
parameter BUFFER_X_POS = `SCREEN_X_WIDTH'd300;
parameter BUFFER_Y_POS = `SCREEN_Y_WIDTH'd300;

// camera refrence design

// shifting window and window selectors
window_wrapper window_inst(
  .clock(clock),
  .reset(reset),
  // buffer inputs
  .pixel_in(),
  .shift_left(shift_left),
  .shift_up(shift_up),
  // window inputs
  .kernel_x(ma_x_coord), // the bottom right corner of the kernel position
  .kernel_y(ma_y_coord), // the bottom right corner of the kernel position

  // the kernel sized view of the buffer to be fed into the multipliers
  .window_out(window_content)
)
window_ctrl window_ctrl_inst(
  .clock(clock),
  .reset(reset),
  .buffer_x(BUFFER_X_POS),
  .buffer_y(BUFFER_Y_POS),
  .screen_x(), // from demo
  .screen_y(),
  .shift_up(shift_up),
  .shift_left(shift_left),
  .buffer_rdy(),
);


// multiply-adder control module, inst outside of loop (only 1 is needed)
mult_adder_ctrl ma_inst(
  .clock(clock),
  .reset(reset),
  .buffer_rdy(),
  .x_coord(ma_x_coord),
  .y_coord(ma_y_coord),
  .pixel_rdy()
);
genvar tree_count;
generate
for (tree_count = 0; tree_count < `NUM_KERNELS; tree_count = tree_count+1) begin : inst_mult_adder_trees
  // multiply adder trees
  mult_adder mult_adder_inst(
    .clock(clock),
    .reset(reset),
    .in(window_content),
    .kernel(),
    .out(fm_pixel_vector[tree_count])
  );

  // rectified linear function
  rect_linear rect_inst(
    .clock(clock),
    .reset(reset),
    .rect_in(fm_pixel_vector[tree_count]),
    .rect_out(rectified_vector[tree_count]),
  );
  // Feature Map RAM buffer
  fm_buffer fm_buffer_inst(
    .clock(clock),
    .reset(reset),
    .wraddress(),
    .data(rectified_vector[tree_count]),
    .wren(),
    .rdaddress(),
    .q()
  );

  // Weight Matrix Buffer

end // for
end generate

fm_coord_sr fm_coord_sr_inst(
  .clock(clock),
  .reset(reset),
  .x_coord(ma_x_coord),
  .y_coord(ma_y_coord),
  .fm_x_coord(fm_x_coord),
  .fm_y_coord(fm_y_coord)
);


feature_map_buffer_ctrl(
  .clock(clock),
  .reset(reset),
  .data_rdy(),
  .xcoord(fm_y_coord),// must hold coords through tree
  .ycoord(fm_y_coord),
  .addr(fm_wr_addr),
  .buffer_full()
);


// read port mux
read_port_mux port_mux_inst(
  .clock(clock),
  .reset(reset),
  .ram_select(),
  .buffer_data_vector(),
  .data_out()
);

// matrix multiply
genvar np_counter;
generate
for (np_counter=0; np_counter<`NUM_CLASSES; np_counter=np_counter+1) begin : np_inst_loop
  np_matrix_mult mm_inst(
    .clock(clock),
    .reset(reset),
    .feature_pixel(),
    .weight(),
    .sum(),
    .dval(),
    .buf_addr()
  );
end // for
endgenerate
// normalization
// hex decode


endmodule
