module password (

    input clk,
    input rst,
    input next,
    input [3:0] switch,

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

    reg next_d;
    wire next_edge;

    always @(posedge clk)
        next_d <= next;

    assign next_edge = next & ~next_d;

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
                    if (next_edge)
                        if (switch == password[15:12])
                            next_state = S1;
                        else
                            next_state = BAD;

                S1:
                    if (next_edge)
                        if (switch == password[11:8])
                            next_state = S2;
                        else
                            next_state = BAD;

                S2:
                    if (next_edge)
                        if (switch == password[7:4])
                            next_state = S3;
                        else
                            next_state = BAD;

                S3:
                    if (next_edge)
                        if (switch == password[3:0])
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

                GOOD:
                begin
                    HEX3 = 7'b1000010; // G
                    HEX2 = 7'b1000000; // O
                    HEX1 = 7'b1000000; // O
                    HEX0 = 7'b0100001; // D
                end

                BAD:
                begin
                    HEX3 = 7'b0000011; // b
                    HEX2 = 7'b0001000; // A
                    HEX1 = 7'b0100001; // d
                    HEX0 = 7'b1111111; // Apagado
                end
            endcase
        end

endmodule
