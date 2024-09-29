module Paddle_Top
(input i_Clk,

input i_Switch_1,
input i_Switch_2,
input i_Switch_3,
input i_Switch_4,

input i_UART_RX,
output o_UART_TX,

output o_Segment1_A,
output o_Segment1_B,
output o_Segment1_C,
output o_Segment1_D,
output o_Segment1_E,
output o_Segment1_F,
output o_Segment1_G,

output o_Segment2_A,
output o_Segment2_B,
output o_Segment2_C,
output o_Segment2_D,
output o_Segment2_E,
output o_Segment2_F,
output o_Segment2_G,

output o_VGA_HSync,
output o_VGA_VSync,
output o_VGA_Red_0,
output o_VGA_Red_1,
output o_VGA_Red_2,
output o_VGA_Green_0,
output o_VGA_Green_1,
output o_VGA_Green_2,
output o_VGA_Blue_0,
output o_VGA_Blue_1,
output o_VGA_Blue_2);

    localparam DEBOUNCE_LIMIT = 250000;
    localparam HMAX = 800;
    localparam VMAX = 525;
    localparam HEIGHT = 30;
    localparam VIDEO_WIDTH = 3;
    localparam BIT_PERIOD_CLKs = 217;

    wire [7:0] w_RX_Byte;
    wire w_RX_DV;
    wire w_TX_Active;
    wire w_TX_Serial;

    wire [$clog2(HMAX)-1:0] w_H_count;
    wire [$clog2(VMAX)-1:0] w_V_count;

    wire [$clog2(HEIGHT)-1:0] w_V_pos_left;
    wire [$clog2(HEIGHT)-1:0] w_V_pos_right;

    reg r_Ready = 1'b0;
    wire w_Ready;
    wire w_Exit_Condition;
    wire w_Reset;
    wire w_Start;
    wire w_Out;

    always @(posedge i_Clk) begin
        r_Ready <= (w_RX_Byte == 8'h0d) ? 1'b1 : 1'b0;
    end

    assign w_Ready = r_Ready;

    assign w_Exit_Condition = (w_RX_Byte == 8'h71) ? 1'b1 : 1'b0;

    SW_toggle SW_toggle_Inst
    (.i_Switch(w_Exit_Condition),
    .i_Clk(i_Clk),
    .o_Toggle(w_Reset));

    // wire [VIDEO_WIDTH-1:0] w_Red;
    // wire [VIDEO_WIDTH-1:0] w_Green;
    // wire [VIDEO_WIDTH-1:0] w_Blue;

    wire w_Draw_Paddle_Left;
    wire w_Draw_Paddle_Right;
    wire w_Draw_Ball;

    wire w_Segment1_A, w_Segment1_B, w_Segment1_C, w_Segment1_D, w_Segment1_E, w_Segment1_F, w_Segment1_G;

    assign o_Segment1_A = !w_Segment1_A;
    assign o_Segment1_B = !w_Segment1_B;
    assign o_Segment1_C = !w_Segment1_C;
    assign o_Segment1_D = !w_Segment1_D;
    assign o_Segment1_E = !w_Segment1_E;
    assign o_Segment1_F = !w_Segment1_F;
    assign o_Segment1_G = !w_Segment1_G;

    wire w_Segment2_A, w_Segment2_B, w_Segment2_C, w_Segment2_D, w_Segment2_E, w_Segment2_F, w_Segment2_G;

    assign o_Segment2_A = !w_Segment2_A;
    assign o_Segment2_B = !w_Segment2_B;
    assign o_Segment2_C = !w_Segment2_C;
    assign o_Segment2_D = !w_Segment2_D;
    assign o_Segment2_E = !w_Segment2_E;
    assign o_Segment2_F = !w_Segment2_F;
    assign o_Segment2_G = !w_Segment2_G;

    UART_RX #(.BIT_PERIOD(BIT_PERIOD_CLKs)) UART_RX_INST
    (.i_Clk(i_Clk),
    .i_RX_Serial(i_UART_RX),
    .o_RX_DV(w_RX_DV),
    .o_RX_byte(w_RX_Byte));

    UART_TX #(.BIT_PERIOD(BIT_PERIOD_CLKs)) UART_TX_INST
    (.i_Clk(i_Clk),
    .i_TX_DV(w_RX_DV),
    .i_TX_Byte(w_RX_Byte),
    .o_TX_Active(w_TX_Active),
    .o_TX_Serial(w_TX_Serial),
    .o_TX_Done());

    assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1;

    Binary_To_7Segment Left_Display
    (.i_Clk(i_Clk),
    .i_Binary_Num(w_RX_Byte[3:0]),
    .o_Segment_A(w_Segment2_A),
    .o_Segment_B(w_Segment2_B),
    .o_Segment_C(w_Segment2_C),
    .o_Segment_D(w_Segment2_D),
    .o_Segment_E(w_Segment2_E),
    .o_Segment_F(w_Segment2_F),
    .o_Segment_G(w_Segment2_G));

    Binary_To_7Segment Right_Display
    (.i_Clk(i_Clk),
    .i_Binary_Num(w_RX_Byte[7:4]),
    .o_Segment_A(w_Segment1_A),
    .o_Segment_B(w_Segment1_B),
    .o_Segment_C(w_Segment1_C),
    .o_Segment_D(w_Segment1_D),
    .o_Segment_E(w_Segment1_E),
    .o_Segment_F(w_Segment1_F),
    .o_Segment_G(w_Segment1_G));

    Paddle_Ctrl Left_Paddle_Ctrl_Inst
    (.i_Clk(i_Clk),
    .i_H_count(w_H_count),
    .i_V_count(w_V_count),
    .i_Up_Ctrl(i_Switch_1),
    .i_Down_Ctrl(i_Switch_2),
    .i_Reset(w_Reset), 
    .i_Ready(w_Ready),
    .i_Start(w_Start),
    .i_Out(w_Out),
    .o_Draw_Paddle(w_Draw_Paddle_Left),
    .o_V_pos(w_V_pos_left));

    Paddle_Ctrl #(.H_POS(37)) Right_Paddle_Ctrl_Inst
    (.i_Clk(i_Clk),
    .i_H_count(w_H_count),
    .i_V_count(w_V_count),
    .i_Up_Ctrl(i_Switch_3),
    .i_Down_Ctrl(i_Switch_4),
    .i_Reset(w_Reset), 
    .i_Ready(w_Ready),
    .i_Start(w_Start),
    .i_Out(w_Out),
    .o_Draw_Paddle(w_Draw_Paddle_Right),
    .o_V_pos(w_V_pos_right));

    Ball_Ctrl Ball_Ctrl_Inst
    (.i_Clk(i_Clk),
    .i_H_count(w_H_count),
    .i_V_count(w_V_count),
    .i_Paddle_Pos_Left(w_V_pos_left),
    .i_Paddle_Pos_Right(w_V_pos_right),
    .i_Reset(w_Reset),
    .i_Ready(w_Ready),
    .o_Draw_Ball(w_Draw_Ball),
    .o_Out(w_Out),
    .o_Start_Play(w_Start));

    assign o_VGA_Red_0 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Red_1 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Red_2 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;

    assign o_VGA_Green_0 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Green_1 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Green_2 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;

    assign o_VGA_Blue_0 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Blue_1 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;
    assign o_VGA_Blue_2 = w_Draw_Paddle_Right|w_Draw_Paddle_Left|w_Draw_Ball ? 1'b1 : 1'b0;

    frame_counter frame_counter_Inst
    (.i_Clk(i_Clk),
    .o_H_count(w_H_count),
    .o_V_count(w_V_count),
    .o_Frame_end(),
    .o_Frame_start());

    decoder decoder_Inst
    (.i_Clk(i_Clk),
    .i_H_count(w_H_count),
    .i_V_count(w_V_count),
    .o_hsync(o_VGA_HSync),
    .o_vsync(o_VGA_VSync),
    .o_video_on());

endmodule