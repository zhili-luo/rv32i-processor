module counter
(
    input clk,
    input rst,

	input update,
	input T,
	input logic [1:0] curr,

	output logic [1:0] next

);
logic NT;
assign NT = update ^ T;

always_ff @(posedge clk)
begin
	if(update) begin

		unique case (curr)
			2'b00:
			begin
				if(T) next <= 2'b01;
				else next <= 2'b00;
			end
			2'b01:
			begin
				if(T) next <= 2'b10;
				else if(NT) next <= 2'b00;
				else next<= 2'b01;

			end
			2'b10:
			begin
				if(T) next <= 2'b11;
				else if (NT) next <= 2'b01;
				else next<= 2'b10;
			end
			2'b11:
			begin
				if(T) next <= 2'b11;
				else next <= 2'b10;
			end

			default:;
		endcase
	end 
	else next <= curr;
end


endmodule : counter
