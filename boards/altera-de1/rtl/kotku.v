/*
 *  Copyright (c) 2009  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module kotku (
    input        clk_50_,
    input        clk_27_,
    output [9:0] ledr_,
    output [7:0] ledg_,
    input  [9:0] sw_,
    input  [3:0] key_,
    output [6:0] hex0_,
    output [6:0] hex1_,
    output [6:0] hex2_,
    output [6:0] hex3_,

    // flash signals
    output [21:0] flash_addr_,
    input  [ 7:0] flash_data_,
    output        flash_we_n_,
    output        flash_oe_n_,
    output        flash_ce_n_,
    output        flash_rst_n_,

    // sdram signals
    output [11:0] sdram_addr_,
    inout  [15:0] sdram_data_,
    output [ 1:0] sdram_ba_,
    output [ 1:0] sdram_dqm_,
    output        sdram_ras_n_,
    output        sdram_cas_n_,
    output        sdram_ce_,
    output        sdram_clk_,
    output        sdram_we_n_,
    output        sdram_cs_n_,

    // sram signals
    output [17:0] sram_addr_,
    inout  [15:0] sram_data_,
    output        sram_we_n_,
    output        sram_oe_n_,
    output        sram_ce_n_,
    output [ 1:0] sram_bw_n_,

    // VGA signals
    output [ 3:0] tft_lcd_r_,
    output [ 3:0] tft_lcd_g_,
    output [ 3:0] tft_lcd_b_,
    output        tft_lcd_hsync_,
    output        tft_lcd_vsync_,

    // UART signals
    input         uart_rxd_,
    output        uart_txd_,

    // PS2 signals
    inout         ps2_clk_,
    inout         ps2_data_,

    // SD card signals
    output        sd_sclk_,
    input         sd_miso_,
    output        sd_mosi_,
    output        sd_ss_,

    // I2C
    inout         i2c_sdat,
    output        i2c_sclk,

    // AUDIO CODEC
    output        aud_adclrck,
    input         aud_adcdat,
    inout         aud_daclrck,
    output        aud_dacdat,
    inout         aud_bclk,
    output        aud_xck
  );

  // Registers and nets
  wire        clk;
  wire        rst;
  wire        rst_lck;
  wire [15:0] dat_o;
  wire [15:0] dat_i;
  wire [19:1] adr;
  wire        we;
  wire        tga;
  wire [ 1:0] sel;
  wire        stb;
  wire        cyc;
  wire        ack;

  wire        lock;

  // wires to flash controller
  wire [15:0] fl_dat_o;
  wire [15:0] fl_dat_i;
  wire        fl_tga_i;
  wire [19:1] fl_adr_i;
  wire [ 1:0] fl_sel_i;
  wire        fl_we_i;
  wire        fl_cyc_i;
  wire        fl_stb_i;
  wire        fl_ack_o;

  // wires to vga controller
  wire [15:0] vga_dat_o;
  wire [15:0] vga_dat_i;
  wire        vga_tga_i;
  wire [19:1] vga_adr_i;
  wire [ 1:0] vga_sel_i;
  wire        vga_we_i;
  wire        vga_cyc_i;
  wire        vga_stb_i;
  wire        vga_ack_o;

  // cross clock domain synchronized signals
  wire [15:0] vga_dat_o_s;
  wire [15:0] vga_dat_i_s;
  wire        vga_tga_i_s;
  wire [19:1] vga_adr_i_s;
  wire [ 1:0] vga_sel_i_s;
  wire        vga_we_i_s;
  wire        vga_cyc_i_s;
  wire        vga_stb_i_s;
  wire        vga_ack_o_s;

  // wires to uart controller
  wire [15:0] uart_dat_o;
  wire [15:0] uart_dat_i;
  wire        uart_tga_i;
  wire [19:1] uart_adr_i;
  wire [ 1:0] uart_sel_i;
  wire        uart_we_i;
  wire        uart_cyc_i;
  wire        uart_stb_i;
  wire        uart_ack_o;

  // wires to keyboard controller
  wire [15:0] keyb_dat_o;
  wire [15:0] keyb_dat_i;
  wire        keyb_tga_i;
  wire [19:1] keyb_adr_i;
  wire [ 1:0] keyb_sel_i;
  wire        keyb_we_i;
  wire        keyb_cyc_i;
  wire        keyb_stb_i;
  wire        keyb_ack_o;

  // wires to sd controller
  wire [15:0] sd_dat_o;
  wire [15:0] sd_dat_i;
  wire        sd_tga_i;
  wire [19:1] sd_adr_i;
  wire [ 1:0] sd_sel_i;
  wire        sd_we_i;
  wire        sd_cyc_i;
  wire        sd_stb_i;
  wire        sd_ack_o;

  // wires to gpio controller
  wire [15:0] gpio_dat_o;
  wire [15:0] gpio_dat_i;
  wire        gpio_tga_i;
  wire [19:1] gpio_adr_i;
  wire [ 1:0] gpio_sel_i;
  wire        gpio_we_i;
  wire        gpio_cyc_i;
  wire        gpio_stb_i;
  wire        gpio_ack_o;

  // wires to sdram controller
  wire [15:0] sdram_dat_o;
  wire [15:0] sdram_dat_i;
  wire        sdram_tga_i;
  wire [19:1] sdram_adr_i;
  wire [ 1:0] sdram_sel_i;
  wire        sdram_we_i;
  wire        sdram_cyc_i;
  wire        sdram_stb_i;
  wire        sdram_ack_o;

  // wires to default stb/ack
  wire def_cyc_i;
  wire def_stb_i;

  wire [15:0] sw_dat_o;

  wire        sdram_clk;

  wire        vga_clk;

  wire [ 7:0] intv;
  wire [ 2:0] iid;
  wire        intr;
  wire        inta;

  wire [15:0] ip;
  wire [19:0] pc;
  wire [15:0] cs;
  wire [ 2:0] state;

  // Module instantiations
  pll pll (
    .inclk0 (clk_50_),
    .c0     (sdram_clk),
    .c1     (vga_clk),
    .c2     (clk),
    .locked (lock)
  );

  flash flash (
    // Wishbone slave interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (fl_dat_i),
    .wb_dat_o (fl_dat_o),
    .wb_adr_i (fl_adr_i[16:1]),
    .wb_we_i  (fl_we_i),
    .wb_tga_i (fl_tga_i),
    .wb_stb_i (fl_stb_i),
    .wb_cyc_i (fl_cyc_i),
    .wb_sel_i (fl_sel_i),
    .wb_ack_o (fl_ack_o),

    // Pad signals
    .flash_addr_  (flash_addr_),
    .flash_data_  (flash_data_),
    .flash_we_n_  (flash_we_n_),
    .flash_oe_n_  (flash_oe_n_),
    .flash_ce_n_  (flash_ce_n_),
    .flash_rst_n_ (flash_rst_n_)
  );

  yadmc #(
    .sdram_depth       (23),
    .sdram_columndepth (8),
    .sdram_adrwires    (12),
    .cache_depth       (6)
    ) yadmc (

    // Wishbone slave interface
    .sys_clk  (clk),
    .sys_rst  (rst),
    .wb_adr_i ({11'h0,sdram_adr_i,2'b00}),
    .wb_dat_i ({16'h0,sdram_dat_i}),
    .wb_dat_o (sdram_dat_o),
    .wb_sel_i ({2'b00,sdram_sel_i}),
    .wb_cyc_i (sdram_cyc_i),
    .wb_stb_i (sdram_stb_i),
    .wb_we_i  (sdram_we_i),
    .wb_ack_o (sdram_ack_o),

    // SDRAM interface
    .sdram_clk   (sdram_clk),
    .sdram_cke   (sdram_ce_),
    .sdram_cs_n  (sdram_cs_n_),
    .sdram_we_n  (sdram_we_n_),
    .sdram_cas_n (sdram_cas_n_),
    .sdram_ras_n (sdram_ras_n_),
    .sdram_dqm   (sdram_dqm_),
    .sdram_adr   (sdram_addr_),
    .sdram_ba    (sdram_ba_),
    .sdram_dq    (sdram_data_)
  );

  wb_abrg vga_brg (
    .sys_rst (rst),

    // Wishbone slave interface
    .wbs_clk_i (clk),
    .wbs_adr_i (vga_adr_i_s),
    .wbs_dat_i (vga_dat_i_s),
    .wbs_dat_o (vga_dat_o_s),
    .wbs_sel_i (vga_sel_i_s),
    .wbs_tga_i (vga_tga_i_s),
    .wbs_stb_i (vga_stb_i_s),
    .wbs_cyc_i (vga_cyc_i_s),
    .wbs_we_i  (vga_we_i_s),
    .wbs_ack_o (vga_ack_o_s),

    // Wishbone master interface
    .wbm_clk_i (vga_clk),
    .wbm_adr_o (vga_adr_i),
    .wbm_dat_o (vga_dat_i),
    .wbm_dat_i (vga_dat_o),
    .wbm_sel_o (vga_sel_i),
    .wbm_tga_o (vga_tga_i),
    .wbm_stb_o (vga_stb_i),
    .wbm_cyc_o (vga_cyc_i),
    .wbm_we_o  (vga_we_i),
    .wbm_ack_i (vga_ack_o)
  );

  vga vga (
    // Wishbone slave interface
    .wb_rst_i (rst),
    .wb_clk_i (vga_clk),   // 25MHz VGA clock
    .wb_dat_i (vga_dat_i),
    .wb_dat_o (vga_dat_o),
    .wb_adr_i (vga_adr_i[16:1]),    // 128K
    .wb_we_i  (vga_we_i),
    .wb_tga_i (vga_tga_i),
    .wb_sel_i (vga_sel_i),
    .wb_stb_i (vga_stb_i),
    .wb_cyc_i (vga_cyc_i),
    .wb_ack_o (vga_ack_o),

    // VGA pad signals
    .vga_red_o   (tft_lcd_r_),
    .vga_green_o (tft_lcd_g_),
    .vga_blue_o  (tft_lcd_b_),
    .horiz_sync  (tft_lcd_hsync_),
    .vert_sync   (tft_lcd_vsync_),

    // SRAM pad signals
    .sram_addr_ (sram_addr_),
    .sram_data_ (sram_data_),
    .sram_we_n_ (sram_we_n_),
    .sram_oe_n_ (sram_oe_n_),
    .sram_ce_n_ (sram_ce_n_),
    .sram_bw_n_ (sram_bw_n_)
  );

  uart_top com1 (
    // Wishbone slave interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_adr_i ({uart_adr_i[2:1],~uart_sel_i[0]}),
    .wb_dat_i (uart_dat_i),
    .wb_dat_o (uart_dat_o),
    .wb_we_i  (uart_we_i),
    .wb_stb_i (uart_stb_i),
    .wb_cyc_i (uart_cyc_i),
    .wb_ack_o (uart_ack_o),
    .wb_sel_i (4'b0),
    .int_o    (intv[4]), // interrupt request

    // UART signals
    // serial input/output
    .stx_pad_o  (uart_txd_),
    .srx_pad_i  (uart_rxd_),

    // modem signals
    .cts_pad_i  (1'b1),
    .dsr_pad_i  (1'b1),
    .ri_pad_i   (1'b0),
    .dcd_pad_i  (1'b0)
  );

  ps2_keyb #(
    .TIMER_60USEC_VALUE_PP (750),
    .TIMER_60USEC_BITS_PP  (10),
    .TIMER_5USEC_VALUE_PP  (60),
    .TIMER_5USEC_BITS_PP   (6)
    ) keyboard (
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_adr_i (keyb_adr_i[2:1]),
    .wb_dat_o (keyb_dat_o),
    .wb_stb_i (keyb_stb_i),
    .wb_cyc_i (keyb_cyc_i),
    .wb_ack_o (keyb_ack_o),
    .wb_tgc_o (intv[1]),

    .ps2_clk_  (ps2_clk_),
    .ps2_data_ (ps2_data_)
  );

  timer #(
    .res   (33),
    .phase (12507)
    ) timer0 (
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_tgc_o (intv[0])
  );

  simple_pic pic0 (
    .clk  (clk),
    .rst  (rst),
    .intv (intv),
    .inta (inta),
    .intr (intr),
    .iid  (iid)
  );

  sdspi sdspi (
    // Serial pad signal
    .sclk  (sd_sclk_),
    .miso  (sd_miso_),
    .mosi  (sd_mosi_),
    .ss    (sd_ss_),

    // Wishbone slave interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (sd_dat_i),
    .wb_dat_o (sd_dat_o),
    .wb_we_i  (sd_we_i),
    .wb_sel_i (sd_sel_i),
    .wb_stb_i (sd_stb_i),
    .wb_cyc_i (sd_cyc_i),
    .wb_ack_o (sd_ack_o)
  );

  // Switches and leds
  sw_leds sw_leds (
    // Wishbone slave interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_adr_i (gpio_adr_i),
    .wb_dat_o (gpio_dat_o),
    .wb_dat_i (gpio_dat_i),
    .wb_sel_i (gpio_sel_i),
    .wb_we_i  (gpio_we_i),
    .wb_stb_i (gpio_stb_i),
    .wb_cyc_i (gpio_cyc_i),
    .wb_ack_o (gpio_ack_o),

    // GPIO inputs/outputs
    .leds_ ({ledr_,ledg_[7:4]}),
    .sw_   (sw_)
  );

  cpu zet_proc (
    .ip         (ip),
    .cs         (cs),
    .state      (state),
    .dbg_block  (1'b0),

    // Wishbone master interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (dat_i),
    .wb_dat_o (dat_o),
    .wb_adr_o (adr),
    .wb_we_o  (we),
    .wb_tga_o (tga),
    .wb_sel_o (sel),
    .wb_stb_o (stb),
    .wb_cyc_o (cyc),
    .wb_ack_i (ack),
    .wb_tgc_i (intr),
    .wb_tgc_o (inta)
  );

  wb_switch #(
    .s0_addr_1 (20'b0_1111_0000_0000_0000_000), // mem 0xf0000 - 0xfffff
    .s0_mask_1 (20'b1_1111_0000_0000_0000_000),
    .s0_addr_2 (20'b0_1100_0000_0000_0000_000), // mem 0xc0000 - 0xcffff
    .s0_mask_2 (20'b1_1111_0000_0000_0000_000),
    .s0_addr_3 (20'b1_0000_1110_0000_0000_000), // io 0xe000 - 0xfeff
    .s0_mask_3 (20'b1_0000_1111_1110_0000_000),
    .s1_addr_1 (20'b0_1010_0000_0000_0000_000), // mem 0xa0000 - 0xbffff
    .s1_mask_1 (20'b1_1110_0000_0000_0000_000),
    .s1_addr_2 (20'b1_0000_0000_0011_1100_000), // io 0x3c0 - 0x3df
    .s1_mask_2 (20'b1_0000_1111_1111_1110_000),
    .s2_addr_1 (20'b1_0000_0000_0011_1111_100), // io 0x3f8 - 0x3ff
    .s2_mask_1 (20'b1_0000_1111_1111_1111_100),
    .s3_addr_1 (20'b1_0000_0000_0000_0110_000), // io 0x60, 0x64
    .s3_mask_1 (20'b1_0000_1111_1111_1111_101),
    .s4_addr_1 (20'b1_0000_0000_0001_0000_000), // io 0x100
    .s4_mask_1 (20'b1_0000_1111_1111_1111_111),
    .s5_addr_1 (20'b1_0000_1111_0001_0000_000), // io 0xf100 - 0xf103
    .s5_mask_1 (20'b1_0000_1111_1111_1111_110),
    .s6_addr_1 (20'b0_0000_0000_0000_0000_000), // mem 0x00000 - 0xfffff
    .s6_mask_1 (20'b1_0000_0000_0000_0000_000)
    ) wbs (

    // Master interface
    .m_dat_i (dat_o),
    .m_dat_o (sw_dat_o),
    .m_adr_i ({tga,adr}),
    .m_sel_i (sel),
    .m_we_i  (we),
    .m_cyc_i (cyc),
    .m_stb_i (stb),
    .m_ack_o (ack),

    // Slave 0 interface - flash
    .s0_dat_i (fl_dat_o),
    .s0_dat_o (fl_dat_i),
    .s0_adr_o ({fl_tga_i,fl_adr_i}),
    .s0_sel_o (fl_sel_i),
    .s0_we_o  (fl_we_i),
    .s0_cyc_o (fl_cyc_i),
    .s0_stb_o (fl_stb_i),
    .s0_ack_i (fl_ack_o),

    // Slave 1 interface - vga
    .s1_dat_i (vga_dat_o_s),
    .s1_dat_o (vga_dat_i_s),
    .s1_adr_o ({vga_tga_i_s,vga_adr_i_s}),
    .s1_sel_o (vga_sel_i_s),
    .s1_we_o  (vga_we_i_s),
    .s1_cyc_o (vga_cyc_i_s),
    .s1_stb_o (vga_stb_i_s),
    .s1_ack_i (vga_ack_o_s),

    // Slave 2 interface - uart
    .s2_dat_i (uart_dat_o),
    .s2_dat_o (uart_dat_i),
    .s2_adr_o ({uart_tga_i,uart_adr_i}),
    .s2_sel_o (uart_sel_i),
    .s2_we_o  (uart_we_i),
    .s2_cyc_o (uart_cyc_i),
    .s2_stb_o (uart_stb_i),
    .s2_ack_i (uart_ack_o),

    // Slave 3 interface - keyb
    .s3_dat_i (keyb_dat_o),
    .s3_dat_o (keyb_dat_i),
    .s3_adr_o ({keyb_tga_i,keyb_adr_i}),
    .s3_sel_o (keyb_sel_i),
    .s3_we_o  (keyb_we_i),
    .s3_cyc_o (keyb_cyc_i),
    .s3_stb_o (keyb_stb_i),
    .s3_ack_i (keyb_ack_o),

    // Slave 4 interface - sd
    .s4_dat_i (sd_dat_o),
    .s4_dat_o (sd_dat_i),
    .s4_adr_o ({sd_tga_i,sd_adr_i}),
    .s4_sel_o (sd_sel_i),
    .s4_we_o  (sd_we_i),
    .s4_cyc_o (sd_cyc_i),
    .s4_stb_o (sd_stb_i),
    .s4_ack_i (sd_ack_o),

    // Slave 5 interface - gpio
    .s5_dat_i (gpio_dat_o),
    .s5_dat_o (gpio_dat_i),
    .s5_adr_o ({gpio_tga_i,gpio_adr_i}),
    .s5_sel_o (gpio_sel_i),
    .s5_we_o  (gpio_we_i),
    .s5_cyc_o (gpio_cyc_i),
    .s5_stb_o (gpio_stb_i),
    .s5_ack_i (gpio_ack_o),

    // Slave 6 interface - sdram
    .s6_dat_i (sdram_dat_o),
    .s6_dat_o (sdram_dat_i),
    .s6_adr_o ({sdram_tga_i,sdram_adr_i}),
    .s6_sel_o (sdram_sel_i),
    .s6_we_o  (sdram_we_i),
    .s6_cyc_o (sdram_cyc_i),
    .s6_stb_o (sdram_stb_i),
    .s6_ack_i (sdram_ack_o),

    // Slave 7 interface - default
    .s7_dat_i (16'hffff),
    .s7_dat_o (),
    .s7_adr_o (),
    .s7_sel_o (),
    .s7_we_o  (),
    .s7_cyc_o (def_cyc_i),
    .s7_stb_o (def_stb_i),
    .s7_ack_i (def_cyc_i & def_stb_i)
  );

  hex_display hex16 (
    .num (pc[19:4]),
    .en  (1'b1),

    .hex0 (hex0_),
    .hex1 (hex1_),
    .hex2 (hex2_),
    .hex3 (hex3_)
  );

  // Continuous assignments
  assign rst_lck         = !lock;
  assign sdram_clk_      = sdram_clk;

  assign dat_i = inta ? { 13'b0000_0000_0000_1, iid }
               : sw_dat_o;

  assign pc  = (cs << 4) + ip;

  assign rst        = sw_[0] | rst_lck;
  assign ledg_[3:0] = pc[3:0];

endmodule
