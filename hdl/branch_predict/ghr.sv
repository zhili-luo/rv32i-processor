module ghr #(parameter width = 4)
(
    input clk,
    input rst,
    input load,
    input in,
    output logic [width-1:0] out
);

logic [width-1:0] data = 1'b0;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= '0;
    end
    else if (load)
    begin
        data <= {data[2:0], in};
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    out = data;
end

endmodule : ghr
