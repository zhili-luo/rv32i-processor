
import rv32i_types::*;

module branch_predict
(
    input clk,
    input rst,
    
    input [31:0] pc_if,
    input [31:0] pc_ex,

    input p1_cor,
    input p2_cor,
    input update,
    input T,

    output result_out,
	 output p,
    output p1_out,
	 output p2_out
);

logic [3:0] ghr_out;
logic [3:0] index_if;
logic [3:0] index_ex;

logic [1:0] counter_out_local;
logic [1:0] counter_out_global;

logic [1:0] pout_global;
logic [1:0] pout_local;
logic [1:0] result;

assign index_if = pc_if[5:2] ^ ghr_out;
assign index_ex = pc_ex[5:2] ^ ghr_out;

assign result_out = p ? p2_out : p1_out;
assign result = p ? pout_global : pout_local;
assign p1_out = pout_local[1];
assign p2_out = pout_global[1];

//global branch predictor
ghr  #(4) ghr(
    .clk,
    .rst,

    .load(update),
    .in(T),
    .out(ghr_out)
);

counter counter_global(
    .clk,
    .rst,

	.update,
	.T,
	.curr(pout_global),

	.next(counter_out_global)
);

predictor predictor_global(
    .clk,
    .rst,

    .index_if,
    .index_ex,

    .counter_out(counter_out_global),
    .sel(1'b1),
	 .update,
	 .T,

    .out(pout_global)
);


//local branch predictor
counter counter_local(
    .clk,
    .rst,

	.update,
	.T,
	.curr(pout_local),

	.next(counter_out_local)
);

predictor predictor_local(
    .clk,
    .rst,

    .index_if(pc_if[5:2]),
    .index_ex(pc_ex[5:2]),

    .counter_out(counter_out_local),
    .sel(1'b0),
	 .update,
	 .T,

    .out(pout_local)
);

//select predictor
selector selector
(
    .clk,
    .rst,

    .p1_cor,
    .p2_cor,
	 .update,

    .p
);

endmodule : branch_predict
