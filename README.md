# Práctica 1: Detector de Números Primos

## Num_Primos.v

El módulo recibe el valor de los 4 switches de la FPGA y determina si el número binario corresponde a un número primo.  
Si el número es primo, el LED se enciende; en caso contrario, el LED permanece apagado.

```verilog
module Num_Primos (

	input [3:0] SW,
	output reg LED
	
);
	
	always @(*)
		begin
			case (SW)	
		    	4'b0010:LED = 1'b1;	// Estos son los números primos definidos del 2 al 13 y tienen como salida el 1 y se prende el LED
				4'b0011:LED = 1'b1;
				4'b0101:LED = 1'b1;
				4'b0111:LED = 1'b1;
				4'b1011:LED = 1'b1;
				4'b1101:LED = 1'b1;
				default:LED = 1'b0;	// El default es para que los números sin definir tengan como salida el 0 y se apague el LED
			endcase
		end

endmodule
```

---

## Código del testbench: Num_Primos_tb.v

El testbench genera valores de entrada del 0 al 15 para verificar el funcionamiento del sistema durante la simulación.

```verilog
module Num_Primos_tb();

    reg [3:0] SW;
    wire LED;

    Num_Primos dut(.SW(SW),.LED(LED));

    initial 
        begin
            $display("Simulacion iniciada");

            SW = 4'b0000; #10;
            SW = 4'b0001; #10;
            SW = 4'b0010; #10;
            SW = 4'b0011; #10;
            SW = 4'b0100; #10;
            SW = 4'b0101; #10;
            SW = 4'b0110; #10;
            SW = 4'b0111; #10;
            SW = 4'b1000; #10;
            SW = 4'b1001; #10;
            SW = 4'b1010; #10;
            SW = 4'b1011; #10;
            SW = 4'b1100; #10;
            SW = 4'b1101; #10;
            SW = 4'b1110; #10;
            SW = 4'b1111; #10;

            $display("Simulacion finalizada");
            $finish;
        end

    initial 
        begin
            $monitor("SW = %b, LED = %b", SW, LED);
        end

    initial 
        begin
            $dumpfile("Num_Primos_tb.vcd");
            $dumpvars(0, Num_Primos_tb);
        end

endmodule
```

---

## Testbench

![Testbench](Practica_1_Numeros_Primos/Num_Primos_tb.png)

---

## Simulación del testbench

![Simulación](Practica_1_Numeros_Primos/Num_Primos_SIM.png)

---

## RTL

![RTL](Practica_1_Numeros_Primos/Num_Primos_RTL.png)

---

## Pruebas con la tarjeta FPGA DE10-Lite

### Pruebas con números primos (LED encendido)

#### Entrada = 2 (0010)
![Prueba 2](Practica_1_Numeros_Primos/Num_Primos(2).jpeg)

#### Entrada = 3 (0011)
![Prueba 3](Practica_1_Numeros_Primos/Num_Primos(3).jpeg)

En ambos casos el LED se enciende porque los valores de entrada son números primos.

---

### Pruebas con números no primos (LED apagado)

#### Entrada = 6 (0110)
![Prueba 6](Practica_1_Numeros_Primos/Num_Primos(6).jpeg)

#### Entrada = 15 (1111)
![Prueba 15](Practica_1_Numeros_Primos/Num_Primos(15).jpeg)

En estos casos el LED no se enciende porque los valores de entrada no son números primos.

---

# Práctica 2: BCD

## BCD_4Displays_W.v

El módulo wrapper conecta las entradas de los switches de la FPGA con el módulo principal `BCD_4Displays` y envía las salidas a los displays de 7 segmentos.

```verilog
module BCD_4Displays_W (

    input  [9:0] SW,
    output [6:0] HEX0, HEX1, HEX2, HEX3
    
);

    BCD_4Displays WRAP (
        .bcd_in(SW), 
        .D_un(HEX0), 
        .D_de(HEX1), 
        .D_ce(HEX2), 
        .D_mi(HEX3)
    );

endmodule
```

---

## BCD_Module.v

Este módulo convierte un dígito BCD (0–9) a su representación en display de 7 segmentos.

```verilog
module BCD_module (

	input  [3:0] bcd_in,
	output reg [6:0] bcd_out

);

	always @(*) 
		begin
			case (bcd_in)
				4'b0000:bcd_out = ~7'b1111110;
				4'b0001:bcd_out = ~7'b0110000;
				4'b0010:bcd_out = ~7'b1101101;
				4'b0011:bcd_out = ~7'b1111001;
				4'b0100:bcd_out = ~7'b0110011;
				4'b0101:bcd_out = ~7'b1011011;
				4'b0110:bcd_out = ~7'b1011111;
				4'b0111:bcd_out = ~7'b1110000;
				4'b1000:bcd_out = ~7'b1111111;
				4'b1001:bcd_out = ~7'b1111011;
				default:bcd_out = ~7'b0000000;
			endcase
		end
	
endmodule
```

---

## BCD_Module_tb.v

El testbench genera valores aleatorios para verificar el funcionamiento del módulo durante la simulación.

```verilog
module BCD_module_tb();

    reg [3:0] bcd_in;
    wire [6:0] bcd_out;

    BCD_module dut(
        .bcd_in(bcd_in), 
        .bcd_out(bcd_out)
    );

    initial 
        begin
            repeat (32) // 32 es el número de iteraciones de las repeticiones
            begin
                bcd_in = $random % 16; #10; // $random es para generar un número aleatorio y el % 16 es para dividir el número entre 16 y nos daría un número menor que 16
            end
                $finish;
        end

    initial 
        begin
            $monitor("bcd_in = %b, bcd_out = %b", bcd_in, bcd_out);
        end

    initial 
        begin
            $dumpfile("BCD_module_tb.vcd");
            $dumpvars(0, BCD_module_tb);
        end

endmodule
```

---

## Testbench

![Testbench](Practica_2_BCD/BCD_Module_tb.png)

---

## Simulación del testbench

![Simulación](Practica_2_BCD/BCD_Module_tb_SIM.png)

---

## RTL

![RTL](Practica_2_BCD/BCD_Module_RTL.png)

---

## BCD_4Displays.v

El módulo principal recibe un número binario de 10 bits y lo separa en unidades, decenas, centenas y millares.  
Cada dígito es convertido a su representación para display de 7 segmentos mediante el módulo `BCD_module`.

```verilog
module BCD_4Displays #(parameter N_in = 10, N_out = 7) (

    input [N_in - 1:0] bcd_in,
    output [N_out - 1:0] D_un, D_de, D_ce, D_mi,
    output [3:0] unidades, decenas, centenas, millares
    
);

    assign unidades = bcd_in % 10;
    assign decenas = (bcd_in / 10) % 10;
    assign centenas = (bcd_in / 100) % 10;
    assign millares = (bcd_in / 1000) % 10;

    BCD_module Unidades (
        .bcd_in(unidades), 
        .bcd_out(D_un)
    );

    BCD_module Decenas (
        .bcd_in(decenas), 
        .bcd_out(D_de)
    );

    BCD_module Centenas (
        .bcd_in(centenas), 
        .bcd_out(D_ce)
    );

    BCD_module Millares (
        .bcd_in(millares), 
        .bcd_out(D_mi)
    );

endmodule
```

---

## BCD_4Displays_tb.v

El testbench genera valores entre 0 y 1023 para verificar la correcta separación de los dígitos y su conversión.

```verilog
module BCD_4Displays_tb();

    reg  [9:0] bcd_in;
    wire [6:0] D_un, D_de, D_ce, D_mi;
    wire [3:0] unidades, decenas, centenas, millares;

    BCD_4Displays dut(
        .bcd_in(bcd_in), 
        .D_un(D_un), 
        .D_de(D_de), 
        .D_ce(D_ce), 
        .D_mi(D_mi), 
        .unidades(unidades), 
        .decenas(decenas), 
        .centenas(centenas), 
        .millares(millares)
    );

    initial 
        begin
            repeat (10)
            begin
                bcd_in = $random % 1024; #10;
            end
                $finish;
        end

    initial 
        begin
            $monitor("bcd_in = %d, Unidades = %d, Decenas = %d, Centenas = %d, Millares = %d", bcd_in, unidades, decenas, centenas, millares);
        end

    initial 
        begin
            $dumpfile("BCD_4Displays_tb.vcd");
            $dumpvars(0, BCD_4Displays_tb);
        end
        
endmodule
```

---

## Testbench

![Testbench](Practica_2_BCD/BCD_4Displays_tb.png)

---

## Simulación del testbench

![Simulación](Practica_2_BCD/BCD_4Displays_tb_SIM.png)

---

## RTL

![RTL](Practica_2_BCD/BCD_4Displays_RTL.png)

---

## Pruebas con la tarjeta FPGA DE10-Lite

[Ver video de la prueba](Practica_2_BCD/BCD_4Displays.mp4)

---

# Práctica 3: Contador Ascendente y Descendente con Load y Reset

## BCD_module.v

Este módulo convierte un dígito BCD (0–9) a su representación en display de 7 segmentos.

```verilog
module BCD_module (

	input  [3:0] bcd_in,
	output reg [6:0] bcd_out

);

	always @(*) 
		begin
			case (bcd_in)
				4'b0000:bcd_out = ~7'b1111110;
				4'b0001:bcd_out = ~7'b0110000;
				4'b0010:bcd_out = ~7'b1101101;
				4'b0011:bcd_out = ~7'b1111001;
				4'b0100:bcd_out = ~7'b0110011;
				4'b0101:bcd_out = ~7'b1011011;
				4'b0110:bcd_out = ~7'b1011111;
				4'b0111:bcd_out = ~7'b1110000;
				4'b1000:bcd_out = ~7'b1111111;
				4'b1001:bcd_out = ~7'b1111011;
				default:bcd_out = ~7'b0000000;
			endcase
		end
	
endmodule
```

---

## BCD_4Displays.v

El módulo recibe el valor del contador y lo separa en unidades, decenas, centenas y millares para mostrarlos en los displays.

```verilog
module BCD_4Displays #(parameter N_in = 14, N_out = 7) (

    input [N_in - 1:0] bcd_in,
    output [N_out - 1:0] D_un, D_de, D_ce, D_mi,
    output [3:0] unidades, decenas, centenas, millares
    
);

    assign unidades = bcd_in % 10;
    assign decenas = (bcd_in / 10) % 10;
    assign centenas = (bcd_in / 100) % 10;
    assign millares = (bcd_in / 1000) % 10;

    BCD_module Unidades (
        .bcd_in(unidades), 
        .bcd_out(D_un)
    );

    BCD_module Decenas (
        .bcd_in(decenas), 
        .bcd_out(D_de)
    );

    BCD_module Centenas (
        .bcd_in(centenas), 
        .bcd_out(D_ce)
    );

    BCD_module Millares (
        .bcd_in(millares), 
        .bcd_out(D_mi)
    );

endmodule
```

---

## counter_wr.v

El módulo wrapper conecta los botones, switches y reloj de la FPGA con el sistema del contador.  
Incluye divisor de frecuencia, contador y módulo de visualización en displays de 7 segmentos.

```verilog
module counter_wr (

    input MAX10_CLK1_50,
    input [1:0] KEY,
    input [13:0] SW,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3

);

    wire rst;
    wire load;
    wire up_down;
    wire slow_clk;
    wire [13:0] data_in;
    wire [13:0] count_value;

    assign rst = ~KEY[0];
    assign load = ~KEY[1];
    assign up_down = SW[13];
    assign data_in = SW;

    clock_divider #(.FREQ(1)) clk_div (
        .clk(MAX10_CLK1_50), 
        .rst(rst), 
        .clk_div(slow_clk)
    );

    counter #(.CMAX(100)) counter (
        .clk(slow_clk), 
        .rst(rst), 
        .load(load), 
        .up_down(up_down), 
        .data_in(data_in), 
        .count(count_value)
    );

    BCD_4Displays display (
        .bcd_in(count_value), 
        .D_un(HEX0), 
        .D_de(HEX1), 
        .D_ce(HEX2), 
        .D_mi(HEX3)
    );

endmodule
```

---

## clock_divider.v

El módulo divisor de frecuencia reduce la señal de 50 MHz de la FPGA a una frecuencia más baja para poder visualizar el conteo en los displays.

```verilog
module clock_divider #(parameter FREQ = 1) (

    input clk,
    input rst,
    output reg clk_div

);

    parameter CLK_FREQ = 50000000;
    parameter COUNT_MAX = (CLK_FREQ / (2 * FREQ));

    reg [31:0] count;

    always @(posedge clk)
        begin
            if (rst == 1'b1)
                begin
                    count <= 32'b0;
                end
            else if (count == COUNT_MAX - 1)
                begin
                    count <= 32'b0;
                end
            else
                begin
                    count <= count + 1;
                end
        end

    always @(posedge clk)
        begin
            if (rst == 1'b1)
                begin
                    clk_div <= 1'b0;
                end
            else if (count == COUNT_MAX - 1)
                begin
                    clk_div <= ~clk_div;
                end
        end

endmodule
```

---

## counter.v

El módulo contador permite contar de manera ascendente o descendente dependiendo del switch `up_down`.  
Incluye botón de `reset` para reiniciar a 0 y botón `load` para cargar un valor inicial.

```verilog
module counter #(parameter CMAX = 100) (

    input clk,
    input rst,
    input load,
    input up_down,
    input [13:0] data_in,
    output reg [13:0] count

);

    always @(posedge clk)
        begin
            if (rst)
                begin
                    count <= 0;
                end
            else if (load)
                begin
                    count <= data_in;
                end
            else if (up_down)
                begin
                    if (count == CMAX)
                        count <= 0;
                    else
                        count <= count + 1;
                end
            else
                begin
                    if (count == 0)
                        count <= CMAX;
                    else
                        count <= count - 1;
                end
        end

endmodule
```

---

## counter_tb.v

El testbench verifica el funcionamiento del contador probando reset, conteo ascendente, descendente y carga de datos.

```verilog
module counter_tb();

    reg clk;
    reg rst;
    reg load;
    reg up_down;
    reg [13:0] data_in;
    wire [13:0] count;

    counter #(.CMAX(100)) dut(
        .clk(clk),
        .rst(rst),
        .load(load),
        .up_down(up_down),
        .data_in(data_in),
        .count(count)
    );

    initial 
        begin
            clk = 0;
            forever #10 clk = ~clk;
        end

    initial 
        begin
            $display("Reset");
            rst = 1; load = 0; up_down = 1; data_in = 0; #50;
            rst = 0;

            $display("Subiendo");
            #200;

            $display("Bajando");
            up_down = 0;
            #300;

            $display("Load con el valor 8");
            load = 1; data_in = 14'd8; #50;
            load = 0;

            $display("Subiendo");
            up_down = 1;
            #100;

            $display("Reset");
            rst = 1; #50;

            $stop;
            $finish;
        end

    initial 
        begin
            $monitor("rst = %b, load = %b | up_down = %b | count = %d", rst, load, up_down, count);
        end

    initial 
        begin
            $dumpfile("counter_tb.vcd");
            $dumpvars(0, counter_tb);
        end

endmodule
```

---

## Testbench

![Testbench](Practica_3_Contador_Sincrono/Counter_tb.png)

---

## Simulación del testbench

![Simulación](Practica_3_Contador_Sincrono/Counter_SIM.png)

---

## RTL

![RTL](Practica_3_Contador_Sincrono/Counter_RTL.png)

---

# Práctica 4: Sistema de Password con Máquina de Estados

## BCD_module.v

Este módulo convierte un dígito BCD (0–9) a su representación en display de 7 segmentos.

```verilog
module BCD_module (

	input  [3:0] bcd_in,
	output reg [6:0] bcd_out

);

	always @(*) 
		begin
			case (bcd_in)
				4'b0000:bcd_out = ~7'b1111110;
				4'b0001:bcd_out = ~7'b0110000;
				4'b0010:bcd_out = ~7'b1101101;
				4'b0011:bcd_out = ~7'b1111001;
				4'b0100:bcd_out = ~7'b0110011;
				4'b0101:bcd_out = ~7'b1011011;
				4'b0110:bcd_out = ~7'b1011111;
				4'b0111:bcd_out = ~7'b1110000;
				4'b1000:bcd_out = ~7'b1111111;
				4'b1001:bcd_out = ~7'b1111011;
				default:bcd_out = ~7'b0000000;
			endcase
		end
	
endmodule
```

---

## password_wr.v

El módulo wrapper conecta los botones, switches y reloj de la FPGA con el sistema del password.

```verilog
module password_wr (

    input MAX10_CLK1_50,
    input [9:0] SW,
    input [1:0] KEY,

    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX3

);

    password dut (

        .clk(MAX10_CLK1_50),
        .rst(~KEY[0]),
        .load(~KEY[1]),
        .SW(SW[3:0]),

        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)

    );

endmodule
```

---

## password.v

Este módulo implementa el sistema de contraseña utilizando una **máquina de estados finitos (FSM)**.

```verilog
module password (

    input clk,
    input rst,
    input load,
    input [3:0] SW,

    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3

);

    parameter [15:0] password = 16'h1234;

    parameter IDLE = 3'd0,
              S1   = 3'd1,
              S2   = 3'd2,
              S3   = 3'd3,
              GOOD = 3'd4,
              BAD  = 3'd5;

    reg [2:0] state, next_state;

    reg load_sync0, load_sync1;
    wire load_pulse;

    wire [6:0] bcd_out;

    BCD_module bcd_inst (
        .bcd_in(SW),
        .bcd_out(bcd_out)
    );

    always @(posedge clk)
		begin
			load_sync0 <= load;
			load_sync1 <= load_sync0;
		end

    assign load_pulse = load_sync0 & ~load_sync1;

    always @(posedge clk or posedge rst)
		begin
			if (rst)
				state <= IDLE;
			else
				state <= next_state;
		end

    always @(*)
		begin
			next_state = state;

			case (state)

				IDLE:
					if (load_pulse)
						if (SW == password[15:12])
							next_state = S1;
						else
							next_state = BAD;

				S1:
					if (load_pulse)
						if (SW == password[11:8])
							next_state = S2;
						else
							next_state = BAD;

				S2:
					if (load_pulse)
						if (SW == password[7:4])
							next_state = S3;
						else
							next_state = BAD;

				S3:
					if (load_pulse)
						if (SW == password[3:0])
							next_state = GOOD;
						else
							next_state = BAD;

				GOOD:
					next_state = GOOD;

				BAD:
					next_state = BAD;

			endcase
		end

    always @(*)
		begin
			HEX0 = 7'b1111111;
			HEX1 = 7'b1111111;
			HEX2 = 7'b1111111;
			HEX3 = 7'b1111111;

			case (state)

				IDLE, S1, S2, S3:
					HEX0 = bcd_out;

				GOOD:
				begin
					HEX3 = ~7'b0111101; // G
					HEX2 = ~7'b1111110; // O
					HEX1 = ~7'b1111110; // O
					HEX0 = ~7'b0111101; // d
				end

				BAD:
				begin
					HEX3 = ~7'b0011111; // b
					HEX2 = ~7'b1110111; // A
					HEX1 = ~7'b0111101; // D
					HEX0 = 7'b1111111;  // Display apagado
				end

			endcase
		end

endmodule
```

---

## password_tb.v

El testbench verifica el funcionamiento del sistema probando una contraseña correcta e incorrecta.

```verilog
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
```

---

## Testbench

![Testbench](Password_tb.png)

---

## Simulación del testbench

![Simulación](Password_SIM.png)

---

## RTL

![RTL](Password_RTL.png)

---

## Máquina de Estados (FSM)

![State Machine](Password_SM.png)

---

## Prueba en la tarjeta FPGA

[Ver video de la prueba](Password.mp4)


## Prueba en la tarjeta FPGA

[Ver video de la prueba](Practica_3_Contador_Sincrono/Counter.mp4)
