module receiver (

    input MAX10_CLK1_50,
    input [9:0] SW,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,

    input [35:0] GPIO

);

    wire rst = SW[9];

    wire [7:0] dato_recibido;
    wire rx_ready;

    reg [7:0] dato_reg = 8'd0;

    UART_RX #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000)) uart_rx (
        .clk(MAX10_CLK1_50),
        .rst(rst),
        .rx_in(GPIO[0]),
        .data_out(dato_recibido),
        .data_ready(rx_ready)
    );

    always @(posedge MAX10_CLK1_50 or posedge rst)
        begin
            if (rst)
                dato_reg <= 8'd0;
            else if (rx_ready)
                dato_reg <= dato_recibido;
        end

    wire [3:0] un = dato_reg % 10;
    wire [3:0] de = (dato_reg / 10) % 10;
    wire [3:0] ce = (dato_reg / 100) % 10;

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

endmodule
