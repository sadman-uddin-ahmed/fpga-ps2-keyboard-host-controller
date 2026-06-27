## CLOCK
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports clk]
## RESET (BTN C)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
## KEYBOARD READ BUTTONS
## rd_kbrd -> BTN U
set_property PACKAGE_PIN T18 [get_ports rd_kbrd]
set_property IOSTANDARD LVCMOS33 [get_ports rd_kbrd]
## rd_dbug -> BTN D
set_property PACKAGE_PIN U17 [get_ports rd_dbug]
set_property IOSTANDARD LVCMOS33 [get_ports rd_dbug]
## PS/2 INTERFACE (PMOD JA)
## JA1 = ps2_clk
set_property PACKAGE_PIN J1 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
## JA2 = ps2_dat
set_property PACKAGE_PIN L2 [get_ports ps2_dat]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_dat]
## AUDIO OUTPUT (PMOD JA3)
set_property PACKAGE_PIN J2 [get_ports aud]
set_property IOSTANDARD LVCMOS33 [get_ports aud]
## FIFO DATA OUTPUT -> LEDs LD7-LD0
set_property IOSTANDARD LVCMOS33 [get_ports {rd_data[*]}]
set_property PACKAGE_PIN U16 [get_ports {rd_data[0]}]  ;# LD0
set_property PACKAGE_PIN E19 [get_ports {rd_data[1]}]  ;# LD1
set_property PACKAGE_PIN U19 [get_ports {rd_data[2]}]  ;# LD2
set_property PACKAGE_PIN V19 [get_ports {rd_data[3]}]  ;# LD3
set_property PACKAGE_PIN W18 [get_ports {rd_data[4]}]  ;# LD4
set_property PACKAGE_PIN U15 [get_ports {rd_data[5]}]  ;# LD5
set_property PACKAGE_PIN U14 [get_ports {rd_data[6]}]  ;# LD6
set_property PACKAGE_PIN V14 [get_ports {rd_data[7]}]  ;# LD7
## FIFO STATUS FLAGS -> LEDs
set_property IOSTANDARD LVCMOS33 [get_ports {data_present data_half data_full}]
set_property PACKAGE_PIN V13 [get_ports data_present] ;# LD8
set_property PACKAGE_PIN V3  [get_ports data_half]    ;# LD9
set_property PACKAGE_PIN W3  [get_ports data_full]    ;# LD10
## 7-SEGMENT DISPLAY ANODES
set_property PACKAGE_PIN U2 [get_ports an0]
set_property PACKAGE_PIN U4 [get_ports an1]
set_property PACKAGE_PIN V4 [get_ports an2]
set_property PACKAGE_PIN W4 [get_ports an3]
set_property IOSTANDARD LVCMOS33 [get_ports {an0 an1 an2 an3}]
## 7-SEGMENT DISPLAY CATHODES
set_property PACKAGE_PIN W7 [get_ports a]
set_property PACKAGE_PIN W6 [get_ports b]
set_property PACKAGE_PIN U8 [get_ports c]
set_property PACKAGE_PIN V8 [get_ports d]
set_property PACKAGE_PIN U5 [get_ports e]
set_property PACKAGE_PIN V5 [get_ports f]
set_property PACKAGE_PIN U7 [get_ports g]
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports {a b c d e f g dp}]
