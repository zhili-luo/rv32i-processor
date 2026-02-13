module arbiter 
(
	input clk,
	input rst,

    //dcache
    output logic d_resp,
    output logic [255:0] d_rdata,
    input logic d_read,
    input logic d_write,
    input logic [31:0] d_addr,
    input logic [255:0] d_wdata,

    //icache
    input logic i_read,
    input logic [31:0] i_addr,
    output logic [255:0] i_rdata,
    output logic i_resp,

    //l2-cache
	output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] pmem_addr,
    output logic [255:0] pmem_wdata,
    input logic [255:0] pmem_rdata,
    input logic pmem_resp

);

arbiter_control arbiter_control
(.*);

arbiter_datapath arbiter_datapath
(.*);

endmodule : arbiter