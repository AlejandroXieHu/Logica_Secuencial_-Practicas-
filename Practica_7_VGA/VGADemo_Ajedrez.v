module VGADemo_Ajedrez (

    input MAX10_CLK1_50,

    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,

    output hsync_out,
    output vsync_out

);

    wire inDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;

    // Generador de 25 MHz
    reg pixel_tick = 0;

    always @(posedge MAX10_CLK1_50)
        begin
            pixel_tick <= ~pixel_tick;
        end

    hvsync_generator hvsync (

        .clk(MAX10_CLK1_50),
        .pixel_tick(pixel_tick),
        .vga_h_sync(hsync_out),
        .vga_v_sync(vsync_out),
        .CounterX(CounterX),
        .CounterY(CounterY),
        .inDisplayArea(inDisplayArea)

    );

    // Lógica del patrón tipo ajedrez
    wire is_white;

    assign is_white = CounterX[6] ^ CounterY[6];

    assign vga_red   = (inDisplayArea && is_white) ? 4'b1111 : 4'b0000;
    assign vga_green = (inDisplayArea && is_white) ? 4'b1111 : 4'b0000;
    assign vga_blue  = (inDisplayArea && is_white) ? 4'b1111 : 4'b0000;

endmodule
