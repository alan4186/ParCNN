module mult_adder #(
  parameter TREE_SIZE = -1
)
(
  input clock, 
	input reset, 
	input [8*TREE_SIZE-1:0]  in,
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
  add_32bit ma_add_inst(
    .clock(clock),
    .dataa(adder_tree_wire[i-1]),
    .datab(adder_tree_wire[i]),
    .result(adder_tree_wire[(i/2)-1])
  );  
end // for

endgenerate
   
endmodule // mult_adder
