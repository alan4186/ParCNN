module top(
  input clock,
  input reset,

  // video inputs
  
  // hex outputs

);

// wire declaratations
// reg declarations



// camera refrence design

// shifting window and window selectors
window_wrapper window_inst(
  .clock(),
  .reset(),
  // buffer inputs
  .pixel_in(),
  .shift_left(),
  .shift_up(),
  // window inputs
  .kernel_x(), // the bottom right corner of the kernel position
  .kernel_y(), // the bottom right corner of the kernel position

  // the kernel sized view of the buffer to be fed into the multipliers
  .window_out()
)
genvar tree_count;
generate
for (tree_count = 0; tree_count < `NUM_KERNELS; tree_count = tree_count+1) begin : inst_mult_adder_trees
  // multiply adder trees
  mult_adder mult_adder_inst(
    .clock(clock),
    .reset(reset),
    .in(),
    .kernel(),
    .out()
  );
  mult_adder_ctrl ma_inst(
    .clock(),
    .reset(),
    .buffer_rdy(),
    .x_coord(),
    .ycoord(),
    .pixel_rdy()
  );
  // rectified linear function
  rect_linear rect_inst(
    .clock(clock),
    .reset(reset),
    .rect_in(),
    .rect_out(),
  );
  // RAM buffer
  fm_buffer fm_buffer_inst(
    .clock(),
    .reset(),
  );

end // for
end generate


// read port mux
read
// matrix multiply
// normalization
// hex decode


endmodule
