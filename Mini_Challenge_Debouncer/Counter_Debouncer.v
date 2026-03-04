module counter_debouncer (

    input clk,
    input rst,
    input pulso,
    output reg [9:0] leds

);

    always @(posedge clk or posedge rst)
        begin
            if (rst)
                leds <= 0;
            else
                if (pulso)
                    leds <= leds + 1;
        end
endmodule
