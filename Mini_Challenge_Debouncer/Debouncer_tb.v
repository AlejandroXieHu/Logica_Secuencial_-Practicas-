module debouncer_tb;

    reg clk;
    reg [1:0] KEY;
    wire [9:0] LEDR;

    debouncer_wr DUT (
        .MAX10_CLK1_50(clk),
        .KEY(KEY),
        .LEDR(LEDR)
    );

    initial
        clk = 0;

    always
        #10 clk = ~clk;

    initial
    begin
        KEY = 2'b11;

        $display("Inicio de simulación");
        $monitor("Tiempo=%0t | KEY=%b | Contador=%d", $time, KEY, LEDR);

        #100;

        KEY[1] = 0;
        #21000000;
        KEY[1] = 1;
        #21000000;

        $display("Primera presión");

        KEY[0] = 0;
        #21000000;
        KEY[0] = 1;
        #21000000;

        $display("Segunda presión");

        KEY[0] = 0;
        #21000000;
        KEY[0] = 1;
        #21000000;

        $display("Reset");

        KEY[1] = 0;
        #21000000;
        KEY[1] = 1;
        #21000000;

        $display("Fin de simulación");
        $finish;
    end

    initial 
        begin
            $dumpfile("debouncer_tb.vcd");
            $dumpvars(0, debouncer_tb);
        end

endmodule
