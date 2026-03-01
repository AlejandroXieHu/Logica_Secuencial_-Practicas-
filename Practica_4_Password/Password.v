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
						 HEX0 = 7'b1111111; // Display apagado
					end

			  endcase
		 end

endmodule
