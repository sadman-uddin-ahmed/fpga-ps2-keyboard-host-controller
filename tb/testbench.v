`timescale 1 ns / 1 ps

module keyboard_testbench_v_tf();
  // PS/2 and control signals
  tri1 ps2_clk;
  tri1 ps2_dat;
  reg tb_clk;
  reg tb_dat;
  assign ps2_clk = tb_clk ? 1'bz : 1'b0;
  assign ps2_dat = tb_dat ? 1'bz : 1'b0;
  reg rd_kbrd;
  reg rd_dbug;
  reg clk;
  reg rst;
  wire [7:0] rd_data;
  wire data_present;
  wire data_half;
  wire data_full;
  // Quad7Seg signals
  reg [3:0] val3, val2, val1, val0;
  reg dot3, dot2, dot1, dot0;
  wire an3, an2, an1, an0;
  wire a, b, c, d, e, f, g, dp;
  // Instantiate keyboard DUT
  keyboard DUT (
        .ps2_clk(ps2_clk),
        .ps2_dat(ps2_dat),
        .rd_kbrd(rd_kbrd),
        .rd_dbug(rd_dbug),
        .clk(clk),
        .rst(rst),
        .rd_data(rd_data),
        .data_present(data_present),
        .data_half(data_half),
        .data_full(data_full)
  );
  // Instantiate quad7seg for display
  quad7seg my_display (
    .val3(val3), .val2(val2), .val1(val1), .val0(val0),
    .dot3(dot3), .dot2(dot2), .dot1(dot1), .dot0(dot0),
    .clk(clk), .rst(rst),
    .an3(an3), .an2(an2), .an1(an1), .an0(an0),
    .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g), .dp(dp)
  );
  // 100 MHz system clock
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end
  // Reset logic
  initial begin
    rst = 1'b1;
    #110;
    rst = 1'b0;
  end
  // Initialize Quad7Seg values to 8.6.4.5
  initial begin
    val3 = 4'd8;
    val2 = 4'd6;
    val1 = 4'd4;
    val0 = 4'd5;
    dot3 = 0;
    dot2 = 0;
    dot1 = 0;
    dot0 = 0;
  end
  // Waveform dump
  initial begin
    $dumpfile("keyboard_tb.vcd");
    $dumpvars(0, keyboard_testbench_v_tf);
  end
  // Timeout watchdog
  initial begin
    #20000000; // 20 ms
    $display("TIMEOUT: Simulation exceeded 20 ms without completing expected actions.");
    $stop;
  end
  // PS/2 timing constants
  localparam integer PS2_LOW  = 1000;   // 1 us low
  localparam integer PS2_HIGH = 1000;   // 1 us high
  localparam integer PS2_IDLE = 5000;   // 5 us idle between frames
  // Send PS/2 scan code
  task SEND_SCANCODE;
    input [7:0] scancode;
    input force_bad_parity;
    input force_bad_start;
    input force_bad_stop;
    integer i;
    reg parity_bit;
  begin
    $display("  Sending scancode 0x%x.", scancode);
    if (force_bad_parity) $display("  ** with bad parity");
    if (force_bad_start)  $display("  ** with bad start");
    if (force_bad_stop)   $display("  ** with bad stop");
    parity_bit = ^{scancode, !force_bad_parity};
    // Ensure idle-high before starting
    tb_clk <= 1'b1;
    tb_dat <= 1'b1;
    #PS2_IDLE;
    // Start bit (0 unless forced bad)
    tb_dat <= force_bad_start;
    #PS2_HIGH;  tb_clk <= 1'b0;
    #PS2_LOW;   tb_clk <= 1'b1;
    // 8 data bits (LSB first)
    for (i = 0; i < 8; i = i + 1) begin
      tb_dat <= scancode[i];
      #PS2_HIGH;  tb_clk <= 1'b0;
      #PS2_LOW;   tb_clk <= 1'b1;
    end
    // Parity bit
    tb_dat <= parity_bit;
    #PS2_HIGH;  tb_clk <= 1'b0;
    #PS2_LOW;   tb_clk <= 1'b1;
    // Stop bit (1 unless forced bad)
    tb_dat <= !force_bad_stop;
    #PS2_HIGH;  tb_clk <= 1'b0;
    #PS2_LOW;   tb_clk <= 1'b1;
    // Return to idle
    tb_dat <= 1'b1;
    tb_clk <= 1'b1;
    #PS2_IDLE;
  end
  endtask
  // Testbench main sequence
  initial begin
    $display("Simulation starting...");
    tb_clk  <= 1'b1;
    tb_dat  <= 1'b1;
    rd_kbrd <= 1'b0;
    rd_dbug <= 1'b0;
    @(negedge rst);
    $display("Reset deasserted, sending scan codes...");
    // Send example scan codes
    SEND_SCANCODE(8'hAA,0,0,0);
    SEND_SCANCODE(8'h1C,0,0,0);
    SEND_SCANCODE(8'h32,0,0,0);
    // Wait until FIFO has data
    wait (data_present == 1'b1);
    // Read up to 3 entries
    @(negedge clk);
    $display("  Read scancode 0x%x from FIFO.", rd_data);
    rd_kbrd <= 1'b1;
    @(negedge clk);
    rd_kbrd <= 1'b0;
    #1000;
    if (data_present) begin
      @(negedge clk);
      $display("  Read scancode 0x%x from FIFO.", rd_data);
      rd_kbrd <= 1'b1;
      @(negedge clk);
      rd_kbrd <= 1'b0;
    end
    #1000;
    if (data_present) begin
      @(negedge clk);
      $display("  Read scancode 0x%x from FIFO.", rd_data);
      rd_kbrd <= 1'b1;
      @(negedge clk);
      rd_kbrd <= 1'b0;
    end
    $display("Simulation over, check waveforms (keyboard_tb.vcd).");
    $stop;
  end
endmodule
