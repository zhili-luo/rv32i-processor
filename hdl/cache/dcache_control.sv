module dcache_control (
	input clk,
	input rst,
	input pmem_resp,
	input mem_read,
	input mem_write,
	output logic pmem_read,
	output logic pmem_write,
	output logic mem_resp,
	
	// Datapath
	input hit_any,
	input dirty,
	output logic load_data,
	output logic load_waddr,
	output logic valid_in,
	output logic addr_in_sel, addr_out_sel
);

int unsigned hit_count, hit_count_next;
int unsigned miss_count, miss_count_next;

enum int unsigned {
    decode, rd, wr
} state, next_state;

function void set_defaults();
	load_data = 1'b0;
	load_waddr = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	mem_resp = 1'b0;
	valid_in = 1'b1;
	addr_in_sel = 1'b0;
	addr_out_sel = 1'b0;
endfunction

always_comb
begin : state_actions
	// counters
	hit_count_next = hit_count;
	miss_count_next = miss_count;
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
	unique case (state)

		decode:
		begin
			if (mem_read || mem_write) begin
				if (hit_any) begin 
					mem_resp = 1;
					hit_count_next = hit_count + 1;
				end
				else begin
					miss_count_next = miss_count + 1;
				end
			end
		end
		rd:
		begin 
			pmem_read = 1;
			if(pmem_resp) begin
				load_data = 1;
				valid_in = 1;
			end
		end

		wr:
		begin
			load_waddr = 1;
			pmem_write = 1;
		end
		default:;
	endcase
end

always_comb
begin : next_state_logic
	/* Next state information and conditions (if any)
	* for transitioning between states */
	unique case (state)
		decode: 
		begin
			next_state = decode;
			if (mem_read || mem_write) begin
				if	(~hit_any) begin
					if (dirty) next_state = wr;
					else next_state = rd;
				end
			end
		end
		rd: begin
			if (pmem_resp) next_state = decode;
			else next_state = rd;
		end
		
		wr: begin
			if (pmem_resp) next_state = rd;
			else next_state = wr;
		end
		
		default: next_state = decode;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
	/* Assignment of next state on clock edge */
	if (rst) begin
		state <= decode;
		hit_count <= 0;
		miss_count <= 0;
	end
	else begin
		state <= next_state;
		hit_count <= hit_count_next;
		miss_count <= miss_count_next;
	end
end

endmodule : dcache_control
