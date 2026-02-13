import rv32i_types::*;

module control_rom
(
	input rv32i_opcode opcode,
	input rv32i_word pc,
	input rv32i_reg rd, rs1, rs2,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	input imm_t imm,
	output rv32i_control_word ctrl
);

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;
//muldiv_funct3_t muldiv_funct3;
alu_ops aluop_funct3;

assign arith_funct3 = arith_funct3_t'(funct3);
//assign muldiv_funct3 = muldiv_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign aluop_funct3 = alu_ops'(funct3);
/**
 *  Functions
**/
function void loadPC(pcmux::pcmux_sel_t sel);
    ctrl.pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
	ctrl.load_regfile = 1'b1;
	ctrl.regfilemux_sel = sel;
endfunction

function void loadMAR();
	ctrl.load_mar = 1'b1;
endfunction

function void loadMDR();
	ctrl.load_mdr = 1'b1;
endfunction

function void setALU(alumux::alumux1_sel_t sel1,
                               alumux::alumux2_sel_t sel2,
                               logic setop = 1'b0, alu_ops op = alu_add);
	ctrl.alumux1_sel = sel1;
	ctrl.alumux2_sel = sel2;
    if (setop)
        ctrl.aluop = op; // else default value
endfunction

function void setAdder(addermux::addermux_sel_t sel);
	ctrl.addermux_sel = sel;
endfunction

function void setMEXT(m_ops mulop, logic rs1_signed, logic rs2_signed);
	ctrl.m_enable = 1'b1;
	ctrl.mulop = mulop;
	ctrl.rs1_signed = rs1_signed;
	ctrl.rs2_signed = rs2_signed;
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
	ctrl.cmpmux_sel = sel;
	ctrl.cmpop = op;
endfunction

/********************************* Set Control Signals ******************************/
always_comb
begin
	/* Set Defaults */
	ctrl.opcode = opcode;
	ctrl.pc = pc;
	ctrl.rd = rd;
	ctrl.rs1 = rs1;
	ctrl.rs2 = rs2;
	ctrl.imm = imm;
	ctrl.cmpop = branch_funct3;
    ctrl.aluop = aluop_funct3;
	ctrl.mulop = m_rem;
	ctrl.rs1_signed = 1'b0;
	ctrl.rs2_signed = 1'b0;
	ctrl.store_funct3 = store_funct3;
	ctrl.load_funct3 = load_funct3;
    ctrl.inst_read		= 1'b1;
    ctrl.load_ir		= 1'b0;
    ctrl.load_regfile	= 1'b0;
    ctrl.load_mar		= 1'b0;
    ctrl.load_mdr		= 1'b0;
    ctrl.m_enable	    = 1'b0;
    ctrl.data_read 		= 1'b0;
    ctrl.data_write 	= 1'b0;
    ctrl.regfilemux_sel	= regfilemux::alu_out;
    ctrl.pcmux_sel      = pcmux::pc_plus4;
	ctrl.alumux1_sel	= alumux::rs1_out;
    ctrl.alumux2_sel	= alumux::i_imm;
	ctrl.addermux_sel	= addermux::b_imm;
    ctrl.cmpmux_sel		= cmpmux::rs2_out;

	/* Assign control signals */
	case (opcode)
		op_lui: begin
			loadRegfile(regfilemux::u_imm);
            loadPC(pcmux::pc_plus4);
		end

		op_auipc: begin
			loadRegfile(regfilemux::alu_out);
            loadPC(pcmux::pc_plus4);
            setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
		end

		op_load: begin
			ctrl.data_read = 1;
			setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
			loadMDR();
            loadPC(pcmux::pc_plus4);
			unique case (load_funct3)
				lb:	loadRegfile(regfilemux::lb);
				lh: loadRegfile(regfilemux::lh);
				lw: loadRegfile(regfilemux::lw);
				lbu: loadRegfile(regfilemux::lbu);
				lhu: loadRegfile(regfilemux::lhu);
				default: ctrl = 0;
            endcase
		end

		op_store: begin
			ctrl.data_write = 1;
			ctrl.rd = 0; // disable data forwarding
			setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
			loadPC(pcmux::pc_plus4);
		end

		op_imm: begin
			loadPC(pcmux::pc_plus4);
            unique case(arith_funct3)
                slt: begin
                    setCMP(cmpmux::i_imm, blt);
                    loadRegfile(regfilemux::br_en);
                end
                sltu: begin
                    setCMP(cmpmux::i_imm, bltu);
                    loadRegfile(regfilemux::br_en);
                end
                sr: begin
                    loadRegfile(regfilemux::alu_out);
					if (funct7[5]) setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_sra);
					else setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_srl);
                end
				default: begin
                    loadRegfile(regfilemux::alu_out);
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_ops'(funct3));
               end
            endcase
		end

		op_br: begin
			case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu: begin
					ctrl.rd = 0; // disable data forwarding
					loadPC(pcmux::br_en);
					setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
					setAdder(addermux::b_imm);
				end
				default: ctrl = 0;
			endcase
		end

		op_jal: begin
            loadRegfile(regfilemux::pc_plus4);
            loadPC(pcmux::adder_out);
            setAdder(addermux::j_imm);
        end

		op_jalr: begin
            loadRegfile(regfilemux::pc_plus4);
            loadPC(pcmux::alu_mod2);
            setAdder(addermux::j_imm);
        end

		op_reg: begin
			loadPC(pcmux::pc_plus4);
			// rv32m
//			if (funct7[0]) begin
//				case (muldiv_funct3)
//					mul: begin
//						setMEXT(m_mul, 1'b1, 1'b1);
//						loadRegfile(regfilemux::ml);
//					end
//
//					mulh: begin
//						setMEXT(m_mul, 1'b1, 1'b1);
//						loadRegfile(regfilemux::mu);
//					end
//
//					mulhsu: begin
//						setMEXT(m_mul, 1'b1, 1'b0);
//						loadRegfile(regfilemux::mu);
//					end
//
//					mulhu: begin
//						setMEXT(m_mul, 1'b0, 1'b0);
//						loadRegfile(regfilemux::mu);
//					end
//
//					div: begin
//						setMEXT(m_div, 1'b1, 1'b1);
//						loadRegfile(regfilemux::ml);
//					end
//
//					divu: begin
//						setMEXT(m_div, 1'b0, 1'b0);
//						loadRegfile(regfilemux::ml);
//					end
//					rem: begin
//						setMEXT(m_rem, 1'b1, 1'b1);
//						loadRegfile(regfilemux::ml);
//					end
//					remu: begin
//						setMEXT(m_rem, 1'b0, 1'b0);
//						loadRegfile(regfilemux::ml);
//					end
//					default:
//						ctrl = 0;
//				endcase
//			end
//
//			// rv32i
//			else begin
				case (arith_funct3)
					slt: begin
						setCMP(cmpmux::rs2_out, blt);
						loadRegfile(regfilemux::br_en);
					end
					sltu: begin
						setCMP(cmpmux::rs2_out, bltu);
						loadRegfile(regfilemux::br_en);
					end
					sr: begin
						loadRegfile(regfilemux::alu_out);
						if (funct7[5]) setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sra);
						else setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_srl);
					end
					add: begin
						loadRegfile(regfilemux::alu_out);
						if (funct7[5]) setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sub);
						else setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_add);
					end
					default: begin
						loadRegfile(regfilemux::alu_out);
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_ops'(funct3));
					end
				endcase
//			end
		end

		default: begin
			ctrl = 0; // Undefined opcode
		end
	endcase
end

endmodule
