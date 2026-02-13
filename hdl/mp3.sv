import rv32i_types::*;

module mp3
(
    input clk,
    input rst,
	input mem_resp,
    input [63:0] mem_rdata,
    output logic mem_read,
    output logic mem_write,
    output logic [31:0] mem_addr,
    output logic [63:0] mem_wdata

);

	/* I Cache Ports */
logic inst_read;
logic [31:0] inst_addr;
logic inst_resp;
logic [31:0] inst_rdata;
	/* D Cache Ports */
logic data_read;
logic data_write;
logic [3:0] data_mbe;
logic [31:0] data_addr;
logic [31:0] data_wdata;
logic data_resp;
logic [31:0] data_rdata;

logic l2_read;
logic l2_write;
logic [31:0] l2_addr;
logic [255:0] l2_wdata;
logic [255:0] l2_rdata;
logic l2_resp;

logic i_read;
logic i_write;
logic [31:0] i_addr;
logic [255:0] i_rdata;
logic i_resp;

logic d_read;
logic d_write;
logic [31:0] d_addr;
logic [255:0] d_wdata;
logic [255:0] d_rdata;
logic d_resp;

logic ca_read;
logic ca_write;
logic [31:0] ca_addr;
logic [255:0] ca_wdata;
logic [255:0] ca_rdata;
logic ca_resp;

datapath datapath(.*);

dcache dcache(
	.clk,
	.rst,

	.mem_address		(data_addr),
	.mem_rdata			(data_rdata),
	.mem_wdata			(data_wdata),
	.mem_read			(data_read),
	.mem_write			(data_write),
	.mem_byte_enable	(data_mbe),
	.mem_resp			(data_resp),

	.pmem_address		(d_addr),
	.pmem_rdata			(d_rdata),
	.pmem_wdata			(d_wdata),
	.pmem_read			(d_read),
	.pmem_write			(d_write),
	.pmem_resp			(d_resp)
);

icache icache(
	.clk,
	.rst,

	.mem_address		(inst_addr),
	.mem_rdata			(inst_rdata),
	.mem_read			(inst_read),
	.mem_resp			(inst_resp),

	.pmem_address		(i_addr),
	.pmem_rdata			(i_rdata),
	.pmem_read			(i_read),
	.pmem_resp			(i_resp)
);

arbiter arbiter(
	.clk,
	.rst,

    //dcache
    .d_resp,
    .d_rdata,
    .d_read,
	.d_write,
    .d_addr,
    .d_wdata,

    //icache
    .i_read,
    .i_addr,
    .i_rdata,
    .i_resp,

    //l2-cache
	.pmem_read(l2_read),
    .pmem_write(l2_write),
    .pmem_addr(l2_addr),
    .pmem_wdata(l2_wdata),
    .pmem_rdata(l2_rdata),
    .pmem_resp(l2_resp)
);

l2cache l2cache(
  .clk(clk),
  .rst(rst),
  .mem_address(l2_addr),
  .mem_rdata(l2_rdata),
  .mem_wdata(l2_wdata),
  .mem_read(l2_read),
  .mem_write(l2_write),
  .mem_resp(l2_resp),

  .pmem_address(ca_addr),
  .pmem_rdata(ca_rdata),
  .pmem_wdata(ca_wdata),
  .pmem_read(ca_read),
  .pmem_write(ca_write),
  .pmem_resp(ca_resp)
);

cacheline_adaptor cacheline_adaptor
(
    .clk,
    .rst,

    .line_i(ca_wdata),
    .line_o(ca_rdata),
    .address_i(ca_addr),
    .read_i(ca_read),
    .write_i(ca_write),
    .resp_o(ca_resp),

    .burst_i(mem_rdata),
    .burst_o(mem_wdata),
    .address_o(mem_addr),
    .read_o(mem_read),
    .write_o(mem_write),
    .resp_i(mem_resp)
);

endmodule : mp3
