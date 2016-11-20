feature_map_ram_1024w feature_map_ram_1024w_inst0 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[0])
);
defparam feature_map_ram_1024w_inst0.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight0.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst1 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[1])
);
defparam feature_map_ram_1024w_inst1.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight1.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst2 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[2])
);
defparam feature_map_ram_1024w_inst2.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight2.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst3 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[3])
);
defparam feature_map_ram_1024w_inst3.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight3.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst4 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[4])
);
defparam feature_map_ram_1024w_inst4.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight4.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst5 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[5])
);
defparam feature_map_ram_1024w_inst5.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight5.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst6 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[6])
);
defparam feature_map_ram_1024w_inst6.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight6.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst7 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[7])
);
defparam feature_map_ram_1024w_inst7.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight7.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst8 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[8])
);
defparam feature_map_ram_1024w_inst8.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight8.mif";

feature_map_ram_1024w feature_map_ram_1024w_inst9 (
    .clock(clock),
    .data(`FFN_IN_WIDTH'd0),
  .rdaddress({fm_buffer_select, fm_rd_addr}),
  .wraddress(`FM_ADDR_WIDTH'd0),
  .wren(1'b0),
  .q(w_buffer_data_vector[9])
);
defparam feature_map_ram_1024w_inst9.init_file = "M:/ECE448/Hardware-CNN/Software/ffn_weight_mifs/ffn_weight9.mif";

