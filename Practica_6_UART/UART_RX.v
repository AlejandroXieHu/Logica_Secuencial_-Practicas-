module UART_RX #(parameter BAUD_RATE = 9600, parameter CLOCK_FREQ = 50000000, parameter BITS = 8) (

    input clk,
    input rst,
    input rx_in,

    output reg [BITS-1:0] data_out,
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

                                if (!rx_in) // Detecta el bit de inicio
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
