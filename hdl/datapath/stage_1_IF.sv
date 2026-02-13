`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module stage_1_IF
( 
	input rst,
	input clk,
	
	input ex_mem_t ex_out,
	
	input stall, pause,
	input inst_resp,
	input load_pc,
	input br_en,
	input rv32i_word adder_out,
	input rv32i_word alu_out,
	input pcmux::pcmux_sel_t pcmux_sel,
	input rv32i_word inst_rdata,
	output if_id_t if_out,
	output rv32i_word pcmux_out,
	output rv32i_word inst_addr
);

assign inst_addr = if_out.pc_out;

pc_register PC(
    .clk    (clk),
    .rst    (rst),
    .load   (load_pc),
    .in     (pcmux_out),
    .out    (if_out.pc_out)
);

ir IR(
    .clk    (clk),
    .rst    (rst),
    .load   (1'b1),
    .data     (inst_rdata),
    .opcode (if_out.opcode),
    .funct3 (if_out.funct3),
    .funct7 (if_out.funct7),
    .rs1    (if_out.rs1),
    .rs2    (if_out.rs2),
    .rd     (if_out.rd),
    .i_imm  (if_out.imm.i_imm),
    .s_imm  (if_out.imm.s_imm),
    .b_imm  (if_out.imm.b_imm),
    .u_imm  (if_out.imm.u_imm),
    .j_imm  (if_out.imm.j_imm)
);

rv32i_word pcplus4;
rv32i_word br_en_out;
assign pcplus4 = if_out.pc_out + 4;
assign br_en_out = br_en ? adder_out : pcplus4;

always_comb begin : IF_MUX
	unique case (pcmux_sel)
		pcmux::br_en: pcmux_out = br_en_out;
        pcmux::pc_plus4: pcmux_out = pcplus4;
        pcmux::adder_out: pcmux_out = adder_out;
        pcmux::alu_mod2: pcmux_out = (alu_out & 32'hFFFFFFFE);
        default: `BAD_MUX_SEL;
    endcase
end


// synthesis translate_off
assign if_out.rvfi.inst = inst_rdata;
assign if_out.rvfi.pc_rdata = if_out.pc_out;
// synthesis translate_on

endmodule
