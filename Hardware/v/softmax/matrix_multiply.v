`include "network_params.h"
module matrix_multiply( // a matrix multiply implementaion of a single layer feed forward network
  input clock,
  input reset,

  input [(`FFN_WIDTH*`NUM_INPUT_N)-1:0] input_neurons,
  input [(`FFN_WIDTH*NUM_INPUT_N*NUM_OUTPUT_N)-1:0] weight_matrix,
  output [(`FFN_WIDTH*2*`NUM_OUTPUT_N)-1:0] output_neurons

);

// wire declarations
wire [`FFN_BITWIDTH:0] input_n_wire [`NUM_INPUT_N];
wire [`FFN_OUT_BITWIDTH:0] output_n_wire [`NUM_OUTPUT_N];
wire [`FFN_OUT_BITWIDTH:0] product_wire [`NUM_INPUT_N][`NUM_OUTPUT_N]; // Connects to the output of the multiplieres
wire [`FFN_OUT_BITWIDTH:0] sum_wire [`SUM_WIRE_LEN][`NUM_OUTPUT_N]; 

// reg declarations

genvar i;
genvar j;
generate 
  for(i=0; i < `NUM_INPUT_N; i=i+1) begin
    for(j=0; j < `NUM_OUTPUT_N; j=j+1) begin
      multiply2 multiply2_inst(
        .clock(clock),
        .reset(reset),
        .operand_a(input_n_wire[i]),
        .operand_b(wieght_matrix[i][j]),
        .product(product_wire[i][j])
      );
    end // for j (output dim)
  end // for i (input dim)
endgenerate

genvar x;
generate
  for(x=0; x < `NUM_INPUT_N; x=x+1) begin
    assign input_n_wire[x] = input_neurons[(`FFN_WIDTH*x)+`FFN_BITWIDTH:`FFN_WIDTH*x];
  end
endgenerate

genvar y;
generate
  for(y=0; y < `NUM_INPUT_N; y=y+1) begin
    // connect the top of the adder tree to the output 
    assign sum_wire[1][y] = output_neurons[(`FFN_WIDTH*y)+`FFN_BITWIDTH:`FFN_WIDTH*y];
  end
endgenerate

genvar z;
genvar w;
generate
  for(z=`SUM_WIRE_LEN-2 ; z <= 2; z=z-2) begin
    for(w=0; w < `NUM_OUTPUT_N; w=w+1) begin
      sum2 sum2_inst(
        .clock(clock),
        .reset(reset),
        .opperand_a(sum_wire[z][w]),
        .opperand_b(sum_wire[z+1][w]),
        .sum(sum_wire[z/2][w])
      );
    end
  end
endgenerate
endmodule

module multiply2( // Multiply 2 fixed point numbers
  input clock,
  input reset,

  input [`FFN_BITWIDTH:0] operand_a,
  input [`FFN_BITWIDTH:0] operand_b,

  output [`FFN_OUT_BITWIDTH:0] product
);

always@(posedge clock or negedge reset) begin
  if(reset == 1;b0) begin
    product <= `FFN_OUT_WIDTH'd0;
  end else begin
    product <= {`CLOG(`NUM_INPUT_N)'d0, operand_a * operand_b} ;
  end // reset
end // always

endmodule


module add2(
  input clock,
  input reset,

  input [`FFN_OUT_BITWIDTH:0] operand_a,
  input [`FFN_OUT_BITWIDTH:0] operand_b,
  output [`FFN_OUT_BITWIDTH:0] sum
);

always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) 
    sum <= `FFN_OUT_WIDTH'd0;
  else 
    sum <= operand_a + operand_b;
end // always

endmodule
