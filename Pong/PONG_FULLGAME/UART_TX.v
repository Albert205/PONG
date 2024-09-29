module UART_TX 
#(parameter BIT_PERIOD = 217)
(
    input i_Clk,
    input i_TX_DV,
    input [7:0] i_TX_Byte,
    output reg o_TX_Active,
    output reg o_TX_Serial,
    output reg o_TX_Done
);

    parameter IDLE = 0, START = 1, WAIT_1 = 2, SEND_DATA = 3, STOP = 4, WAIT_2 = 5, CLEAN_UP = 6;

    reg [$clog2(BIT_PERIOD)-1:0] r_clock_count;
    reg [3:0] r_bit_count;
    reg r_wait_done = 1'b0;
    reg [7:0] r_TX_Byte;

    reg [2:0] r_ps = 3'b0, r_ns;

    always @(posedge i_Clk) begin
        r_ps <= r_ns;
    end

    always @(*) begin
        case(r_ps)
            IDLE: r_ns = i_TX_DV ? START : IDLE;
            START: r_ns = WAIT_1;
            WAIT_1: r_ns = r_wait_done ? ((r_bit_count < 8) ? SEND_DATA : STOP) : WAIT_1;
            SEND_DATA: r_ns = WAIT_1;
            STOP: r_ns = WAIT_2;
            WAIT_2: r_ns = r_wait_done ? CLEAN_UP : WAIT_2;
            CLEAN_UP: r_ns = IDLE;
            default: r_ns = IDLE;
        endcase
    end

    always @(posedge i_Clk) begin
        if(r_ps == IDLE) begin
            r_bit_count <= 3'b0;
            r_clock_count <= 0;
            o_TX_Done <= 1'b0;
        end else if (r_ps == START) begin
            o_TX_Active <= 1'b1;
            o_TX_Serial <= 1'b0;
            r_TX_Byte <= i_TX_Byte;
        end else if (r_ps == WAIT_1 || r_ps == WAIT_2) begin
            if(r_clock_count < BIT_PERIOD - 1) begin
                r_clock_count <= r_clock_count + 1;
                r_wait_done <= 1'b0;
            end else if (r_clock_count == BIT_PERIOD - 1) begin
                r_clock_count <= 0;
                r_wait_done <= 1'b1;
            end
        end else if (r_ps == SEND_DATA) begin
            o_TX_Serial <= r_TX_Byte[r_bit_count];
            r_bit_count <= r_bit_count + 1;
            r_wait_done <= 1'b0;
        end else if (r_ps == STOP) begin
            o_TX_Serial <= 1'b1;
            r_wait_done <= 1'b0;
        end else if (r_ps == CLEAN_UP) begin
            o_TX_Active <= 1'b0;
            o_TX_Done <= 1'b1;
        end
    end

endmodule
        
