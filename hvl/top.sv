module mp3_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);
/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP3
assign rvfi.inst = dut.datapath.rvfi.inst;
assign rvfi.rs1_addr = dut.datapath.rvfi.rs1_addr;
assign rvfi.rs2_addr = dut.datapath.rvfi.rs2_addr;
assign rvfi.rs1_rdata = rvfi.rs1_addr ? dut.datapath.rvfi.rs1_rdata : 0;
assign rvfi.rs2_rdata = rvfi.rs2_addr ? dut.datapath.rvfi.rs2_rdata : 0;
assign rvfi.load_regfile = dut.datapath.rvfi.load_regfile;
assign rvfi.rd_addr = dut.datapath.rvfi.rd_addr;
assign rvfi.rd_wdata = rvfi.rd_addr ? dut.datapath.rvfi.rd_wdata : 0;
assign rvfi.pc_rdata = dut.datapath.rvfi.pc_rdata;
assign rvfi.pc_wdata = dut.datapath.rvfi.pc_wdata;
assign rvfi.mem_addr = dut.datapath.rvfi.mem_addr;
assign rvfi.mem_rmask = dut.datapath.rvfi.mem_rmask;
assign rvfi.mem_wmask = dut.datapath.rvfi.mem_wmask;
assign rvfi.mem_rdata = dut.datapath.rvfi.mem_rdata;
assign rvfi.mem_wdata = dut.datapath.rvfi.mem_wdata;
//assign rvfi.trap = dut.datapath.rvfi.trap;

assign rvfi.commit = (dut.datapath.stage5.ctrl != 0) & (~dut.datapath.pause); // Set high when a valid instruction is modifying regfile or PC
// assign rvfi.halt = 0;
logic halt_flag;
logic [2:0] halt_cnt;
assign halt_flag = (dut.datapath.stage4.ctrl.pc == dut.datapath.stage1.pcmux_out);
always @(posedge itf.clk) begin
	if (itf.rst) begin
		halt_cnt <= 0;
	end
	if (halt_flag) begin
		halt_cnt ++;
	end
end
assign rvfi.halt = (halt_cnt == 1);   // Set high when you detect an infinite loop
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO
/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.datapath.stage2.regfile.data;

/*********************** Instantiate your design here ************************/
mp3 dut(
	.clk	(itf.clk),
	.rst	(itf.rst),
	.mem_read	(itf.mem_read),
    .mem_write	(itf.mem_write),
    .mem_addr	(itf.mem_addr),
    .mem_wdata	(itf.mem_wdata),
    .mem_resp	(itf.mem_resp),
    .mem_rdata	(itf.mem_rdata)

);

assign itf.inst_read = dut.inst_read;
assign itf.inst_addr = dut.inst_addr;
assign itf.inst_rdata = dut.inst_rdata;
assign itf.inst_resp = dut.inst_resp;

assign itf.data_read = dut.data_read;
assign itf.data_write = dut.data_write;
assign itf.data_mbe = dut.data_mbe;
assign itf.data_addr = dut.data_addr;
assign itf.data_wdata = dut.data_wdata;
assign itf.data_rdata = dut.data_rdata;
assign itf.data_resp = dut.data_resp;

logic [31:0] regfile [32];
assign regfile = dut.datapath.stage2.regfile.data;

int branch_total, branch_mispredict, stall_count;
int icache_miss, icache_hit, dcache_miss, dcache_hit, l2cache_miss, l2cache_hit;
assign branch_total = dut.datapath.branch_total;
assign branch_mispredict = dut.datapath.branch_mispredict;
assign stall_count = dut.datapath.stall_count;
assign icache_miss = dut.icache.icache_control.miss_count;
assign dcache_miss = dut.dcache.dcache_control.miss_count;
assign l2cache_miss = dut.l2cache.l2cache_control.miss_count;
assign icache_hit = dut.icache.icache_control.hit_count;
assign dcache_hit = dut.dcache.dcache_control.hit_count;
assign l2cache_hit = dut.l2cache.l2cache_control.hit_count;

/***************************** End Instantiation *****************************/

endmodule
