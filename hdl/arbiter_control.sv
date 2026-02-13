module arbiter_control (
	input logic clk,
	input logic rst,

    input logic i_read,
    input logic pmem_resp,
    input logic d_write,
    input logic d_read,
    input logic [31:0] i_addr,
    input logic [31:0] d_addr,

    output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] pmem_addr,
    output logic i_resp,
    output logic d_resp
);

enum int unsigned {
    idle, icache, dcache
} state, next_state;

function void set_defaults();
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	pmem_addr = 32'b0;
	i_resp = 1'b0;
	d_resp = 1'b0;
endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
	unique case (state)
		idle:;
		icache:
            begin
                pmem_read = i_read;
                pmem_write = 0;
                pmem_addr = i_addr;
                i_resp = pmem_resp;
                d_resp = 0;
            end
		dcache:
            begin
                pmem_read = d_read;
                pmem_write = d_write;
                pmem_addr = d_addr;
                d_resp = pmem_resp;
                i_resp = 0;
            end
	endcase
end

always_comb
begin : next_state_logic
	/* Next state information and conditions (if any)
	* for transitioning between states */
	unique case (state)
		idle:
		begin
			if (i_read) next_state = icache;
			else if(d_read || d_write) next_state = dcache;
			else next_state = idle;
		end

		icache:
		begin
			if (pmem_resp && (d_read || d_write)) next_state = dcache;
         else if(pmem_resp && (~d_read) && (~d_write)) next_state = idle;
			else next_state = icache;
        end

		dcache:
		begin
         if(pmem_resp && i_read) next_state = icache;
			else if (pmem_resp&&(~i_read)) next_state = idle;
			else next_state = dcache;
        end

	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
	/* Assignment of next state on clock edge */
	if (rst)
		state <= idle;
	else
		state <= next_state;
end

endmodule : arbiter_control
