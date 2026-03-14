module PWM_tb ();

    //Señales de entrada
    reg MAX10_CLK1_50;
    reg [9:0] SW;

    //Señales de salida
    wire [15:0] ARDUINO_IO;
    wire [0:6] HEX0;
    wire [0:6] HEX1;
    wire [0:6] HEX2;

    //Instancia del módulo
    PWM PWM (
        .MAX10_CLK1_50(MAX10_CLK1_50),
        .SW(SW),
        .ARDUINO_IO(ARDUINO_IO),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2)
    );

    initial
        begin
            MAX10_CLK1_50 = 0;
            SW = 10'b0;
        end

    always
        #10 MAX10_CLK1_50 = ~MAX10_CLK1_50; //Reloj de 50 MHz

    initial
        begin
            $display("Simulacion iniciada");

            #30;

            SW[0] = 1; //Reset
            #20;
            SW[0] = 0;

            #1000;

            repeat(6)
                begin
                    SW[8:1] = $random % 200; //Prueba con varios grados
                    #2000000;

                    $display("Grados solicitados = %d | Grados limitados = %d | PWM = %b", SW[8:1], PWM.grado, ARDUINO_IO[0]);
                end

            $stop;
            $finish;
        end

    initial
        begin
            $dumpfile("PWM_tb.vcd");
            $dumpvars(0, PWM_tb);
        end

endmodule
