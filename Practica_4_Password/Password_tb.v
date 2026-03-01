module password_tb();

    reg clk;
    reg rst;
    reg load;
    reg [3:0] SW;

    wire [6:0] HEX0;
    wire [6:0] HEX1;
    wire [6:0] HEX2;
    wire [6:0] HEX3;

    password dut(
        .clk(clk),
        .rst(rst),
        .load(load),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    initial 
        begin
            clk = 0;
            forever #10 clk = ~clk;
        end

    initial 
        begin
            rst = 1; 
            load = 0; 
            SW = 0; 
            #20;

            rst = 0;

            // Contraseña correcta: 1-2-3-4
            SW = 4'h1; #20;
            load = 1; #20;
            load = 0; #20;

            SW = 4'h2; #20;
            load = 1; #20;
            load = 0; #20;

            SW = 4'h3; #20;
            load = 1; #20;
            load = 0; #20;

            SW = 4'h4; #20;
            load = 1; #20;
            load = 0; #40;

            // Reset
            rst = 1; #20;
            rst = 0; #20;

            // Contraseña incorrecta
            SW = 4'h5; #20;
            load = 1; #20;
            load = 0; #40;

            $stop;
            $finish;
        end

    initial 
        begin
            $monitor("rst = %b, load = %b, SW = %h, HEX3 = %b, HEX2 = %b, HEX1 = %b, HEX0 = %b",
                     rst, load, SW, HEX3, HEX2, HEX1, HEX0);
        end

    initial 
        begin
            $dumpfile("password_tb.vcd");
            $dumpvars(0, password_tb);
        end

endmodule
