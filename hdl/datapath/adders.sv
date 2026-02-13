module half_adder
(
	input logic a, b,
	output logic co, s
);

assign s = a ^ b;
assign co = a & b;

endmodule : half_adder

module full_adder
(
	input logic a, b, ci,
	output logic co, s
);

assign s = (a ^ b) ^ ci;
assign co = a & b | (a ^ b) & ci;

endmodule : full_adder

module carry_save_adder
(
	input logic [31:0] a, b, ci,
	output logic [31:0] co, s
);

generate
	genvar i;
	for (i = 0; i < 32; i = i + 1) begin : csa_gen
		full_adder fa_csa (.a(a[i]), .b(b[i]), .ci(ci[i]), .co(co[i]), .s(s[i]));
	end
endgenerate

endmodule : carry_save_adder

module carry_prop_adder
(
	input logic [64:0] a, b,
	output logic [64:0] s
);

logic [64:0] temp;
logic co;

generate
	genvar i;
	for (i = 0; i < 65; i = i + 1) begin : cpa_gen
		if (i == 0)
			half_adder ha_cpa (.a(a[i]), .b(b[i]), .co(temp[i]), .s(s[i]));
		else if (i == 64)
			full_adder fa_cpa (.a(a[i]), .b(b[i]), .ci(temp[i-1]), .co(co), .s(s[i]));
		else 
			full_adder fa_cpa (.a(a[i]), .b(b[i]), .ci(temp[i-1]), .co(temp[i]), .s(s[i]));
	end
endgenerate

endmodule : carry_prop_adder