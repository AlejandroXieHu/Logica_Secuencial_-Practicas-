module debouncer_wr (

    input MAX10_CLK1_50,
    input [1:0] KEY,
    output [9:0] LEDR,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3

);

    wire clk;
    wire rst;
    wire boton_in;
    wire boton_limpio;
    wire pulso;

    wire [9:0] contador;

    assign clk = MAX10_CLK1_50;
    assign rst = ~KEY[1];
    assign boton_in = ~KEY[0];

    debouncer Debouncer (
        .clk(clk),
        .rst(rst),
        .boton_in(boton_in),
        .boton_out(boton_limpio)
    );

    edge_detector EdgeDetector (
        .clk(clk),
        .rst(rst),
        .boton_out(boton_limpio),
        .pulso(pulso)
    );

    counter_debouncer CounterDebouncer (
        .clk(clk),
        .rst(rst),
        .pulso(pulso),
        .leds(contador)
    );

    assign LEDR = contador;

    BCD_4Displays BCD (
        .bcd_in(contador),
        .D_un(HEX0),
        .D_de(HEX1),
        .D_ce(HEX2),
        .D_mi(HEX3)
    );

endmodule
