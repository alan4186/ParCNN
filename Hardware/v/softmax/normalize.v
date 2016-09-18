module normalize(
  input clock,
  input reset,
  input [`NN_WIDTH*`NUM_CLASSES-1:0] in_vector,
  output [`NORM_OUT_BITWIDTH*`NUM_CLASSES-1:0] out_vector
);

// wire declarations
wire [`FFN_OUT_BITWIDTH:0] in_vector_wire [`NUM_CLASSES];
wire [`NORM_OUT_BITWIDTH:0] adder_tree_wire [(`NUM_CLASSES*2)-1];
wire [`NORM_OUT_BITWIDTH:0] out_vector_wire [`NUM_CLASSES];

// reg declarations


// connect input vector to wire array
genvar i;
generate
for(i = 0; i < `NUM_CLASSES; i=i+1) begin
    assign vector_wire[i] = in_vector[`NN_WIDTH*i:(`NN_WIDTH*i)-1];
  end
endgenerate

// sum inputs
genvar j;
generate
for(j= (`NUM_CLASSES*2)-1 ; j <=3 ; j=j-2) begin : sum_inputs
  always@(posedge clock or negedge reset) begin
    if( reset == 1'b0) begin
      adder_tree_wire[j-1] <= `NORM_OUT_BITWIDTH'd0;
      adder_tree_wire[j-2] <= `NORM_OUT_BITWIDTH'd0;
    end else begin
      add2 add2_inst(
        .clock(clock),
        .reset(reset),
        .opperand_a(adder_tree_wire[j-2]),
        .opperand_b(adder_tree_wire[j-1]),
        .sum(adder_tree_wire[((j-1)/2)-1])
      );  
    end // else reset
  end // always
end // for
endgenerate

// normalize inputs
genvar k;
generate
for (k=0; k < `NUM_CLASSES; k=k+1) begin : divide_by_sum
  always@(posedge clock or negedge reset) begin
    if(reset == 1'b0) begin
      out_vector_wire[k] <= `NORM_OUT_BITWIDTH'd0;
    end else begin 
      out_vector_wire[k] <= in_vector_wire[k] / adder_tree_wire[0];
    end
  end // always
end // for


// wire up output vector
genvar m;
generate
for(m=0; m < `NUM_CLASSES; m=m+1) begin : connect_out_vector
  assign out_vector[ (`NORM_OUT_WIDTH*m) + `NORM_OUT_BITWIDTH : `NORM_OUT_WIDTH * m ] = out_vector_wire[m];
end
endgenerate


endmodule
