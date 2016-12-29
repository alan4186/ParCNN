import network_params
import project_settings as ps

data = """`include "../network_params.h"
module read_port_mux( // combinds several sram read ports into one address space
  input clock,
  input reset,
 
  input [`RAM_SELECT_BITWIDTH:0] ram_select,
  input [(`FFN_IN_WIDTH*`NUM_KERNELS)-1:0] buffer_data_vector,

  output reg [`FFN_IN_BITWIDTH:0] data_out
);

always@(*) begin
  if (reset == 1'b0) begin 
    data_out = `FFN_IN_WIDTH'd0;
  end else begin
    case(ram_select)
"""

case = '      '+str(network_params.NUM_KERNELS) + "'d"
for x in range(0,network_params.NUM_KERNELS):
    data = data + case + str(x) +": data_out = buffer_data_vector[" +str((x*network_params.FFN_IN_WIDTH)+network_params.FFN_IN_BITWIDTH)+":"+str(x*network_params.FFN_IN_WIDTH) + "];\n"

data = data + "    endcase\n  end //reset\nend //always\nendmodule"

    
print "writing to " + ps.read_port_mux
with open(ps.read_port_mux,'w') as f:
    f.write(data)

print "done!"

