import rv32i_types::*;

module mext(
  input clk,
  input rst,
  input m_ops mulop,
  input [31:0] rs1,
  input [31:0] rs2,
  input logic rs1_signed, rs2_signed,
  input enable,

  output logic [63:0] out,
  output logic pause
);

logic [32:0] counter, counter_next;
logic [64:0] sum, sum_next;
logic [64:0] a, b, s;
logic [64:0] rs1_ext, rs2_ext;
logic [64:0] rs1_pos, rs2_neg;
logic [63:0] out_abs, quot, quot_next;
logic rs1_sign, rs2_sign;

assign rs1_ext = {{33{rs1[31] & rs1_signed}}, rs1};
assign rs2_ext = {{33{rs2[31] & rs2_signed}}, rs2};
assign rs1_sign = rs1_ext[64];
assign rs2_sign = rs2_ext[64];

always_comb begin
	if (rs1_sign)
		rs1_pos = ~rs1_ext + 1'b1;
	else
		rs1_pos = rs1_ext;

	if (rs2_sign)
		rs2_neg = rs2_ext;
	else
		rs2_neg = ~rs2_ext + 1'b1;
end



carry_prop_adder adder(.*);
enum int unsigned {
	idle, run
} state, next_state;

always_comb begin : state_action
	pause = enable;
	sum_next = sum;
	counter_next = counter;
	quot_next = quot;
	out = '0;
	out_abs = '0;
	a = '0;
	b = '0;
	// setup
	unique case (state)
	idle: begin
		counter_next = '0;
		if (mulop == m_mul)
			sum_next = '0;
		else
			sum_next = rs1_pos;
	end
	
	run: begin	
		// multiply
		counter_next = counter + 1'b1;
		if (mulop == m_mul) begin
			if (counter == 32'd32) begin
				pause = 1'b0;
				counter_next = '0;
			end
			a = sum;
			sum_next = s;
			if (rs2_ext[counter]) begin
				if (rs2_signed & counter == 32'd32)
					b = ~(rs1_ext << counter) + 1'b1;
				else
					b = rs1_ext << counter;
			end
			else
				b = '0;
			out = sum_next[63:0];
		end
		else begin
			if (counter == 32'd31) begin
				pause = 1'b0;
				counter_next = '0;
			end
			
			a = sum;
			b = rs2_neg << (31 - counter);
			if (s[64]) begin
				sum_next = sum;
				quot_next[31-counter] = 1'b0;
			end
			else begin
				sum_next = s;
				quot_next[31-counter] = 1'b1;
			end
			if (mulop == m_rem)
				out_abs = sum_next[63:0];
			else
				out_abs = quot_next;
			if (rs1_sign ^ rs2_sign)
				out = ~out_abs + 1'b1;
			else
				out = out_abs;
				
			//special case
			if ((rs1 == 32'h80000000) && (rs2 == 32'hffffffff)) begin
				pause = 1'b0;
				if (mulop == m_div)
					out = 32'h80000000;
				else
					out = '0;
			end
			else if (rs2 == '0) begin
				pause = 1'b0;
				if (mulop == m_div)
					out = 32'hffffffff;
				else
					out = rs1;
			end
		end
	end
	endcase
end

always_comb begin : state_logic
	next_state = state;
	unique case (state)
		idle: begin
			next_state = run;
		end
		run: begin
			if (~pause)
				next_state = idle;
		end
	endcase
end

always_ff @(posedge clk) begin
	if (enable) begin
		counter <= counter_next;
		sum <= sum_next;
		quot <= quot_next;
		state <= next_state;
	end
	else begin
		counter <= '0;
		sum <= '0;
		quot <= '0;
		state <= idle;
	end
end

endmodule : mext
