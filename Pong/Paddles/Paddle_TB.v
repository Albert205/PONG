// Code your testbench here
// or browse Examples
module Paddle_TB;

    parameter MOVE_SPEED = 5;

    reg r_Clk = 1'b0;
    reg [$clog2(800)-1:0] r_H_count = 20;
    reg [$clog2(525)-1:0] r_V_count = 20;

    reg r_Up_Ctrl = 1'b0;
    reg r_Down_Ctrl = 1'b0;

    reg r_Reset = 1'b0;
    reg r_Ready = 1'b0;
    reg r_Start = 1'b0;

    wire [2:0] w_Red;
    wire [2:0] w_Green;
    wire [2:0] w_Blue;

    always #10 r_Clk <= ~r_Clk;

    Paddle_Ctrl #(.MOVE_SPEED(MOVE_SPEED)) Paddle_Ctrl_Inst
    (.i_Clk(r_Clk),
    .i_H_count(r_H_count),
    .i_V_count(r_V_count),
    .i_Up_Ctrl(r_Up_Ctrl),
    .i_Down_Ctrl(r_Down_Ctrl),
    .i_Reset(r_Reset),
    .i_Ready(r_Ready),
    .i_Start(r_Start),
    .o_Red(w_Red),
    .o_Green(w_Green),
    .o_Blue(w_Blue));

    initial begin
        #5
        r_Ready <= 1'b1;
        #10
        r_Ready <= 1'b0;
        #30
        r_Start <= 1'b1;
        #10
        r_Start <= 1'b0;
        #30
        r_Up_Ctrl <= 1'b1;
      	r_H_count <= 64;
      	r_V_count <= 129;
      	#600
      	r_Up_Ctrl <= 1'b0;
      	r_Down_Ctrl <= 1'b1;
      	#500
      	r_Down_Ctrl <= 1'b0;
      	#50
      	r_Reset <= 1'b1;
      	#20
      	r_Reset <= 1'b0;
        #1000
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule


