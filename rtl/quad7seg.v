`timescale 1ns / 1ps

module quad7seg(
    input [3:0] val3, val2, val1, val0,
    input dot3, dot2, dot1, dot0,
    input clk, rst,
    output reg an3, an2, an1, an0,
    output reg a, b, c, d, e, f, g, dp
    );
//Internal signals
reg [1:0] digit_select;       // which digit is active (0-3)
reg [16:0] refresh_counter;   // refresh clock divider
wire [3:0] curr_val;
wire curr_dot;
//Refresh counter
always @(posedge clk or posedge rst) begin
    if (rst)
        refresh_counter <= 0;
    else
        refresh_counter <= refresh_counter + 1;
end
//Digit selection (slowed for simulation)
always @(posedge clk or posedge rst) begin
    if (rst)
        digit_select <= 0;
    else
        digit_select <= refresh_counter[4:3];  //Slower digit switching for visibility
end
//Select value and dot for the active digit
assign curr_val = (digit_select == 2'b00) ? val0 :
                  (digit_select == 2'b01) ? val1 :
                  (digit_select == 2'b10) ? val2 :
                                            val3;
assign curr_dot = (digit_select == 2'b00) ? dot0 :
                  (digit_select == 2'b01) ? dot1 :
                  (digit_select == 2'b10) ? dot2 :
                                            dot3;
//7-Segment Decoder (Hexadecimal 0-F)
reg [6:0] seg; // {a,b,c,d,e,f,g}
always @(*) begin
    case (curr_val)
        4'h0: seg = 7'b0000001;
        4'h1: seg = 7'b1001111;
        4'h2: seg = 7'b0010010;
        4'h3: seg = 7'b0000110;
        4'h4: seg = 7'b1001100;
        4'h5: seg = 7'b0100100;
        4'h6: seg = 7'b0100000;
        4'h7: seg = 7'b0001111;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0000100;
        4'hA: seg = 7'b0001000;
        4'hB: seg = 7'b1100000;
        4'hC: seg = 7'b0110001;
        4'hD: seg = 7'b1000010;
        4'hE: seg = 7'b0110000;
        4'hF: seg = 7'b0111000;
        default: seg = 7'b1111111; // Blank off
    endcase
end
//Drive segment and anode outputs
always @(*) begin
    // Common anode: active low
    an0 = 1; an1 = 1; an2 = 1; an3 = 1;
    case (digit_select)
        2'b00: an0 = 0;
        2'b01: an1 = 0;
        2'b10: an2 = 0;
        2'b11: an3 = 0;
    endcase
//Assign segment outputs
    {a,b,c,d,e,f,g} = seg;
    dp = ~curr_dot; // active low DP
end
endmodule
