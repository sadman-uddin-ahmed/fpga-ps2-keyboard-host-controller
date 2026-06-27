`timescale 1 ns / 1 ps
// PCM Top-Level Module
// Connects SEQ, ROM, and DAC modules
module PCM (
    input  wire clk,   //100 MHz system clock
    input  wire rst,   //Asynchronous reset
    input  wire init,  //Pushbutton start signal
    output wire aud    //1-bit audio output
);
//Internal connections
wire [12:0] addr;   //Address from SEQ to ROM
wire [7:0]  dout;   //Data from ROM to DAC
//Instantiate the Address Sequencer
SEQ my_seq (
        .clk(clk),
        .rst(rst),
        .init(init),
        .addr(addr)
);
//Instantiate the ROM (Audio Data Memory)
ROM my_rom (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .dout(dout)
);
//Instantiate the DAC (Delta-Sigma Converter)
DAC my_dac (
        .sample(dout),   //8-bit signed audio sample from ROM
        .analog(aud),    //1-bit PWM output to speaker
        .clk(clk),
        .rst(rst)
);
endmodule
