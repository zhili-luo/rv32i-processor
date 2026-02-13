
import rv32i_types::*;

module datapath
(

    input clk,
    input rst,

	/* I Cache Ports */
    input inst_resp,
    input [31:0] inst_rdata,
	output logic inst_read,
	output logic [31:0] inst_addr,
	/* D Cache Ports */
	input data_resp,
    input [31:0] data_rdata,
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe,
    output logic [31:0] data_addr,
    output logic [31:0] data_wdata
);

// synthesis translate_off
rvfi_packet rvfi;
// synthesis translate_on

/******************* Signals Needed for RVFI Monitor *************************/
rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
imm_t imm;
logic br_en;
rv32i_control_word ctrl;
rv32i_word pcmux_out;
rv32i_word mdrreg_out;
rv32i_word marmux_out;
rv32i_word pc_out;
rv32i_word rs1_out, rs2_out;
logic[4:0] rs1, rs2, rd;
rv32i_word alu_out, alumux1_out, alumux2_out;
rv32i_word regfilemux_out;
rv32i_word i_imm, u_imm, b_imm, s_imm, j_imm;
rv32i_word cmpmux_out;

rv32i_word data_addr_copy;

/****************************** Counters **********************************/
int branch_total, branch_mispredict, stall_count;

/******************************* Stages ***********************************/
if_id_t if_out;
if_id_t id_in;
id_ex_t id_out;
id_ex_t ex_in;
ex_mem_t ex_out;
ex_mem_t mem_in;
mem_wb_t mem_out;
mem_wb_t wb_in;

logic load_pc;
pcmux::pcmux_sel_t pcmux_sel;
logic load_regfile;
regfilemux::regfilemux_sel_t regfilemux_sel;
forwardmux::forward_sel_t forward1_sel, forward2_sel;
forwardmux::memforward_sel_t memforward_sel;
rv32i_word adder_out;
//logic mem_pause, mext_pause;
logic stall, pause, tb, br;
logic halt;
//logic flush;
logic mispredict;
//assign halt = load_pc & (mem_in.ctrl.pc == pcmux_out);
//assign inst_read = ~halt;
assign inst_read = 1'b1;

// stall when reg not ready
assign stall = ex_in.ctrl.data_read && (id_in.opcode != op_store) && ex_in.ctrl.rd && ((ex_in.ctrl.rd == id_in.rs1) || (ex_in.ctrl.rd == id_in.rs2));

// pause when mem_resp isn't high
//assign mem_pause = ((inst_read & ~inst_resp) || ((data_read || data_write) & ~data_resp));
assign pause = ((inst_read & ~inst_resp) || ((data_read || data_write) & ~data_resp));

// flush for taken branch
//assign br = ((mem_in.ctrl.opcode == op_br) && mem_in.br_en);
//assign flush = (mem_in.ctrl.opcode == op_jal) || (mem_in.ctrl.opcode == op_jalr);

// compare branch when mem is op_br

//assign pause = mem_pause || mext_pause;
assign tb = (mem_in.ctrl.opcode == op_br) ||
(mem_in.ctrl.opcode == op_jal) || (mem_in.ctrl.opcode == op_jalr);

assign mispredict = ((mem_in.ctrl.opcode == op_br) && mem_in.br_en) ||
(mem_in.ctrl.opcode == op_jal) || (mem_in.ctrl.opcode == op_jalr);

assign load_pc = ~(stall || pause);

// forwarding
always_comb begin : forwarding
	forward1_sel = forwardmux::rs_out;
	forward2_sel = forwardmux::rs_out;
	memforward_sel = forwardmux::mem_wdata;

	//rs1
	if (mem_in.ctrl.rd && (mem_in.ctrl.rd == ex_in.ctrl.rs1))
		forward1_sel = forwardmux::ex_forward;
	else if (wb_in.ctrl.rd && (wb_in.ctrl.rd == ex_in.ctrl.rs1))
		forward1_sel = forwardmux::mem_forward;
	//rs2
	if (mem_in.ctrl.rd && (mem_in.ctrl.rd == ex_in.ctrl.rs2))
		forward2_sel = forwardmux::ex_forward;
	else if (wb_in.ctrl.rd && (wb_in.ctrl.rd == ex_in.ctrl.rs2))
		forward2_sel = forwardmux::mem_forward;
	if ((wb_in.ctrl.rd) && (wb_in.ctrl.rd == mem_in.ctrl.rs2)
		&& (wb_in.ctrl.opcode == op_load) && (mem_in.ctrl.opcode == op_store))
		memforward_sel = forwardmux::mem2_forward;

end

rv32i_word ex_forward, mem_forward;
assign ex_forward = mem_out.regfilemux_out;
assign mem_forward = regfilemux_out;

stage_1_IF stage1(.*);
stage_2_ID stage2(.*);
stage_3_EX stage3(.*);
stage_4_MEM stage4(.*);
stage_5_WB stage5(.*);

// shift stages
always_ff @(posedge clk) begin
	if (rst) begin
		id_in <= 0;
		ex_in <= 0;
		mem_in <= 0;
		wb_in <= 0;
		branch_total <= 0;
		branch_mispredict <= 0;
		stall_count <= 0;
	end
	else begin
		if (tb)
			branch_total <= branch_total + 1;
		if (pause) begin
			id_in <= id_in;
			ex_in <= ex_in;
			mem_in <= mem_in;
			wb_in <= wb_in;
		end
		else if (mispredict) begin
			id_in <= 0;
			ex_in <= 0;
			mem_in <= 0;
			wb_in <= mem_out;
			branch_mispredict <= branch_mispredict + 1;
		end
		else if (stall) begin
			id_in <= id_in;
			ex_in <= 0;
			mem_in <= ex_out;
			wb_in <= mem_out;
			stall_count <= stall_count + 1;
		end
		else begin
			id_in <= if_out;
			ex_in <= id_out;
			mem_in <= ex_out;
			wb_in <= mem_out;
		end
	end
end

endmodule : datapath
