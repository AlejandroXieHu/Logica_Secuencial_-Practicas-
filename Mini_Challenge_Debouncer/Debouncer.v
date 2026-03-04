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
