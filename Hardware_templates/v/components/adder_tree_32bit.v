/* Sum a vector 32 bit of signed numbers
*
*  A vector of signed 32 bit integers is summed.  The values are assumed to
*  be small enough that overflow will not occur.  In most cases this module
*  will be used for values much less than 32 bits, in these cases overflow 
*  will still be impossible.
*
*  Each value in the vector is concatenated and input in parallel to a 
*  single port.  The values are summed in a tree.  The value of TREE_SIZE
*  must be a pwer of 2 to create a symetric tree.  If the input vector is 
*  not a power of 2, round up and input zeros to the extra values.  
*  Extra values will be removed during optimization during synthesis.
*
*  The output latency of the module is log2(TREE_SIZE).  This module is
*  pipelined and new inputs can be given every clock cycle.
*
*  Parameters:
*    TREE_SIZE: The number of 32 bit values in the input vector
*
*  Inputs:
*    in: A vector of 32 bit signed values of length TREE_SIZE
*
*  Outputs:
*    out: The sum of the input vector in a signed 32 bit representation
*
*/

module adder_tree_32bit #(
  parameter TREE_SIZE = -1
)
(
  input clock, 
	input reset, 
	input [32*TREE_SIZE-1:0]  in,
	output [31:0] out	
);


// wire declarations
wire [31:0] adder_tree_wire [((TREE_SIZE*2)-1)-1:0];

// assign statments
assign out = adder_tree_wire[0];

genvar i;
generate
// map input to wire array
for(i = 0; i < TREE_SIZE; i=i+1) begin : connect_in_vector
	assign adder_tree_wire[i+TREE_SIZE-1] = in[i*32+31:i*32];
end // for

// connect adder tree
for(i= (TREE_SIZE*2)-2 ; i >=1 ; i=i-2) begin : sum_products
  add_32bit_signed add_inst(
    .clock(clock),
    .dataa(adder_tree_wire[i-1]),
    .datab(adder_tree_wire[i]),
    .result(adder_tree_wire[(i/2)-1])
  );  
end // for

endgenerate
   
endmodule // mult_adder
