# Práctica 6: UART

## UART_TX.v

Este módulo implementa el **transmisor UART (Universal Asynchronous Receiver Transmitter)**.  
Se encarga de enviar datos en serie a través de la línea `tx_out`.

El funcionamiento se basa en una **máquina de estados** con cuatro etapas:

- **IDLE:** la línea permanece en estado inactivo esperando iniciar transmisión.
- **START_BIT:** se envía el bit de inicio (`0`).
- **DATA_BITS:** se transmiten los bits del dato uno por uno.
- **STOP_BIT:** se envía el bit de parada (`1`) y finaliza la transmisión.

```verilog
module UART_TX #(parameter BAUD_RATE = 9600, parameter CLOCK_FREQ = 50000000, parameter BITS = 8)(

    input wire clk,
    input wire rst,
    input wire [BITS - 1:0] data_in,
    input wire start,

    output reg tx_out,
    output reg busy

);

    localparam IDLE = 2'b00, START_BIT = 2'b01, DATA_BITS = 2'b10, STOP_BIT = 2'b11;

    reg [1:0] state;
    reg [3:0] bit_index;
    reg [15:0] baud_counter;
    reg [BITS-1:0] data_buffer;

    always @(posedge clk or posedge rst)
        begin
            if (rst)
                begin
                    state <= IDLE;
                    tx_out <= 1'b1;
                    busy <= 0;
                    bit_index <= 0;
                    baud_counter <= 0;
                end
            else
                begin
                    case (state)

                        IDLE:
                            begin
                                tx_out <= 1'b1;
                                busy <= 0;

                                if (start)
                                    begin
                                        data_buffer <= data_in;
                                        state <= START_BIT;
                                        busy <= 1;
                                    end
                            end

                        START_BIT:
                            begin
                                tx_out <= 1'b0;

                                if (baud_counter < (CLOCK_FREQ / BAUD_RATE) - 1)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;
                                        state <= DATA_BITS;
                                        bit_index <= 0;
                                    end
                            end

                        DATA_BITS:
                            begin
                                tx_out <= data_buffer[bit_index];

                                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;

                                        if (bit_index < BITS - 1)
                                            bit_index <= bit_index + 1;
                                        else
                                            state <= STOP_BIT;
                                    end
                            end

                        STOP_BIT:
                            begin
                                tx_out <= 1'b1;

                                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;
                                        state <= IDLE;
                                    end
                            end

                    endcase
                end
        end

endmodule
```

---

## UART_RX.v

Este módulo implementa el **receptor UART**, encargado de recibir los datos seriales desde la línea `rx_in` y reconstruirlos en formato paralelo.

El proceso de recepción sigue los siguientes estados:

- **IDLE:** espera detectar el bit de inicio.
- **START_BIT:** sincroniza la lectura en la mitad del bit.
- **DATA_BITS:** captura los bits del dato uno por uno.
- **STOP_BIT:** valida el bit de parada y habilita la señal `data_ready`.

```verilog
module UART_RX #(parameter BAUD_RATE = 9600, parameter CLOCK_FREQ = 50000000, parameter BITS = 8) (

    input clk,
    input rst,
    input rx_in,

    output reg [BITS - 1:0] data_out,
    output reg data_ready

);

    localparam IDLE = 2'b00;
    localparam START_BIT = 2'b01;
    localparam DATA_BITS = 2'b10;
    localparam STOP_BIT = 2'b11;

    reg [1:0] state;
    reg [3:0] bit_index;
    reg [15:0] baud_counter;
    reg [BITS-1:0] data_buffer;

    always @(posedge clk or posedge rst)
        begin
            if (rst)
                begin
                    state <= IDLE;
                    data_out <= 0;
                    data_ready <= 0;
                    bit_index <= 0;
                    baud_counter <= 0;
                end
            else
                begin
                    case (state)

                        IDLE:
                            begin
                                data_ready <= 0;

                                if (!rx_in)
                                    begin
                                        state <= START_BIT;
                                        baud_counter <= 0;
                                    end
                            end

                        START_BIT:
                            begin
                                if (baud_counter < (CLOCK_FREQ / BAUD_RATE) / 2)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;
                                        state <= DATA_BITS;
                                        bit_index <= 0;
                                    end
                            end

                        DATA_BITS:
                            begin
                                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;
                                        data_buffer[bit_index] <= rx_in;

                                        if (bit_index < BITS - 1)
                                            bit_index <= bit_index + 1;
                                        else
                                            state <= STOP_BIT;
                                    end
                            end

                        STOP_BIT:
                            begin
                                if (baud_counter < CLOCK_FREQ / BAUD_RATE - 1)
                                    baud_counter <= baud_counter + 1;
                                else
                                    begin
                                        baud_counter <= 0;
                                        data_out <= data_buffer;
                                        data_ready <= 1;
                                        state <= IDLE;
                                    end
                            end

                    endcase
                end
        end

endmodule
```

---

## transmiter.v

Este módulo funciona como el **top module del transmisor UART en la FPGA**.  
Los switches (`SW`) permiten ingresar un valor de **8 bits**, el cual se envía mediante UART al presionar el botón `KEY[0]`.  

El valor también se muestra en **tres displays de 7 segmentos**.

```verilog
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
```

---

## receiver.v

Este módulo implementa el **receptor UART en la FPGA**.  
Recibe los datos seriales desde `GPIO[0]`, los reconstruye usando el módulo `UART_RX` y posteriormente muestra el valor recibido en **tres displays de 7 segmentos**.

```verilog
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
```

---

## UART_tb.v

El **testbench** verifica el funcionamiento del sistema UART conectando directamente el transmisor con el receptor.  
Se generan datos aleatorios, se transmiten y posteriormente se verifica que el receptor reciba correctamente la misma información.

```verilog
module UART_tb ();

    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg start;

    wire busy;
    wire UART_wire;

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
        #10 clk = ~clk;

    initial
        begin
            $display("Simulación iniciada");

            #30;

            rst = 1;
            #10;
            rst = 0;

            #20000;

            repeat(10)
                begin
                    data_in = $random % 256;
                    start = 1;
                    #20;
                    start = 0;

                    @(posedge data_ready);
                    #10;

                    $display("Dato transmitido: %h, Dato recibido: %h", data_in, data_out);

                    wait(busy == 0);
                    #100;
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
```

---

## Testbench

![Testbench](UART_tb.png)

---

## Simulación del testbench

![Simulación](UART_SIM.png)

---

## Prueba en la tarjeta FPGA

[Ver video de la prueba](UART.mp4)
