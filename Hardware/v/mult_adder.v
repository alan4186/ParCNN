`include "network_parms.h"
module mult_adder(input     clock, 
		  input     reset, 
		  input [`MULT_ADDER_BITWIDTH:0]  in,
		  input [`MULT_ADDER_BITWIDTH:0]  kernal,
		  output [`NN_BITWIDTH:0] out	
		  );

// wire declarations
wire [`CONV_PRODUCT_WIDTH:0] in_add_vector_wire [`KERNEL_SIZE_SQ];
wire [`CONV_PRODUCT_WIDTH:0] adder_tree_wire [(`KERNEL_SIZE_SQ*2)-1];
   
// connect input vector to wire array
genvar i;
generate
for(i = 0; i < `KERNEL_SIZE_SQ; i=i+1) begin : connect_mul
   mult_adder_mult ma_mult_inst(
    .clock(clock),
    .reset(reset),
    .operand_a([`CONV_MULT_WIDTH*(i+1)-1:i*`CONV_MULT_WIDTH]in),
    .operand_b([`CONV_MULT_WIDTH*(i+1)-1:i*`CONV_MULT_WIDTH]kernal),
    .out(in_add_vector_wire[i])
			     ); 
  end
endgenerate

// map products to adder tree
genvar i;
generate
for(i = 0; i < `NUM_CLASSES; i=i+1) begin : connect_in_vector
    assign in_vector_wire[i] = in_vector[(`NN_WIDTH*i)+`NN_BITWIDTH:`NN_WIDTH*i];
    assign adder_tree_wire[i+`NUM_CLASSES-1] = { `ADDER_TREE_PAD'd0, in_vector[(`NN_WIDTH*i)+`NN_BITWIDTH:`NN_WIDTH*i] };
  end
endgenerate

// connect adder tree
genvar j;
generate
for(j= (`NUM_CLASSES*2)-2 ; j >=1 ; j=j-2) begin : sum_products
  mult_adder_add ma_add_inst(
    .clock(clock),
    .reset(reset),
    .operand_a(),
    .operand_b(),
    .sum()
  );  
//assign adder_tree_wire[(j/2)-1] = adder_tree_wire[j] + adder_tree_wire[j-1];
end // for
endgenerate
   
endmodule // mult_adder

module mult_adder_mult(
  input clock,
  input reset,
  input [`CONV_MULT_WIDTH:0] operand_a,
  input [`CONV_MULT_WIDTH:0] operand_b,
  output reg[`CONV_PRODUCT_WIDTH:0] out 
);
   reg [`CONV_PRODUCT_WIDTH:0]    product;
   always@(posedge clock or negedge reset) begin
      if(reset == 1'b0) 
	product <= `CONV_PRODUCT_WIDTH'd0;
      else  
	product <= operand_a * operand_b;
   end // always
   assign out = product[`CONV_PRODUCT_WIDTH:0];
endmodule

module mult_adder_add(
  input clock,
  input reset,
  input [`CONV_PRODUCT_WIDTH:0] operand_a,
  input [`CONV_PRODUCT_WIDTH:0] operand_b,
  output reg[`CONV_PRODUCT_WIDTH:0] out,
  output reg[`CONV_PRODUCT_WIDTH:0] carry
);
   reg [`CONV_PRODUCT_WIDTH+1:0]    sum;
   always@(posedge clock or negedge reset) begin
      if(reset == 1'b0) 
	sum <= `CONV_MULT_WIDTH'd0;
      else  
	sum <= operand_a + operand_b;
   end // always
   assign out = sum[`CONV_PRODUCT_WIDTH:0];
   assign carry = sum[`CONV_PRODUCT_WIDTH+1];
endmodule
