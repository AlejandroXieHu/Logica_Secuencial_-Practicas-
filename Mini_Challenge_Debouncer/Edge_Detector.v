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
