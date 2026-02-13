module selector
(
    input clk,
    input rst,

    input logic p1_cor,
    input logic p2_cor,
	 input logic update,

    output logic p

);

enum int unsigned {
    s_00, s_01, s_10, s_11
} state, next_state;

function void set_defaults();
    p = 0;
endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
	unique case (state)
		s_00:
		begin
            p = 0;
		end
		s_01:
		begin
            p = 0;
		end
		s_10:
		begin
            p = 1;
		end
		s_11:
		begin
            p = 1;
		end

	endcase
end

always_ff @(posedge update)
begin : next_state_logic
	/* Next state information and conditions (if any)
	* for transitioning between states */
	unique case (state)
		s_00:
		begin
            if((~p1_cor) && p2_cor) next_state <= s_01;
            else next_state <= s_00;
		end
		s_01:
		begin
            if((~p1_cor) && p2_cor) next_state <= s_10;
				else if(p1_cor && (~p2_cor)) next_state <= s_00;
            else next_state <= s_01;
		end
		s_10:
		begin
				if((~p1_cor) && (p2_cor) ) next_state <= s_11;
            else if((p1_cor) && (~p2_cor)) next_state <= s_01;
            else next_state = s_10;
		end
		s_11:
		begin
            if((p1_cor) && (~p2_cor) ) next_state <= s_10;
            else next_state <= s_11;
		end
	endcase
end

always_comb
begin: next_state_assignment
	/* Assignment of next state on clock edge */
	if (rst)
		state = s_00;
	else state = next_state;
end

endmodule : selector
