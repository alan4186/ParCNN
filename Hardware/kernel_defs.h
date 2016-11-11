wire [(9*9)-1:0] k[`NUM_KERNELS-1:0];
genvar k_count;
generate
for (k_count=0; k_count<`NUM_KERNELS; k_count=k_count+1) begin :kloopassign
assign k[k_count] = {9'b001000000,9'b001000000,9'b001000000,9'b001000000,9'b001000000,9'b001000000,9'b001000000,9'b001000000,9'b001000000};
end // for
endgenerate
