module normalize(
  input clock,
  input reset,
  input [`NN_WIDTH*`NUM_CLASSES-1:0] in_vector,
  output [`NN_WIDTH*`NUM_CLASSES-1:0] out_vector
);

// wire declarations
wire [`NN_BITWIDTH:0] vector_wire [`NUM_CLASSES];

// reg declarations


// connect input vector to wire array
genvar i;
generate
for(i = 0; i < `NUM_CLASSES; i=i+1) begin
    assign vector_wire[i] = in_vector[`NN_WIDTH*i:(`NN_WIDTH*i)-1];
  end
endgenerate

// normalize wire array
genvar j;
generate
for(j=0; j < `CLOG(`
