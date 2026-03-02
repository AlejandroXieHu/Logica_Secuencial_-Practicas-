module counter_wr (

    input MAX10_CLK1_50,
    input [1:0] KEY,
    input [9:0] SW,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3

);

    wire rst;
    wire load;
    wire up_down;
    wire slow_clk;
    wire [13:0] data_in;
    wire [13:0] count_value;

    assign rst = ~KEY[0];
    assign load = ~KEY[1];
    assign up_down = SW[9];
    assign data_in = {5'b00000, SW[8:0]};

    clock_divider #(.FREQ(1)) clk_div (
        .clk(MAX10_CLK1_50), 
        .rst(rst), 
        .clk_div(slow_clk)
    );

    counter #(.CMAX(100)) counter (
        .clk(slow_clk), 
        .rst(rst), 
        .load(load), 
        .up_down(up_down), 
        .data_in(data_in), 
        .count(count_value)
    );

    BCD_4Displays display (
        .bcd_in(count_value), 
        .D_un(HEX0), 
        .D_de(HEX1), 
        .D_ce(HEX2), 
        .D_mi(HEX3)
    );

endmodule
