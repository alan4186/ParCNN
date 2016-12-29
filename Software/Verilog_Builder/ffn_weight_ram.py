import network_params

ram_str = ''
ram_init = ''
module_name = 'feature_map_ram_1024w'
file_name = '../Hardware/ffn_weight_rams.h'

for i in range(0,network_params.NUM_CLASSES):
    inst_name = module_name + '_inst' + str(int(i)) 
    index_max = (network_params.FFN_IN_WIDTH * i) + network_params.FFN_IN_BITWIDTH
    index_min = network_params.FFN_IN_WIDTH * i
    ram_init = module_name + ' ' + inst_name  
    ram_init = ram_init +  """ (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),\n"""
    #ram_init = ram_init + "  .q(w_buffer_data_vector["+str(index_max) + ':' + str(index_min)+"])\n);\ndefparam "
    ram_init = ram_init + "  .q(w_buffer_data_vector["+str(i)+"])\n);\ndefparam "
 
    ram_init = ram_init + inst_name + '.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight' + str(int(i)) + '.mif";\n\n'

    ram_str = ram_str + ram_init

with open(file_name, 'w') as f:
    f.write(ram_str)
