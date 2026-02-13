module predictor
(
    input clk,
    input rst,

    input [3:0] index_if,
    input [3:0] index_ex,

    input [1:0] counter_out,
    input sel,
	 input update,
	 input T,

    output [1:0] out
);


logic [1:0] data_0 [16]  = '{default:2'b00};
logic [1:0] data_1 [16]  = '{default:2'b11};


always @(posedge clk)
begin
	if(rst) begin
		data_0 <= '{default:2'b00};
		data_1 <= '{default:2'b11};
	end 
	else if(update) 
	begin
		if(~sel) data_0[index_ex] <= counter_out;
		else data_1[index_ex] <= counter_out;
	end
	else begin
		data_0 <= data_0;
		data_1 <= data_1;
	end

end

assign out = (sel)? data_1[index_if]: data_0[index_if];


endmodule : predictor
