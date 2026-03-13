module transmiter (

    input CLOCK_50,
    input [9:0] SW,
    input [3:0] KEY,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output GPIO_0

);

    wire rst = SW[9];
    wire start_signal = ~KEY[0];
    wire uart_busy;
    wire tx_line;

    wire [7:0] cuenta = SW[7:0];

    wire [3:0] un = cuenta % 10;
    wire [3:0] de = (cuenta / 10) % 10;
    wire [3:0] ce = (cuenta / 100) % 10;

    UART_TX #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000), .BITS(8)) uart_tx (
        .clk(CLOCK_50),
        .rst(rst),
        .data_in(cuenta),
        .start(start_signal),
        .tx_out(tx_line),
        .busy(uart_busy)
    );

    BCD_module unidades (
        .bcd_in(un),
        .bcd_out(HEX0)
    );

    BCD_module decenas (
        .bcd_in(de),
        .bcd_out(HEX1)
    );

    BCD_module centenas (
        .bcd_in(ce),
        .bcd_out(HEX2)
    );

    assign GPIO_0 = tx_line;

endmodule
