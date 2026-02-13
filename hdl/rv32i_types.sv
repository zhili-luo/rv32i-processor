package rv32i_types;
// Mux types are in their own packages to prevent identiier collisions
// e.g. pcmux::pc_plus4 and regfilemux::pc_plus4 are seperate identifiers
// for seperate enumerated types
import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import addermux::*;
import regfilemux::*;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

// synthesis translate_off
typedef struct packed {
    logic [31:0] inst;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [31:0] rs1_rdata;
    logic [31:0] rs2_rdata;
    logic load_regfile;
    logic [4:0] rd_addr;
    logic [31:0] rd_wdata;
    logic [31:0] pc_rdata;
    logic [31:0] pc_wdata;
    logic [31:0] mem_addr;
    logic [3:0] mem_rmask;
    logic [3:0] mem_wmask;
    logic [31:0] mem_rdata;
    logic [31:0] mem_wdata;
	logic trap;
} rvfi_packet;
// synthesis translate_on

typedef enum bit [6:0] {
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
    op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
    mul	   = 3'b000,
    mulh   = 3'b001,
    mulhsu = 3'b010,
    mulhu  = 3'b011,
    div    = 3'b100,
    divu   = 3'b101,
    rem    = 3'b110,
    remu   = 3'b111
} muldiv_funct3_t;

typedef enum bit [1:0] {
    m_rem	   = 2'b00,
    m_div    = 2'b01,
    m_mul    = 2'b11
} m_ops;

typedef enum bit [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;

typedef struct packed {
	rv32i_word i_imm;
	rv32i_word s_imm;
	rv32i_word b_imm;
	rv32i_word u_imm;
	rv32i_word j_imm;
} imm_t;

typedef struct packed {
    rv32i_opcode opcode;
	rv32i_word pc;
	imm_t imm;
	rv32i_reg rd;
	rv32i_reg rs1;
	rv32i_reg rs2;
    branch_funct3_t cmpop;
	m_ops mulop;
	logic rs1_signed;
	logic rs2_signed;
    alu_ops aluop;
	store_funct3_t store_funct3;
	load_funct3_t load_funct3;
    logic inst_read;
    logic load_ir;
    logic load_regfile;
    logic load_mar;
    logic load_mdr;
    logic m_enable;
    logic data_read;
    logic data_write;
    regfilemux_sel_t regfilemux_sel;
    pcmux_sel_t pcmux_sel;
    alumux1_sel_t alumux1_sel;
    alumux2_sel_t alumux2_sel;
	addermux_sel_t addermux_sel;
    cmpmux_sel_t cmpmux_sel;
} rv32i_control_word;

typedef struct packed {
// synthesis translate_off
	rvfi_packet rvfi;
// synthesis translate_on
	rv32i_reg rs1, rs2, rd;
	rv32i_word pc_out;
	rv32i_opcode opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;
	imm_t imm;
} if_id_t;

typedef struct packed {
// synthesis translate_off
	rvfi_packet rvfi;
// synthesis translate_on
	rv32i_control_word ctrl;
	rv32i_word rs1_out;
	rv32i_word rs2_out;
} id_ex_t;

typedef struct packed {
// synthesis translate_off
	rvfi_packet rvfi;
// synthesis translate_on
	rv32i_control_word ctrl;
	rv32i_word alu_out;
//	logic [63:0] mext_out;
	rv32i_word adder_out;
	rv32i_word rs2_out;
	logic br_en;
} ex_mem_t;

typedef struct packed {
// synthesis translate_off
	rvfi_packet rvfi;
// synthesis translate_on
	rv32i_control_word ctrl;
	rv32i_word regfilemux_out;
} mem_wb_t;

endpackage : rv32i_types
