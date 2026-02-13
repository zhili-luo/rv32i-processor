module l2cache_datapath #(
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
	// arbiter
	input logic [31:0] mem_address,
	input logic [255:0] mem_wdata256,
	output logic [255:0] mem_rdata256,
	input mem_read,
	input mem_write,
	// Memory (Cacheline adaptor)
	input logic [255:0] pmem_rdata,
	output logic [255:0] pmem_wdata,
	output logic [31:0] pmem_address,
	input pmem_resp,

	// Control signals
	input logic load_data,
	input logic valid_in,
	input logic load_waddr,
	output logic hit_any,
	output logic dirty
);

// reg output
logic [1:0][s_line-1:0] data_out;
logic [1:0][s_tag-1:0] tag_out;
logic [1:0] dirty_out;
logic [1:0] valid_out;
logic lru_out;

// inner signals
logic [s_tag-1:0] tag;
logic [s_index-1:0] index, rindex, windex;
logic [1:0] load;
logic read;
logic [1:0] hit;
logic [1:0][s_mask-1:0] write_en;
logic [31:0] mask;
logic [s_line-1:0] data_in;
logic dirty_in;

assign tag = mem_address[31-:s_tag];
assign index = mem_address[31-s_tag -: s_index];
assign rindex = index;
assign windex = index;
assign read = 1'b1;
assign data_in = (mem_write & hit_any) ? mem_wdata256 : pmem_rdata;

// output to control
assign hit_any = hit[0] | hit[1];
assign dirty = dirty_out[lru_out];
assign dirty_in = hit_any & mem_write;

// output
assign mem_rdata256 = data_out[hit[1]];
assign pmem_wdata = data_out[lru_out];
assign pmem_address[31:s_offset] = (load_waddr) ? {tag_out[lru_out], index} : mem_address[31:s_offset];
assign pmem_address[s_offset-1:0] = {s_offset{1'b0}};

generate
	genvar i;
	for (i=0; i<2; i++) begin : comb_logic
		assign hit[i] = ((tag == tag_out[i]) & valid_out[i]);

		always_comb
		begin
			load[i] = 1'b0;
			write_en[i] = 32'b0;
			if (load_data & (lru_out == i))
			begin
				load[i] = 1'b1;
				write_en[i] = 32'hffffffff;
			end

			if (hit[i] & mem_write)
			begin
				load[i] = 1'b1;
				write_en[i] = 32'hffffffff;
			end
		end
	end
endgenerate

data_array #(s_offset, s_index) data_arr[2]
(.*, .datain(data_in), .dataout(data_out));

array #(s_index, s_tag) tag_arr[2]
(.*, .datain(tag), .dataout(tag_out));

array #(s_index, 1) dirty_arr[2]
(.*, .datain(dirty_in), .dataout(dirty_out));

array #(s_index, 1) valid_arr[2]
(.*, .datain(valid_in), .dataout(valid_out));

array #(s_index, 1) lru_arr
(.*, .load(hit_any), .datain(hit[0]), .dataout(lru_out));

endmodule : l2cache_datapath
