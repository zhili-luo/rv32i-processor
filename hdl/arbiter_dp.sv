module arbiter_datapath 
(
	input clk,
	input rst,

    //dcache
    output logic [255:0] d_rdata,
    input logic [255:0] d_wdata,

    //icache
    output logic [255:0] i_rdata,

    //l2-cache
    output logic [255:0] pmem_wdata,
    input logic [255:0] pmem_rdata
);

assign i_rdata = pmem_rdata;
assign d_rdata = pmem_rdata;

assign pmem_wdata = d_wdata;

endmodule : arbiter_datapath
