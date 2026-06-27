`timescale 1ns / 1ps
//SEQ Sub-Module: Address Sequencer for Audio Playback
module SEQ(
    input  wire clk,     //100 MHz clock
    input  wire rst,     //Asynchronous reset
    input  wire init,    //Asynchronous start (pushbutton)
    output reg  [12:0] addr  //ROM address output
);
//Internal registers
reg [13:0] count;      //Sample rate counter (14 bits for 12207)
reg        ce;         //Playback enable
reg [2:0]  sync;       //Synchronizer shift register
//Constant for sample rate division (100 MHz / 8192 Hz ≈ 12207)
localparam integer SAMPLE_DIV = 14'd12207;
//Maximum address (end of tune)
localparam [12:0] MAX_ADDR = 13'h1FFF;
//Rising-edge detect signal for INIT
wire start = sync[1] & ~sync[2];
//Asynchronous Reset and Main Sequencing Logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr  <= 13'd0;
        count <= 14'd0;
        ce    <= 1'b0;
    end
    else if (start) begin
        addr  <= 13'd0;
        count <= 14'd0;
        ce    <= 1'b1;
    end
    else if (ce) begin
        if (count >= SAMPLE_DIV) begin 
        count <= 14'd0;
        if (addr < MAX_ADDR)
            addr <= addr + 13'd1;
        else
            ce <= 1'b0;  // stop when end reached
        end
        else begin 
            count <= count + 14'd1;
        end
    end
end
//Synchronizer for Asynchronous INIT Signal
always @(posedge clk or posedge rst) begin
if (rst)
    sync <= 3'b000;
else
    sync <= {sync[1:0], init};
end
endmodule
