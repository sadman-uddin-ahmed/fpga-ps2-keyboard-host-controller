`timescale 1 ns / 1 ps

module keyboard (
    ps2_clk, ps2_dat,
    rd_kbrd, rd_dbug,
    clk, rst,
    rd_data, data_present, data_half, data_full,
    aud,
    an3, an2, an1, an0,
    a, b, c, d, e, f, g, dp
);
//Input ports
input ps2_clk;  
input ps2_dat;  
input rd_kbrd;
input rd_dbug;
input clk;
input rst;
//Output ports
output [7:0] rd_data;
output data_present;
output data_half;
output data_full;
//Output from PCM
output aud;
//Output from Quad 7 Segment
output an3, an2, an1, an0;
output a, b, c, d, e, f, g, dp;
// ORIGINAL KEYBOARD LOGIC (UNCHANGED)
wire read;
reg dbug_d1, dbug_d2;
reg [19:0] dbug_ctr;
reg dbug_det;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dbug_d1 <= 0;
        dbug_d2 <= 0;
        dbug_ctr <= 0;
        dbug_det <= 0;
    end else begin
        dbug_d1 <= rd_dbug;
        dbug_d2 <= dbug_d1;
        if (dbug_d2) begin
            if (dbug_ctr != 20'hfffff)
                dbug_ctr <= dbug_ctr + 1;
            dbug_det <= (dbug_ctr == 20'hffffe);
        end else begin
            dbug_ctr <= 0;
            dbug_det <= 0;
        end
    end
end
(* KEEP = "TRUE" *) wire rd_kbrd_keep;
assign rd_kbrd_keep = rd_kbrd;
assign read = rd_kbrd | dbug_det;
//PS/2 filtering
wire ps2_data, ps2_edge;
reg data_d1, data_d2;
reg edge_d1, edge_d2;
reg [3:0] edge_ctr;
reg edge_det;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_d1 <= 1;
        data_d2 <= 1;
        edge_d1 <= 1;
        edge_d2 <= 1;
        edge_ctr <= 0;
        edge_det <= 0;
    end else begin
        data_d1 <= ps2_dat;
        data_d2 <= data_d1;
        edge_d1 <= ps2_clk;
        edge_d2 <= edge_d1;
        if (edge_d2) begin
            edge_ctr <= 0;
            edge_det <= 0;
        end else begin
            if (edge_ctr != 4'hf)
                edge_ctr <= edge_ctr + 1;
            edge_det <= (edge_ctr == 4'he);
        end
    end
end
assign ps2_edge = edge_det;
assign ps2_data = data_d2;
//Shifter
wire shift, okay;
reg [10:0] shifter;
wire [7:0] data_in;
always @(posedge clk or posedge rst) begin
    if (rst)
        shifter <= 0;
    else if (shift)
        shifter <= {ps2_data, shifter[10:1]};
end
assign data_in = shifter[8:1];
assign okay = !shifter[0] && shifter[10] && ^shifter[9:1];
//Timeout
wire expired;
reg [11:0] timeout_ctr;
always @(posedge clk or posedge rst) begin
    if (rst)
        timeout_ctr <= 0;
    else if (shift)
        timeout_ctr <= 0;
    else if (timeout_ctr != 12'hfff)
        timeout_ctr <= timeout_ctr + 1;
end
assign expired = (timeout_ctr == 12'hffe);
//FIFO
wire write;
fifo_16x8 my_fifo (
    .data_in(data_in),
    .data_out(rd_data),
    .rst(rst),
    .write(write),
    .read(read),
    .full(data_full),
    .half_full(data_half),
    .data_present(data_present),
    .clk(clk)
);
//FSM
FSM my_fsm (
    .shift(shift),
    .write(write),
    .expired(expired),
    .okay(okay),
    .ps2_edge(ps2_edge),
    .clk(clk),
    .rst(rst)
);
//Latch last read key
reg [7:0] last_key;
always @(posedge clk or posedge rst) begin
    if (rst)
        last_key <= 8'h00;
    else if (read && data_present)
        last_key <= rd_data;
end
//One-shot pulse for PCM.init
reg pcm_init;
always @(posedge clk or posedge rst) begin
    if (rst)
        pcm_init <= 1'b0;
    else
        pcm_init <= (read && data_present);
end
// PCM AUDIO
PCM pcm_inst (
    .clk(clk),
    .rst(rst),
    .init(pcm_init),
    .aud(aud)
);
//7-SEG DISPLAY
quad7seg seg_inst (
    .val3(4'h0),
    .val2(4'h0),
    .val1(last_key[7:4]),
    .val0(last_key[3:0]),
    .dot3(1'b0),
    .dot2(1'b0),
    .dot1(1'b0),
    .dot0(1'b0),
    .clk(clk),
    .rst(rst),
    .an3(an3),
    .an2(an2),
    .an1(an1),
    .an0(an0),
    .a(a), .b(b), .c(c), .d(d),
    .e(e), .f(f), .g(g),
    .dp(dp)
);
endmodule
