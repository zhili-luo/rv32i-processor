import rv32i_types::*;

module stage_2_ID
( 
	input rst,
	input clk,
	input if_id_t id_in,
	output id_ex_t id_out,
	
	input rv32i_reg rd,
	input load_regfile,
	input rv32i_word regfilemux_out
);

rv32i_control_word ctrl;
assign id_out.ctrl = ctrl;


control_rom control(
	.opcode	 (id_in.opcode),
	.funct3	 (id_in.funct3),
	.funct7	 (id_in.funct7),
	.pc		 (id_in.pc_out),
	.rd		 (id_in.rd),
	.rs1	 (id_in.rs1),
	.rs2	 (id_in.rs2),
	.imm	 (id_in.imm),
	.*
);

regfile regfile(
    .*,
    .load   (load_regfile),
    .in     (regfilemux_out),
    .src_a  (id_in.rs1),
	.src_b  (id_in.rs2),
	.dest   (rd),
    .reg_a  (id_out.rs1_out),
	.reg_b  (id_out.rs2_out)
);

// synthesis translate_off
assign id_out.rvfi = id_in.rvfi;
// synthesis translate_on

endmodule
