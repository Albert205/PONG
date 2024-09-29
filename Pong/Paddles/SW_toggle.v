module SW_toggle
(input i_Switch,
input i_Clk,
output o_Toggle);

    reg r_Switch = 1'b0;
    reg r_Toggle = 1'b0;
    assign o_Toggle = r_Toggle;

    always @(posedge i_Clk) begin
        r_Switch <= i_Switch;
        if(r_Switch == 1'b0 && i_Switch == 1'b1)
            r_Toggle <= 1'b1;
        else
            r_Toggle <= 1'b0;
    end

endmodule

