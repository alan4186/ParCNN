/* Perform element wise multiplication on 2 vectors and sum the result.
*
*  The inputs kernel and in represent vectors of signed 8 bit values.  The
*  input vectors must be the same length. The input vectors are multiplied 
*  element wise and fed into a 32 bit adder tree similar to the 
*  adder_tree_32bit module.  The product of the two inputs is 16 bits wide
*  when it is fed into the adder tree, leaving another 16 bits for overflow.
*  As long as each input vector has less than 2^16 8 bit values, overflow 
*  will be imposible.
*
*  The output latency of this module is log2(MA_TREE_SIZE).  This module is 
*  pipelined and new inputs can be given every clock cycle.
*
*  Parameters:
*    MA_TREE_SIZE: The number of 8 bit values in one input vector.
*
*  Inputs:
*    in: A vector of signed 8 bit values with a length of MA_TREE_SIZE
*    kernel: A vector of signed 8 bit values with a length of MA_TREE_SIZE
*
*  Outputs:
*    out: The sum of the element wise multiplication of in and kernel stored
*      in a signed 32 bit representation.
*
*/


module mult_adder #(
  parameter MA_TREE_SIZE = -1
)
(
  input clock, 
	input reset, 
	input [8*MA_TREE_SIZE-1:0]  in,
	input [8*MA_TREE_SIZE-1:0]  kernel,
	output [31:0] out	
);
`define SIGNED_INT 1

// wire declarations
wire [15:0] in_add_vector_wire [MA_TREE_SIZE-1:0];
wire [31:0] adder_tree_wire [((MA_TREE_SIZE*2)-1)-1:0];

// assign statments
assign out = adder_tree_wire[0];

// connect input vector to multipliers
genvar i;
generate
for(i = 0; i < MA_TREE_SIZE; i=i+1) begin : connect_mul
   mult_8bit_signed ma_mult_inst(
    .clock(clock),
    .dataa(in[8*(i+1)-1:i*8]),
    .datab(kernel[8*(i+1)-1:i*8]),
    .result(in_add_vector_wire[i])
	); 
  end
endgenerate

// map products to adder tree wire
genvar pad_count;
generate
for(i = 0; i < MA_TREE_SIZE; i=i+1) begin : connect_in_vector
  // assign the lsbs here
	assign adder_tree_wire[i+MA_TREE_SIZE-1][15:0] = in_add_vector_wire[i];
`ifdef SIGNED_INT
  // loop over msb and assign sign bit here
  for(pad_count=0; pad_count<16; pad_count=pad_count+1) begin : sign_bit_extention_loop
	  assign adder_tree_wire[i+MA_TREE_SIZE-1][16+pad_count] = in_add_vector_wire[i][15];
  end // pad count 
`else
  assign adder_tree_wire[i+MA_TREE_SIZE-1][31:16] = 16'd0;   
`endif
  end
endgenerate

// connect adder tree
genvar j;
generate
for(j= (MA_TREE_SIZE*2)-2 ; j >=1 ; j=j-2) begin : sum_products
  add_32bit_signed ma_add_inst(
    .clock(clock),
    .dataa(adder_tree_wire[j-1]),
    .datab(adder_tree_wire[j]),
    .result(adder_tree_wire[(j/2)-1])
  );  

end // for
endgenerate
   
endmodule // mult_adder
