module mult_adder(
      input     clock, 
		  input     reset, 
		  input [8*`MA_TREE_SIZE-1:0]  in,
		  input [8*`MA_TREE_SIZE-1:0]  kernal,
		  output [31:0] out	
		  );

// wire declarations
wire [15:0] in_add_vector_wire [`MA_TREE_SIZE-1:0];
wire [31:0] adder_tree_wire [((`MA_TREE_SIZE*2)-1)-1:0];
wire [(`MA_TREE_SIZE*2)-1-1:0]carry_wire ;  

// assign statments
assign out = adder_tree_wire[0];
assign carry_wire [(`MA_TREE_SIZE*2)-1-1:`MA_TREE_SIZE-1] = `MA_TREE_SIZE'd0;

// connect input vector to multipliers
genvar i;
generate
for(i = 0; i < `MA_TREE_SIZE; i=i+1) begin : connect_mul
   mult_8bit ma_mult_inst(
    .clock(clock),
    .reset(reset),
    .operand_a(in[8*(i+1)-1:i*8]),
    .operand_b(kernal[8*(i+1)-1:i*8]),
    .out(in_add_vector_wire[i])
	); 
  end
endgenerate

// map products to adder tree wire
genvar pad_count;
generate
//for(i = 0; i < `KERNEL_SIZE_SQ; i=i+1) begin : connect_in_vector
for(i = 0; i < `MA_TREE_SIZE; i=i+1) begin : connect_in_vector
  // assign the lsbs here
	assign adder_tree_wire[i+`MA_TREE_SIZE-1][15:0] = in_add_vector_wire[i];
`ifdef SIGNED_INT
  // loop over msb and assign sign bit here
  for(pad_count=0; pad_count<`MULT_PAD_WIDTH; pad_count=pad_count+1) begin : sign_bit_extention_loop
	  assign adder_tree_wire[i+`MA_TREE_SIZE-1][16+pad_count] = in_add_vector_wire[i][15];
  end // pad count 
`else
  assign adder_tree_wire[i+`MA_TREE_SIZE-1][31:31-`MULT_PAD_WIDTH] = `MULT_PAD_WIDTH'd0;   
`endif
  end
endgenerate

// connect adder tree
genvar j;
generate
for(j= (`MA_TREE_SIZE*2)-2 ; j >=1 ; j=j-2) begin : sum_products
  add_32bit ma_add_inst(
    .clock(clock),
    .operand_a(adder_tree_wire[j-1]),
    .operand_b(adder_tree_wire[j]),
    .out(adder_tree_wire[(j/2)-1]),
  );  

end // for
endgenerate
   
endmodule // mult_adder
