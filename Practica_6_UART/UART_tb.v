module UART_tb ();

    //Señales para el transmisor
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg start;
    //wire tx_out;
    wire busy;

    //Señales intermedias
    wire UART_wire; // Conexión entre TX y RX

    //Señales para el receptor
    //reg rx_in;
    wire [7:0] data_out;
    wire data_ready;

    UART_TX #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000), .BITS(8)) UART_TX (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .start(start),
        .tx_out(UART_wire),
        .busy(busy)
    );

    UART_RX #(.BAUD_RATE(9600), .CLOCK_FREQ(50000000), .BITS(8)) UART_RX (
        .clk(clk),
        .rst(rst),
        .rx_in(UART_wire),
        .data_out(data_out),
        .data_ready(data_ready)
    );

    initial
        begin
            clk = 0;
            rst = 0;
            data_in = 8'h00;
            start = 0;
        end

    always
        #10 clk = ~clk; // Genera un reloj de 50 MHz

    initial
        begin
            $display("Simulación iniciada");

            #30;

            rst = 1; // Activa el reset
            #10;
            rst = 0; // Desactiva el reset

            #20000; // Espera suficiente tiempo para que el sistema se estabilice

            repeat(10)
                begin
                    data_in = $random % 256; // Carga un dato de prueba
                    start = 1; // Inicia la transmisión
                    #20;
                    start = 0; // Detiene la señal de inicio

                    @(posedge data_ready); // Espera a que el receptor termine
                    #10; // Pequeño delay para asegurar que data_out se actualizó

                    $display("Dato transmitido: %h, Dato recibido: %h", data_in, data_out);

                    // En lugar de @(negedge data_ready), esperamos a que el TX no esté ocupado
                    wait(busy == 0);
                    #100; // Espacio entre transmisiones
                end

            $stop;
            $finish;
        end

    initial 
        begin
            $dumpfile("UART_tb.vcd");
            $dumpvars(0, UART_tb);
        end

endmodule
