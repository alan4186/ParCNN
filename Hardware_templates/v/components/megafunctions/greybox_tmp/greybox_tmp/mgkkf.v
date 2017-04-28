//parallel_add CBX_SINGLE_OUTPUT_FILE="ON" MSW_SUBTRACT="NO" PIPELINE=1 REPRESENTATION="UNSIGNED" RESULT_ALIGNMENT="LSB" SHIFT=0 SIZE=16 WIDTH=16 WIDTHR=20 clock data result
//VERSION_BEGIN 15.0 cbx_mgl 2015:04:15:20:18:26:SJ cbx_stratixii 2015:04:15:19:11:39:SJ cbx_util_mgl 2015:04:15:19:11:39:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus II License Agreement,
//  the Altera MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Altera and sold by Altera or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = parallel_add 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgkkf
	( 
	clock,
	data,
	result) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   [255:0]  data;
	output   [19:0]  result;

	wire  [19:0]   wire_mgl_prim1_result;

	parallel_add   mgl_prim1
	( 
	.clock(clock),
	.data(data),
	.result(wire_mgl_prim1_result));
	defparam
		mgl_prim1.msw_subtract = "NO",
		mgl_prim1.pipeline = 1,
		mgl_prim1.representation = "UNSIGNED",
		mgl_prim1.result_alignment = "LSB",
		mgl_prim1.shift = 0,
		mgl_prim1.size = 16,
		mgl_prim1.width = 16,
		mgl_prim1.widthr = 20;
	assign
		result = wire_mgl_prim1_result;
endmodule //mgkkf
//VALID FILE
