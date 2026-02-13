`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module stage_5_WB
( 
	input rst,
	input clk,
	input mem_wb_t wb_in,
	
// synthesis translate_off
	output rvfi_packet rvfi,
// synthesis translate_on

	output logic load_regfile,
	output rv32i_word regfilemux_out,
	output rv32i_reg rd
);
rv32i_control_word ctrl;
assign ctrl = wb_in.ctrl;
assign load_regfile = ctrl.load_regfile;
assign rd = ctrl.rd;
assign regfilemux_out = wb_in.regfilemux_out;

// synthesis translate_off
assign rvfi.rs1_addr = ctrl.rs1;
assign rvfi.rs2_addr = ctrl.rs2;
assign rvfi.load_regfile = ctrl.load_regfile;
assign rvfi.rd_addr = rd;
assign rvfi.rd_wdata = regfilemux_out;

assign rvfi.inst = wb_in.rvfi.inst;
assign rvfi.rs1_rdata = wb_in.rvfi.rs1_rdata;
assign rvfi.rs2_rdata = wb_in.rvfi.rs2_rdata;
assign rvfi.pc_rdata = wb_in.rvfi.pc_rdata;
assign rvfi.pc_wdata = wb_in.rvfi.pc_wdata;
assign rvfi.mem_addr = wb_in.rvfi.mem_addr;
assign rvfi.mem_rmask = wb_in.rvfi.mem_rmask;
assign rvfi.mem_wmask = wb_in.rvfi.mem_wmask;
assign rvfi.mem_rdata = wb_in.rvfi.mem_rdata;
assign rvfi.mem_wdata = wb_in.rvfi.mem_wdata;
// synthesis translate_on

endmodule
