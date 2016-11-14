import network_params

save_path = "../Hardware/v/window_selector.v"

file_content = """`include "../network_params.h"\
module window_selector(
  input clock,
  input reset,
  input [`BUFFER_OUT_VECTOR_BITWIDTH:0] buffer_vector,
  input [`X_COORD_BITWIDTH:0] x,
  input [`Y_COORD_BITWIDTH:0] y,
  output reg[`CAMERA_PIXEL_BITWIDTH:0] value_out
);

// wire declarations
wire [`CAMERA_PIXEL_BITWIDTH:0] buffer_wire [`BUFFER_BW:0][`BUFFER_BH:0];

// reg declarations
reg[`CAMERA_PIXEL_BITWIDTH:0] width_selector_wire [`BUFFER_BH:0];

genvar j;
genvar i;
generate 
for (j=0; j<`BUFFER_H; j=j+1) begin : buffer_height_loop
  for(i=0; i<`BUFFER_W; i=i+1) begin : buffer_width_loop
    assign buffer_wire[i][j] = buffer_vector[
    (`CAMERA_PIXEL_WIDTH*i)+(`BUFFER_W*`CAMERA_PIXEL_WIDTH*j) +`CAMERA_PIXEL_BITWIDTH:
    (`CAMERA_PIXEL_WIDTH*i)+(`BUFFER_W*`CAMERA_PIXEL_WIDTH*j)
    ];  
  end // for i
end // for j
endgenerate


// width selector
genvar m;
generate
for (m=0; m<`BUFFER_H; m=m+1) begin : width_selector
  always@(*) begin
    case(x)
"""

for x in range(0,network_params.BUFFER_W):
    case = "      `X_COORD_WIDTH'd" +str(x)+": width_selector_wire[m] = buffer_wire["+str(x)+"][m];\n"
    file_content = file_content + case

file_content = file_content + "      default: width_selector_wire[m] = `CAMERA_PIXEL_WIDTH'd0;"
file_content = file_content + "    endcase\n  end //always\nend //for\nendgenerate\n\n"

file_content = file_content + """\
always@(*) begin
  case(y)
"""


for y in range(0,network_params.BUFFER_H):
    case = "    `Y_COORD_WIDTH'd" +str(y)+": value_out = width_selector_wire["+str(y)+"];\n"
    file_content = file_content + case


file_content = file_content + """\
    default: value_out = `CAMERA_PIXEL_WIDTH'd0;
  endcase
end // always

endmodule
"""
print "writing to " +save_path 

with open(save_path,'w') as f:
    f.write(file_content)

print "done!"

