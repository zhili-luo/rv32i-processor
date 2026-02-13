`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module stage_3_EX
(
	input rst,
	input clk,
	input id_ex_t ex_in,
	input forwardmux::forward_sel_t forward1_sel, forward2_sel,
	input rv32i_word ex_forward, mem_forward,
//	output logic mext_pause,
	output ex_mem_t ex_out
);
// Pass on ctrl word
rv32i_control_word ctrl;
assign ctrl = ex_in.ctrl;
assign ex_out.ctrl = ctrl;

rv32i_word alumux1_out, alumux2_out;
rv32i_word cmpmux_out, addermux_out;
rv32i_word rs1mux_out, rs2mux_out;
logic [63:0] mext_out;

alu ALU(
    .aluop  (ctrl.aluop),
    .a      (alumux1_out),
	.b      (alumux2_out),
    .f      (ex_out.alu_out)
);

cmp CMP(
	.a      (rs1mux_out),
	.b      (cmpmux_out),
	.cmpop  (ctrl.cmpop),
	.br_en    (ex_out.br_en)
);

//mext MEXT(
//	.*,
//	.rs1	(rs1mux_out),
//	.rs2	(rs2mux_out),
//	.rs1_signed (ctrl.rs1_signed),
//	.rs2_signed (ctrl.rs2_signed),
//	.mulop	(ctrl.mulop),
//	.enable (ctrl.m_enable),
//	.out	(ex_out.mext_out),
//	.pause	(mext_pause)
//);

/************************* Muxes **************************/
always_comb begin : EX_MUX

	// forwarding mux
	unique case (forward1_sel)
        forwardmux::rs_out: 		rs1mux_out = ex_in.rs1_out;
		forwardmux::ex_forward: 	rs1mux_out = ex_forward;
		forwardmux::mem_forward: 	rs1mux_out = mem_forward;
        default: `BAD_MUX_SEL;
    endcase
	unique case (forward2_sel)
        forwardmux::rs_out: 		rs2mux_out = ex_in.rs2_out;
		forwardmux::ex_forward: 	rs2mux_out = ex_forward;
		forwardmux::mem_forward: 	rs2mux_out = mem_forward;
        default: `BAD_MUX_SEL;
    endcase

	// ALU and CMP mux
	unique case (ctrl.alumux1_sel)
        alumux::rs1_out: alumux1_out = rs1mux_out;
		alumux::pc_out : alumux1_out = ctrl.pc;
        default: `BAD_MUX_SEL;
    endcase

    unique case (ctrl.alumux2_sel)
		alumux::i_imm: alumux2_out = ctrl.imm.i_imm;
		alumux::u_imm: alumux2_out = ctrl.imm.u_imm;
		alumux::b_imm: alumux2_out = ctrl.imm.b_imm;
		alumux::s_imm: alumux2_out = ctrl.imm.s_imm;
		alumux::j_imm: alumux2_out = ctrl.imm.j_imm;
		alumux::rs2_out: alumux2_out = rs2mux_out;
      default: `BAD_MUX_SEL;
    endcase

	unique case (ctrl.cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = rs2mux_out;
        cmpmux::i_imm: cmpmux_out = ctrl.imm.i_imm;
        default: `BAD_MUX_SEL;
    endcase

	unique case (ctrl.cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = rs2mux_out;
        cmpmux::i_imm: cmpmux_out = ctrl.imm.i_imm;
        default: `BAD_MUX_SEL;
    endcase

	unique case (ctrl.addermux_sel)
        addermux::b_imm: addermux_out = ctrl.imm.b_imm;
        addermux::j_imm: addermux_out = ctrl.imm.j_imm;
        default: `BAD_MUX_SEL;
    endcase

	ex_out.rs2_out = rs2mux_out;
	ex_out.adder_out = ctrl.pc + addermux_out;

end

// synthesis translate_off
assign ex_out.rvfi.rs1_rdata = rs1mux_out;
assign ex_out.rvfi.rs2_rdata = rs2mux_out;

assign ex_out.rvfi.inst = ex_in.rvfi.inst;
assign ex_out.rvfi.rs1_addr = ex_in.rvfi.rs1_addr;
assign ex_out.rvfi.rs2_addr = ex_in.rvfi.rs2_addr;
assign ex_out.rvfi.load_regfile = ex_in.rvfi.load_regfile;
assign ex_out.rvfi.rd_addr = ex_in.rvfi.rd_addr;
assign ex_out.rvfi.rd_wdata = ex_in.rvfi.rd_wdata;
assign ex_out.rvfi.pc_rdata = ex_in.rvfi.pc_rdata;
assign ex_out.rvfi.pc_wdata = ex_in.rvfi.pc_wdata;
assign ex_out.rvfi.mem_addr = ex_in.rvfi.mem_addr;
assign ex_out.rvfi.mem_rmask = ex_in.rvfi.mem_rmask;
assign ex_out.rvfi.mem_wmask = ex_in.rvfi.mem_wmask;
assign ex_out.rvfi.mem_rdata = ex_in.rvfi.mem_rdata;
assign ex_out.rvfi.mem_wdata = ex_in.rvfi.mem_wdata;
// synthesis translate_on

endmodule
