module l2cache #(
    parameter s_offset = 5,
    parameter s_index  = 5,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
	input clk,
	input rst,
	// CPU signals
	input [31:0] mem_address,
	output logic [255:0] mem_rdata,
	input [255:0] mem_wdata,
	input mem_read,
	input mem_write,
	output logic mem_resp,

	// Main memory signals
	output logic [31:0] pmem_address,
	input logic [255:0] pmem_rdata,
	output logic [255:0] pmem_wdata,
	output logic pmem_read,
	output logic pmem_write,
	input pmem_resp
);
logic [255:0] mem_wdata256;
logic [255:0] mem_rdata256;

assign mem_wdata256 = mem_wdata;
assign mem_rdata = mem_rdata256;

logic hit_any;
logic load_data;
logic load_waddr;
logic valid_in;
logic dirty;

l2cache_control l2cache_control
(.*);

l2cache_datapath #(s_offset, s_index, s_tag, s_mask, s_line, num_sets) l2cache_datapath
(.*);


endmodule : l2cache
