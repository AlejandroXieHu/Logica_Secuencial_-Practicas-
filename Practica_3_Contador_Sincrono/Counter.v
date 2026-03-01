module counter #(parameter CMAX = 100) (

    input clk,
    input rst,
    input load,
    input up_down,
    input [13:0] data_in,
    output reg [13:0] count

);

    always @(posedge clk)
        begin
            if (rst)
                begin
                    count <= 0;
                end
            else if (load)
                begin
                    count <= data_in;
                end
            else if (up_down)
                begin
                    if (count == CMAX)
                        count <= 0;
                    else
                        count <= count + 1;
                end
            else
                begin
                    if (count == 0)
                        count <= CMAX;
                    else
                        count <= count - 1;
                end
        end

endmodule
