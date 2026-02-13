module cacheline_adaptor
(
    input clk,
    input rst,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);
	assign read_o = read_i & (~resp_o);
	assign write_o = write_i & (~resp_o);
	assign address_o = address_i;

	logic [1:0] loc, loc_next;
	logic resp_o_next;
	
	always_ff @(posedge clk) begin
		
		if (resp_i == 1) begin
			line_o [64*loc +: 64] <= burst_i;
			loc <= loc_next;
		end
		resp_o <= resp_o_next;
		
		if (rst) begin
			loc <= 0;
			resp_o <= 0;
		end
	end

	always_comb begin
		burst_o = line_i [64*loc +: 64];
		loc_next = loc + 1'b1;
		if (loc == 3)
			resp_o_next = 1;
		else
			resp_o_next = 0;
	end

endmodule : cacheline_adaptor
