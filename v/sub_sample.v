`include <network_parameters.h>
`define VECTOR_WIDTH `NEIGHBORHOOD_SIZE*`NN_WIDTH
`define VECTOR_BITWIDTH VECTOR_WIDTH - 1
`define NUM_LAYERS CLOG(`NEIGHBORHOOD_SIZE)
module sub_sample( // Mean pooling
  input clock,
  input reset,
  input [VECTOR_BITWIDTH:0] nh_vector, // ` indicates a difined macro
  output [`NN_BITWIDTH:0] out
);

// wires
wire [`NN_BITWIDTH+`NUM_LAYERS:0] adder_tree_wire [`NUM_LAYERS+1][`NEIGHBORHOOD_SIZE];

// regs



genvar i
genvar j
generate
for(i=0; i < `NUM_LAYERS; i=i+1) begin
  for(j=0; j < `NEIGHBORHOOD_SIZE - i; j=j+2) begin
    add add_inst ( 
      .add_a(adder_tree_wire[i][j]),
      .add_b(adder_tree_wire[i][j+1]),
      .out(adder_tree_wire[i+1][j/2])
    );
  end 
end
endgenerate

endmodule


module add (
  input [`NN_BITWIDTH + `NUMLAYERS:0] add_a,
  input [`NN_BITWIDTH + `NUMLAYERS:0] add_b,
  output [`NN_BITWIDTH + `NUMLAYERS:0] out
);

assign out = add_a + add_b;

endmodule
