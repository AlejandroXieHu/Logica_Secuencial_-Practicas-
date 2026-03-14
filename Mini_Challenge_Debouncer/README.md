# Mini Challenge 1: Debouncer

## debouncer_wr.v

Este módulo funciona como **wrapper del sistema de debouncing**.  
Conecta los botones (`KEY`), el reloj de la FPGA y los módulos internos encargados de limpiar la señal del botón, detectar el flanco de subida y contar las pulsaciones.

El valor del contador se muestra tanto en los **LEDs de la tarjeta** como en **cuatro displays de 7 segmentos**.

```verilog
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
```

---

## debouncer.v

Este módulo implementa el **debouncer**, cuya función es eliminar el rebote mecánico de los botones.  

Cuando se detecta un cambio en la entrada `boton_in`, se inicia un contador.  
Si el cambio se mantiene estable durante un tiempo determinado (`MAX_COUNT`), entonces la salida `boton_out` se actualiza.

```verilog
module debouncer (

    input  clk,
    input  rst,
    input  boton_in,
    output reg boton_out

);

    parameter MAX_COUNT = 1000000;

    reg [19:0] contador;

    always @(posedge clk or posedge rst)
        begin
            if (rst)
                begin
                        boton_out <= 0;
                        contador <= 0;
                end
            else
                begin
                        if (boton_in != boton_out)
                            begin
                                contador <= contador + 1;
                                if (contador == MAX_COUNT)
                                    begin
                                        boton_out <= boton_in;
                                        contador  <= 0;
                                    end
                            end
                        else
                            begin
                                contador <= 0;
                            end
                end
        end
endmodule
```

---

## edge_detector.v

Este módulo detecta el **flanco de subida** del botón ya debounced.  

Cuando la señal pasa de `0` a `1`, se genera un **pulso de un solo ciclo de reloj**, lo cual permite activar correctamente el contador.

```verilog
module edge_detector (

    input clk,
    input rst,
    input boton_out,
    output reg pulso

);
    reg boton_d;

    always @(posedge clk or posedge rst)
        begin
            if (rst)
                begin
                    boton_d <= 0;
                    pulso <= 0;
                end
            else
                begin
                    boton_d <= boton_out;
                    pulso <= boton_out & ~boton_d;
                end
        end
endmodule
```

---

## debouncer_tb.v

Este **testbench** verifica el funcionamiento del sistema completo.  
Simula varias presiones del botón y un reset para comprobar que el contador solo se incrementa una vez por cada pulsación limpia.

```verilog
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
```

---

## Testbench

![Testbench](Debouncer_tb.png)
