module PWM (

    input MAX10_CLK1_50,
    input [9:0] SW,

    output [15:0] ARDUINO_IO,
    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2

);

    wire rst = SW[0];
    wire [7:0] grado_raw = SW[8:1];

    reg [7:0] grado;

    wire [3:0] uni;
    wire [3:0] dec;
    wire [3:0] cen;

    always @(*)
        begin
            if (grado_raw > 8'd180)
                grado = 8'd180;
            else
                grado = grado_raw;
        end

    wire clk_div;
    reg [18:0] count = 0;
    wire [18:0] duty;
    wire arduino;

    parameter maxCount = 500000;

    clock_divider #(.FREQ(25000000)) clkdiv (
        .clk(MAX10_CLK1_50),
        .rst(rst),
        .clk_div(clk_div)
    );

    assign duty = 25000 + (grado * 25000) / 180;

    always @(posedge clk_div or posedge rst)
        begin
            if (rst)
                count <= 0;
            else if (count >= maxCount)
                count <= 0;
            else
                count <= count + 1;
        end

    assign arduino = (count < duty);
    assign ARDUINO_IO[0] = arduino;

    assign uni = grado % 10;
    assign dec = (grado / 10) % 10;
    assign cen = (grado / 100) % 10;

    BCD_module d0 (
        .bcd_in(uni), 
        .bcd_out(HEX0)
    );

    BCD_module d1 (
        .bcd_in(dec), 
        .bcd_out(HEX1)
    );

    BCD_module d2 (
        .bcd_in(cen), 
        .bcd_out(HEX2)
    );

endmodule
