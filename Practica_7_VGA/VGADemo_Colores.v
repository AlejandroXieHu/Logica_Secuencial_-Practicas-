module VGADemo_Colores (

    input MAX10_CLK1_50,
    output reg [2:0] pixel,
    output hsync_out,
    output vsync_out

);

    wire inDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;

    reg pixel_tick = 0;

    always @(posedge MAX10_CLK1_50)
        pixel_tick <= ~pixel_tick;

    hvsync_generator hvsync (
        .clk(MAX10_CLK1_50),
        .pixel_tick(pixel_tick),
        .vga_h_sync(hsync_out),
        .vga_v_sync(vsync_out),
        .CounterX(CounterX),
        .CounterY(CounterY),
        .inDisplayArea(inDisplayArea)
    ); 

    always @(posedge MAX10_CLK1_50)
        begin
            if (inDisplayArea)
                pixel <= CounterX[9:6];
            else
                pixel <= 3'b000;
        end
        
endmodule
