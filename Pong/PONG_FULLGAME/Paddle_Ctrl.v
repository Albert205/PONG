// Code your design here
module Paddle_Ctrl
#(parameter VIDEO_WIDTH = 3,
parameter HMAX = 800,
parameter VMAX = 525,
parameter HDISPLAY = 640,
parameter VDISPLAY = 480,
parameter WIDTH = 40,
parameter HEIGHT = 30,
parameter PIXEL_SIZE = 16,
parameter H_POS = 5,
parameter V_INIT = 15,
parameter V_POS_MIN = 4,
parameter V_POS_MAX = 27,
parameter MOVE_SPEED = 1250000
)

(input i_Clk,
input [$clog2(HMAX)-1:0] i_H_count,
input [$clog2(VMAX)-1:0] i_V_count,
input i_Up_Ctrl,
input i_Down_Ctrl,
input i_Reset, //resets game to beginning screen
input i_Ready, //sets game to START state
input i_Start, //sets game to IDLE state
input i_Out, //resets game to START state
output o_Draw_Paddle,
output [$clog2(HEIGHT)-1:0] o_V_pos);

    reg r_Wait_done;
    reg [$clog2(MOVE_SPEED)-1:0] r_Clock_count;

    reg r_Next_pos = 1'b0; //0 if down, 1 if up
    reg [$clog2(HEIGHT)-1:0] r_V_pos;
    assign o_V_pos = r_V_pos;

    reg r_Draw_Paddle = 1'b0;
    assign o_Draw_Paddle = r_Draw_Paddle;

    localparam RESET = 0; //home screen of game
    localparam START = 1; //paddles and board is shown but cannot move -> wait for ball to be played
    localparam IDLE = 2; //ball is in play, can move paddles
    localparam WAIT = 3; //delay movement of the paddles (WRT input)
    localparam MOVE_UP = 4; //moving up
    localparam MOVE_DOWN = 5; //moving down

    reg [2:0] ps = 3'b0, ns;

    always @(posedge i_Clk) begin
        if(i_Reset)
            ps <= RESET;
        else if(i_Out)
            ps <= START;
        else
            ps <= ns;

        if (i_Up_Ctrl)
            r_Next_pos <= 1'b1;
        else if (i_Down_Ctrl)
            r_Next_pos <= 1'b0;

    end

    always @(*) begin
        case(ps)
            RESET: ns = i_Ready ? START : RESET;
            START: ns = i_Start ? IDLE : START;
            IDLE: ns = i_Up_Ctrl^i_Down_Ctrl ? WAIT : IDLE;
            WAIT: ns = r_Wait_done ? (r_Next_pos ? MOVE_UP : MOVE_DOWN) : WAIT;
            MOVE_DOWN: ns = IDLE;
            MOVE_UP: ns = IDLE;
        endcase
    end

    //Always block for control signals, updating position
    always @(posedge i_Clk) begin
        if(ps == RESET) begin
            r_V_pos <= V_INIT;
        end else if(ps == START) begin
            r_V_pos <= V_INIT;
        end else if (ps == IDLE) begin
            r_Clock_count <= 0;
            r_Wait_done <= 1'b0;
        end else if(ps == WAIT) begin
            if(r_Clock_count < MOVE_SPEED - 1) begin
                r_Clock_count <= r_Clock_count + 1;
            end else if(r_Clock_count == MOVE_SPEED - 1) begin
                r_Wait_done <= 1'b1;
            end
        end else if(ps == MOVE_UP) begin
            if(r_V_pos > V_POS_MIN)
                r_V_pos <= r_V_pos - 1;
        end else if(ps == MOVE_DOWN) begin
            if(r_V_pos < V_POS_MAX)
                r_V_pos <= r_V_pos + 1;
        end
    end

    //Always block for VGA control
    always @(posedge i_Clk) begin
        if (ps == RESET) begin
            // o_Red <= {VIDEO_WIDTH{1'b0}};
            // o_Green <= {VIDEO_WIDTH{1'b0}};
            // o_Blue <= {VIDEO_WIDTH{1'b0}};
            r_Draw_Paddle <= 1'b0;
        end else if (ps == START) begin
            if(i_H_count < H_POS * PIXEL_SIZE && i_H_count > (H_POS - 2) * PIXEL_SIZE && i_V_count < (V_INIT + 3)*PIXEL_SIZE && i_V_count > (V_INIT - 4)*PIXEL_SIZE) begin
                // o_Red <= {VIDEO_WIDTH{1'b1}};
                // o_Green <= {VIDEO_WIDTH{1'b1}};
                // o_Blue <= {VIDEO_WIDTH{1'b1}};
                r_Draw_Paddle <= 1'b1;
            end else begin
              	// o_Red <= {VIDEO_WIDTH{1'b0}};
              	// o_Green <= {VIDEO_WIDTH{1'b0}};
              	// o_Blue <= {VIDEO_WIDTH{1'b0}};
                r_Draw_Paddle <= 1'b0;
            end
        end else if (ps == IDLE || ps == WAIT || ps == MOVE_DOWN || ps == MOVE_UP) begin
            if(i_H_count < H_POS * PIXEL_SIZE && i_H_count > (H_POS - 2) * PIXEL_SIZE && i_V_count < (r_V_pos + 3)*PIXEL_SIZE && i_V_count > (r_V_pos - 4)*PIXEL_SIZE) begin
                // o_Red <= {VIDEO_WIDTH{1'b1}};
                // o_Green <= {VIDEO_WIDTH{1'b1}};
                // o_Blue <= {VIDEO_WIDTH{1'b1}};
                r_Draw_Paddle <= 1'b1;
            end else begin
              	// o_Red <= {VIDEO_WIDTH{1'b0}};
              	// o_Green <= {VIDEO_WIDTH{1'b0}};
              	// o_Blue <= {VIDEO_WIDTH{1'b0}};
                r_Draw_Paddle <= 1'b0;
            end
        end        
    end

endmodule





