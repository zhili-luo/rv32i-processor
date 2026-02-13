module icache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
	input clk,
	input rst,

	input [31:0] mem_address,
	output logic [31:0] mem_rdata,
	input mem_read,
	output logic mem_resp,
	
	output logic [31:0] pmem_address,
	input logic [255:0] pmem_rdata,
	output logic pmem_read,
	input pmem_resp
);
logic [255:0] mem_rdata256;

logic hit_any;
logic load_data;
logic load_waddr;
logic valid_in;

assign mem_rdata = mem_rdata256[(32*mem_address[4:2]) +: 32];

icache_control icache_control
(.*);

icache_datapath icache_datapath
(.*);

endmodule : icache
