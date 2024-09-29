module UART_RX
#(parameter BIT_PERIOD = 217)
(input i_Clk,
input i_RX_Serial,
output o_RX_DV,
output [7:0] o_RX_byte);

    parameter IDLE = 0, WAIT_HALF = 1, START = 2, WAIT_FULL = 3, GET_DATA = 4, STOP_BIT = 5, CLEAN_UP = 6;
    reg [2:0] r_ps = 3'b000, r_ns;

  	reg [3:0] r_bit_count;

    reg [$clog2(BIT_PERIOD)-1:0] r_clock_count;

    reg r_wait_done = 1'b0;

    reg [7:0] r_RX_byte;

    assign o_RX_byte = r_RX_byte;    
  assign o_RX_DV = (r_ps == STOP_BIT);

    always @(posedge i_Clk) begin
        r_ps <= r_ns;
    end

    always @(*) begin
      case(r_ps)
            IDLE: r_ns = i_RX_Serial ? IDLE : WAIT_HALF;
            WAIT_HALF: r_ns = r_wait_done ? START : WAIT_HALF;
            START: r_ns = i_RX_Serial ? IDLE : WAIT_FULL;
        WAIT_FULL: r_ns = r_wait_done ? ((r_bit_count < 8) ? GET_DATA : STOP_BIT) : WAIT_FULL;
            GET_DATA: r_ns = WAIT_FULL;
            STOP_BIT: r_ns = CLEAN_UP;
            CLEAN_UP: r_ns = IDLE;
            default: r_ns = IDLE;
        endcase
    end

    always @(posedge i_Clk) begin
        if(r_ps == IDLE) begin
            r_bit_count <= 3'b0;
            r_clock_count <= 0;
        end else if (r_ps == WAIT_HALF) begin
            if(r_clock_count < (BIT_PERIOD-1)/2) begin
                r_clock_count <= r_clock_count + 1;
                r_wait_done <= 1'b0;
            end else if (r_clock_count == (BIT_PERIOD-1)/2) begin
                r_clock_count <= 0;
                r_wait_done <= 1'b1;
            end
        end else if (r_ps == START) begin
            r_wait_done <= 1'b0;
        end else if (r_ps == WAIT_FULL) begin
            if(r_clock_count < BIT_PERIOD - 1) begin
                r_clock_count <= r_clock_count + 1;
                r_wait_done <= 1'b0;
            end else if (r_clock_count == BIT_PERIOD - 1) begin
                r_clock_count <= 0;
                r_wait_done <= 1'b1;
            end
        end else if (r_ps == GET_DATA) begin
            r_RX_byte[r_bit_count] <= i_RX_Serial;
            r_bit_count <= r_bit_count + 1;
            r_wait_done <= 1'b0;
        end
    end

endmodule

            





    