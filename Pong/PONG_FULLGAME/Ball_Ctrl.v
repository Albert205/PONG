module Ball_Ctrl
#(parameter VIDEO_WIDTH = 3,
parameter HMAX = 800,
parameter VMAX = 525,
parameter HDISPLAY = 640,
parameter VDISPLAY = 480,
parameter WIDTH = 40,
parameter HEIGHT = 30,
parameter PIXEL_SIZE = 16,
parameter PADDLE_1_H_POS = 5,
parameter H_INIT = 7, //Initial X position when ball is "served"
parameter V_INIT = 15, //Initial Y position when ball is "served"
parameter TOP_POS_MIN = 1, //Upper boundary
parameter BOT_POS_MAX = 30, //Lower boundary
parameter LEFT_BOUND = 1, //If X position of the ball is equal to this, the ball is out of bounds
parameter MOVE_SPEED = 1250000,
parameter PAUSE_TIME = 25000000 //Pause for 1 second between when the ball goes out of bounds and when we reset to start, and when we reset the game for the next round
)

(input i_Clk,
input [$clog2(HMAX)-1:0] i_H_count,
input [$clog2(VMAX)-1:0] i_V_count,
input [$clog2(HEIGHT)-1:0] i_Paddle_Pos_Left,
input [$clog2(HEIGHT)-1:0] i_Paddle_Pos_Right,
input i_Reset,
input i_Ready,
output o_Draw_Ball,
output o_Out,
output o_Start_Play);

    reg r_Wait_done_1;
    assign o_Start_Play = r_Wait_done_1;
    reg r_Wait_done_2;
    assign o_Out = r_Wait_done_2;
    reg [$clog2(MOVE_SPEED)-1:0] r_Clock_count_mvmt;
    reg [$clog2(PAUSE_TIME)-1:0] r_Clock_count_pause;

    reg [$clog2(WIDTH)-1:0] r_H_pos;
    reg [$clog2(HEIGHT)-1:0] r_V_pos;

    reg [1:0] r_Prev_Direction;

    reg r_Out = 1'b0;
    

    reg r_Draw_Ball = 1'b0;
    assign o_Draw_Ball = r_Draw_Ball;

    localparam RESET = 0;
    localparam START = 1;
    localparam MOVING = 2;
    localparam WAIT = 3;
    localparam OUT = 4;

    reg [2:0] ps = 3'b0, ns;

    always @(posedge i_Clk) begin
        if(i_Reset)
            ps <= RESET;
        else
            ps <= ns;
    end

    always @(*) begin
        case(ps)
            RESET: ns = i_Ready ? START : RESET;
            START: ns = r_Wait_done_1 ? MOVING : START;
            MOVING: ns = r_Out ? OUT : WAIT;
            WAIT: ns = r_Wait_done_1 ? MOVING : WAIT;
            OUT: ns = r_Wait_done_2 ? START : OUT;
        endcase
    end

    //Always block for control signals, updating position
    always @(posedge i_Clk) begin
        if(ps == RESET) begin
            r_H_pos <= H_INIT;
            r_V_pos <= V_INIT;
            r_Clock_count_pause <= 0;
            r_Wait_done_1 <= 1'b0;
            r_Wait_done_2 <= 1'b0;
        end else if(ps == START) begin           
            if(r_Clock_count_pause < PAUSE_TIME - 1) begin
                r_Clock_count_pause <= r_Clock_count_pause + 1;
            end else if (r_Clock_count_pause == PAUSE_TIME - 1) begin
                r_Clock_count_pause <= 0;
                r_Wait_done_1 <= 1'b1;
            end

            r_H_pos <= H_INIT;
            r_V_pos <= V_INIT;

            r_Wait_done_2 <= 1'b0;
            r_Prev_Direction <= 2'b01;
            r_Out <= 1'b0;

            r_Clock_count_mvmt <= 0;

        end else if(ps == MOVING) begin
            r_Wait_done_1 <= 1'b0;
            //check if ball is OUT on left side
            if(r_H_pos < 6) begin
                r_Out <= 1'b1;
            end
            //Collision across the front of the left paddle 
            else if(r_H_pos == 6 && r_V_pos > i_Paddle_Pos_Left - 4 && r_V_pos < i_Paddle_Pos_Left + 4) begin
                if(r_V_pos == 1) begin
                    r_Prev_Direction <= 2'b11;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos + 1;
                end else if (r_V_pos == 30) begin
                    r_Prev_Direction <= 2'b01;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos - 1;
                end else begin
                    if(r_Prev_Direction == 2'b00) begin
                        r_Prev_Direction <= 2'b01;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos - 1;
                    end else if(r_Prev_Direction == 2'b10) begin
                        r_Prev_Direction <= 2'b11;
                        r_H_pos <= r_H_pos + 1;                       
                        r_V_pos <= r_V_pos + 1;
                    end
                end
            end
            //Collision at top right corner of the left paddle 
            else if(r_H_pos == 6 && r_V_pos == i_Paddle_Pos_Left - 4) begin
                if(r_V_pos == 1) begin
                    r_Prev_Direction <= 2'b11;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos + 1;
                end else begin
                    if(r_Prev_Direction == 2'b10) begin
                        r_Prev_Direction <= 2'b01;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos - 1;
                    end else if(r_Prev_Direction == 2'b00) begin
                        r_Prev_Direction <= 2'b00;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos - 1;
                    end
                end
            end
            //Collision at bottom right corner of the left paddle
            else if(r_H_pos == 6 && r_V_pos == i_Paddle_Pos_Left + 4) begin
                if(r_V_pos == 30) begin
                    r_Prev_Direction <= 2'b01;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos - 1;
                end else begin
                    if(r_Prev_Direction == 2'b00) begin
                        r_Prev_Direction <= 2'b11;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos + 1;
                    end else if(r_Prev_Direction == 2'b10) begin
                        r_Prev_Direction <= 2'b10;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos + 1;
                    end
                end
            end
            //Check if the ball is OUT on the left boundary
            else if(r_H_pos > 35) begin
                r_Out <= 1'b1;
            end
            //Collision with the front of the right paddle
            else if(r_H_pos == 35 && r_V_pos > i_Paddle_Pos_Right - 4 && r_V_pos < i_Paddle_Pos_Right + 4) begin
                if(r_V_pos == 1) begin
                    r_Prev_Direction <= 2'b10;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos + 1;
                end else if(r_V_pos == 30) begin
                    r_Prev_Direction <= 2'b00;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos - 1;
                end else begin
                    if(r_Prev_Direction == 2'b01) begin
                        r_Prev_Direction <= 2'b00;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos - 1;
                    end else if(r_Prev_Direction <= 2'b11) begin
                        r_Prev_Direction <= 2'b10;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos + 1;
                    end
                end
            end
            //Collision with top left corner of the right paddle
            else if(r_H_pos == 35 && r_V_pos == i_Paddle_Pos_Right - 4) begin
                if(r_V_pos == 1) begin
                    r_Prev_Direction <= 2'b10;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos + 1;
                end else begin
                    if(r_Prev_Direction == 2'b11) begin
                        r_Prev_Direction <= 2'b00;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos - 1;
                    end else if(r_Prev_Direction == 2'b01) begin
                        r_Prev_Direction <= 2'b01;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos - 1;
                    end
                end
            end
            //Collision with bottom left corner of the right paddle
            else if(r_H_pos == 35 && r_V_pos == i_Paddle_Pos_Right + 4) begin
                if(r_V_pos == 30) begin
                    r_Prev_Direction <= 2'b00;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos - 1;
                end else begin
                    if(r_Prev_Direction == 2'b01) begin
                        r_Prev_Direction <= 2'b10;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos + 1;
                    end else if(r_Prev_Direction == 2'b11) begin
                        r_Prev_Direction <= 2'b11;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos + 1;
                    end
                end
            end
            //Check if we hit the top boundary 
            else if(r_V_pos == 1) begin
                if(r_Prev_Direction == 2'b00) begin
                    r_Prev_Direction <= 2'b10;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos + 1;
                end else if(r_Prev_Direction == 2'b01) begin
                    r_Prev_Direction <= 2'b11;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos + 1;
                end
            end
            //Check if we hit the bottom boundary (no corners)
            else if(r_V_pos == 30) begin
                if(r_Prev_Direction ==  2'b10) begin
                    r_Prev_Direction <= 2'b00;
                    r_H_pos <= r_H_pos - 1;
                    r_V_pos <= r_V_pos - 1;
                end else if(r_Prev_Direction == 2'b11) begin
                    r_Prev_Direction <= 2'b01;
                    r_H_pos <= r_H_pos + 1;
                    r_V_pos <= r_V_pos - 1;
                end
            end
            //No collision -> path of ball remains constant
            else begin
                case(r_Prev_Direction)
                    2'b00: begin
                        r_Prev_Direction <= 2'b00;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos - 1;
                    end
                    2'b01: begin
                        r_Prev_Direction <= 2'b01;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos - 1;
                    end
                    2'b10: begin
                        r_Prev_Direction <= 2'b10;
                        r_H_pos <= r_H_pos - 1;
                        r_V_pos <= r_V_pos + 1;
                    end
                    2'b11: begin
                        r_Prev_Direction <= 2'b11;
                        r_H_pos <= r_H_pos + 1;
                        r_V_pos <= r_V_pos + 1;
                    end
                endcase
            end
        end else if(ps == WAIT) begin
            if(r_Clock_count_mvmt < MOVE_SPEED - 1) begin
                r_Clock_count_mvmt <= r_Clock_count_mvmt + 1;
            end else if(r_Clock_count_mvmt == MOVE_SPEED -1) begin
                r_Clock_count_mvmt <= 0;
                r_Wait_done_1 <= 1'b1;
            end
        end else if(ps == OUT) begin
            if(r_Clock_count_pause < PAUSE_TIME - 1) begin
                r_Clock_count_pause <= r_Clock_count_pause + 1;
            end else if (r_Clock_count_pause == PAUSE_TIME - 1) begin
                r_Clock_count_pause <= 0;
                r_Wait_done_2 <= 1'b1;
            end
        end
    end

    always @(posedge i_Clk) begin
        if(ps == RESET) begin
            r_Draw_Ball <= 1'b0;
        end else if(ps == START || ps == MOVING || ps == WAIT || ps == OUT) begin            
             if(i_H_count < r_H_pos * PIXEL_SIZE && i_H_count > (r_H_pos -1) * PIXEL_SIZE && i_V_count < r_V_pos * PIXEL_SIZE && i_V_count > (r_V_pos - 1) * PIXEL_SIZE) begin
                r_Draw_Ball <= 1'b1;
            end else begin
                r_Draw_Ball <= 1'b0;
            end
        end
    end

endmodule
