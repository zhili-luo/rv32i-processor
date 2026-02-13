`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module stage_4_MEM
(
	input rst,
	input clk,
	input ex_mem_t mem_in,
	output mem_wb_t mem_out,
	input rv32i_word data_rdata,
	input forwardmux::memforward_sel_t memforward_sel,
	input rv32i_word mem_forward,
	output br_en,
	output pcmux::pcmux_sel_t pcmux_sel,
	output rv32i_word data_addr,
	output rv32i_word data_wdata,
	output rv32i_word adder_out,
	output rv32i_word alu_out,
	output logic data_read, data_write,
	output logic [3:0] data_mbe
);
// Pass on ctrl word
rv32i_control_word ctrl;
assign ctrl = mem_in.ctrl;
assign mem_out.ctrl = ctrl;
rv32i_word mem_wdata_shift;
logic [3:0] rmask, wmask;
rv32i_word pcmux_out;

assign alu_out = mem_in.alu_out;
assign br_en = mem_in.br_en;
assign pcmux_sel = ctrl.pcmux_sel;
assign adder_out = mem_in.adder_out;
assign data_read = ctrl.data_read;
assign data_write = ctrl.data_write;
assign data_addr = alu_out & 32'hFFFFFFFC;
assign mem_wdata_shift = mem_in.rs2_out << {alu_out[1:0], 3'b0};
//assign data_wdata = mem_wdata_shift;
rv32i_word pc_wdata; // rvfi signal
rv32i_word mdr_shift;
assign mdr_shift = data_rdata >> {alu_out[1:0], 3'b0};

always_comb begin
	data_mbe = 4'b1111;
	rmask = '0;
	wmask = '0;
	if (data_read) begin
		case (ctrl.load_funct3)
			lb, lbu : rmask = 4'b0001 << (alu_out[1:0]);
			lh, lhu : rmask = 4'b0011 << (alu_out[1:0]);
			lw : rmask = 4'b1111;
		endcase
		data_mbe = rmask;
	end

	if (data_write) begin
		case (ctrl.store_funct3)
			sb : wmask = 4'b0001 << (alu_out[1:0]);
			sh : wmask = 4'b0011 << (alu_out[1:0]);
			sw : wmask = 4'b1111;
		endcase
		data_mbe = wmask;
	end

	unique case (memforward_sel)
		forwardmux::mem_wdata: data_wdata = mem_wdata_shift;
		forwardmux::mem2_forward: data_wdata = mem_forward;
      default: `BAD_MUX_SEL;
    endcase

    unique case (ctrl.regfilemux_sel)
        regfilemux::alu_out: mem_out.regfilemux_out = alu_out;
        regfilemux::br_en: mem_out.regfilemux_out = {31'b0, br_en};
        regfilemux::u_imm: mem_out.regfilemux_out = ctrl.imm.u_imm;
		regfilemux::pc_plus4: mem_out.regfilemux_out = ctrl.pc + 4;
		regfilemux::lw:  mem_out.regfilemux_out = data_rdata;
		regfilemux::lb:  mem_out.regfilemux_out = 32'(signed'(mdr_shift[7:0]));
        regfilemux::lbu: mem_out.regfilemux_out = {24'b0, mdr_shift[7:0]};
        regfilemux::lh:  mem_out.regfilemux_out = 32'(signed'(mdr_shift[15:0]));
        regfilemux::lhu: mem_out.regfilemux_out = {16'b0, mdr_shift[15:0]};
//		regfilemux::ml:  mem_out.regfilemux_out = mem_in.mext_out[31:0];
//		regfilemux::mu:  mem_out.regfilemux_out = mem_in.mext_out[63:32];
		default: `BAD_MUX_SEL;
	endcase

	// rvfi signal
	unique case (pcmux_sel)
		pcmux::br_en: pcmux_out = br_en ? adder_out : (ctrl.pc + 4);
        pcmux::pc_plus4: pcmux_out = (ctrl.pc + 4);
        pcmux::adder_out: pcmux_out = adder_out;
        pcmux::alu_mod2: pcmux_out = (alu_out & 32'hFFFFFFFE);
        default: `BAD_MUX_SEL;
    endcase
end

// synthesis translate_off
assign mem_out.rvfi.pc_wdata = pcmux_out;
assign mem_out.rvfi.mem_addr = data_addr;
assign mem_out.rvfi.mem_rdata = data_rdata;
assign mem_out.rvfi.mem_wdata = data_wdata;
assign mem_out.rvfi.mem_rmask = rmask;
assign mem_out.rvfi.mem_wmask = wmask;

assign mem_out.rvfi.inst = mem_in.rvfi.inst;
assign mem_out.rvfi.rs1_addr = mem_in.rvfi.rs1_addr;
assign mem_out.rvfi.rs2_addr = mem_in.rvfi.rs2_addr;
assign mem_out.rvfi.rs1_rdata = mem_in.rvfi.rs1_rdata;
assign mem_out.rvfi.rs2_rdata = mem_in.rvfi.rs2_rdata;
assign mem_out.rvfi.load_regfile = mem_in.rvfi.load_regfile;
assign mem_out.rvfi.rd_addr = mem_in.rvfi.rd_addr;
assign mem_out.rvfi.rd_wdata = mem_in.rvfi.rd_wdata;
assign mem_out.rvfi.pc_rdata = mem_in.rvfi.pc_rdata;
// synthesis translate_on

endmodule
