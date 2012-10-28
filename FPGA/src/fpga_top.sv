`default_nettype none

  /**
   * Top module for Led driver testing in the FPGA.
   * This module instantiate the led_driver module, the gumstix communication module
   * and a ram module.
   * The aim is to received pixels sent by gumstix, to store it on external ram and
   * to turn on the appropriated LED.
   **/

  module top(// Clock input
             clk12,

             // Gumstix IF
             gumstix_clk,
             gumstix_nCS, gumstix_nADV, gumstix_nWE, gumstix_nOE,
             gumstix_ad,
             gumstix_addr,

             // TMC5951 IF
             gssck, gssin, gslat,
             xblink,
             gsckr, gsckg, gsckb,
             dcsck, dcsin,

             // Encoding wheel signals
             a,
             b,
             index,

             // External RAM signals
             ram1_clk,
             ram1_oe_n,
             ram1_ce1_n,
             ram1_we_n,
             ram1_bwa_n,
             ram1_addr,
             ram1_data,

	     ram2_clk,
             ram2_oe_n,
             ram2_ce1_n,
             ram2_we_n,
             ram2_bwa_n,
             ram2_addr,
             ram2_data
             );

   input logic clk12;                // clock (12MHz)

   // Gumstix signal
   input logic gumstix_clk;  // GPMC clock (40 MHz)
   input logic gumstix_nCS;  // GPMC chip select (active low)
   input logic gumstix_nADV; // GPMC address valid (active low)
   input logic gumstix_nWE;  // GPMC write enable (active low)
   input logic gumstix_nOE;  // GPMC output enable (active low)
   input logic [15:0] gumstix_ad;   // GPMC multiplexed address (LSB) and data bus
   input logic [20:17] gumstix_addr; // GPMC address bus (MSB)

   // LED driver signal
   output logic        gssck;        // clock to shift out the pixels
   output logic [7:0]  gssin;        // data beeing shifted out
   output logic        gslat;        // latch pulse for TLC5951 marking end of shift operation
   output logic        xblink;       // when xblink is low, TLC outputs are disable
   output logic        gsckr;        // red PWM clock
   output logic        gsckg;        // green PWM clock
   output logic        gsckb;        // blue PWM clock
   output logic        dcsck;        // clock to shift out dc data (not used)
   output logic [7:0]  dcsin;        // dedicated bus for dc data (not used)

   // Encoding wheel signals
   input logic         a;            // encoding wheel a signal
   input logic         b;            // encoding wheel b signal ; the conjunstion of a and b allow to know if a new position if reached
   input logic         index;        // encoding wheel index signal : put at 1 when position 0 is reached

   // Ram Signals
   output logic        ram1_clk;
   output logic        ram1_oe_n;         // output enable (active low : 0 for reading access)
   output logic        ram1_ce1_n;        // chip enable (active low : 0 for writing and reading access)
   output logic        ram1_we_n;         // write enable (active low : 0 for a writing access)
   output logic        ram1_bwa_n;        // use to select 8 LSB bits (active low)
   output logic [18:0] ram1_addr;
   inout wire [7:0]    ram1_data;

   output logic        ram2_clk;
   output logic        ram2_oe_n;         // output enable (active low : 0 for reading access)
   output logic        ram2_ce1_n;        // chip enable (active low : 0 for writing and reading access)
   output logic        ram2_we_n;         // write enable (active low : 0 for a writing access)
   output logic        ram2_bwa_n;        // use to select 8 LSB bits (active low)
   output logic [18:0] ram2_addr;
   inout wire [7:0]    ram2_data;


   /**
    * CLK 30 MHz generation (through PLL)
    **/
   logic               clk30;

   pll pll_inst(.inclk0(clk12),
                .c0(clk30)
                );

   /**
    * Reset generation
    **/
   logic               rst_n;
   logic [15:0]        count;

   // pragma synthesis off
   initial
     count <= 0;
   // pragma synthesis on

   always_ff @(posedge clk30)
     begin
        if(count !=16'h1ff)
          count <= count+16'h1;
        rst_n <= count == 16'h1ff;
     end


   /**
    * Gumstix' interface
    **/
   logic [20:0]        fpga_addr; // FPGA address bus (21 bits, bit 0 is always 0)
   logic [15:0]        fpga_data; // FPGA data bus
   logic               fpga_valid;
   logic               fpga_ack;

   gumstix_interface gs_if(.gumstix_clk(gumstix_clk),
                           .gumstix_ad(gumstix_ad),
                           .gumstix_addr(gumstix_addr),
                           .gumstix_nCS(gumstix_nCS),
                           .gumstix_nADV(gumstix_nADV),
                           .gumstix_nWE(gumstix_nWE),
                           .gumstix_nOE(gumstix_nOE),

                           .clk30(clk30),
                           .addr(fpga_addr),
                           .data(fpga_data),
                           .valid(fpga_valid),
                           .ack(fpga_ack)
                           );

   // When a transcation is available on the interface FPGA side (fpga_valid is high), then ack it and ask for the next one.
   // !!! WARNING !!! Every module has then only ONE cycle to handle transcations.
   assign fpga_ack = fpga_valid;


   // The Gumstix can send either pixel data, configuration commands or control data.
   // The mapping is as follow :
   //    fpga_addr[20:19] == 00 : pixel data
   //    fpga_addr[20:19] == 01 : configuration command
   //    fpga_addr[20:19] == 10 : control command

   // Address decoding
   logic               pixel_write_enable,
                       config_write_enable,
                       command_write_enable;
   assign pixel_write_enable   = (fpga_addr[20:19] == 2'b00) && fpga_valid;
   assign config_write_enable  = (fpga_addr[20:19] == 2'b01) && fpga_valid;
   assign command_write_enable = (fpga_addr[20:19] == 2'b10) && fpga_valid;



   /**
    * Control register :
    *   bit 0    : send config (set by gumstix, cleared by FPGA as soon as the configuration shift has begun)
    *   bit 1    : led enable (unused)
    *   bit 2    : RAM toggle (read in the first ram and write to the second ram)
    *   bit 3    : RAM toggle (write to the first ram and read the second ram)
    *   bit 4    : Set the zero of the blade at the current position (set by gumstix, cleared by FPGA) - unused
    *   bit 15:5 : reserved
    **/
   logic [15:0]       control_register;
   logic              ram_switch; // Be carefull; it is called switch but it is not a toggle. See explainations lower.
   logic              config_shift_start; // enable to begin shifting out config data (1 cycle active only)
   logic              config_has_started; // indicates that config shift has started
   logic 	      set_zero; // indicates the 0 position of the blade (unused)
   logic 	      zero_seted;	      

   always_ff @(posedge clk30 or negedge rst_n)
     if(~rst_n)
       control_register <= 0;
     else
       begin
          // Bit 0 : gumstix can set it to start a command shift operation.
          // As soon as the configuration shift has begun, this bit is cleared by this module so that the Gumstix can
          // enqueue another configuration shift request.
          if(command_write_enable)
	    begin
               control_register[0] <= fpga_data[0];
	       control_register[4] <= fpga_data[4];
	    end
          if(config_has_started)
            control_register[0] <= 0;
	  if(zero_seted)
	    control_register[4] <= 0;
	  	  
          // Bit 2 & 3 : control the RAM cross bar. 
	  // The gumstix can write a 1 to this bit to switch on a RAM, or 1 in the other one  to switch to the other one.
	  // Bit 2 has the priority.
          if(command_write_enable && !fpga_data[0])
	    begin
               if (fpga_data[3])
		 begin
		    control_register[3] <= fpga_data[3];
		    control_register[2] <= !fpga_data[3];
		 end
	       if (fpga_data[2])
		 begin
		    control_register[2] <= fpga_data[2];
		    control_register[3] <= !fpga_data[2];
		 end
	    end // if (command_write_enable && !fpga_data[0])

          // Bit 4 : Command to tell to set the zero position

          // Bit 15:5 and 1 : reserved
          control_register[15:5] <= 11'b0;
          control_register[1] <= 1'b0;

       end // else: !if(~rst_n)
   
   assign set_zero = control_register[4];
   assign config_shift_start = control_register[0];
   assign ram_switch = control_register[2];

   /**
    * Blade_position module
    **/
   logic [9:0]        led_position;                // the current blade position (angle)
   logic [6:0]        led_number;                  // the current LED on the blade
   logic [3:0]        led_subcycle;                // the current clock cycle fot the current LED


   blade_position position_int(.clk(clk30),
                               .rst_n(rst_n),
                               .a_signal(a),
                               .b_signal(b),
                               .index_signal(index),
                               .position(led_position),
                               .led(led_number),
                               .led_subcycle(led_subcycle),
			       .set_zero(set_zero),
			       .zero_seted(zero_seted)
                               );

   /**
    * Internal rom
    * With the precalcultations
    **/
   logic [14:0]       rom_addr;
   logic [19:0]       data_from_rom;
   
   internal_rom internal_rom(.clk(clk30),
			     .address(rom_addr),
			     .data(data_from_rom)
			     );
   
   
   /**
    * Pixel fetcher
    **/
   logic [7:0]         read_ram_rdata;
   logic [18:0]        read_ram_addr;
   logic [8:0]         pixel_addr;         // [7:1] = the number of the pixel currently beeing stored in the driver buffer, [0]: 0=RG, 1=B
   logic [7:0]         pixel_data;         // value of pixel currentl beeing stored in the driver buffer
   logic               store_pixel;        // enable to store the pixel (1 cycle active only)
   logic               pixel_shift_start;  // High to begin shifting operation

   fetch_pixels fetch_pixels(.clk(clk30),
                             .rst_n(rst_n),
                             .position(led_position),
                             .led(led_number),
                             .led_subcycle(led_subcycle),
                             .ram_addr(read_ram_addr),
                             .ram_rdata(read_ram_rdata),
                             .pixel_addr(pixel_addr),
                             .pixel_data(pixel_data),
                             .store_pixel(store_pixel),
                             .pixel_shift_start(pixel_shift_start),
			     .data_from_rom(data_from_rom),
			     .rom_addr(rom_addr)
                             );


   /**
    * Storage of the pixels in the RAM : take one short word from Gumstix, and split it into
    * two char store in one of the RAM
    **/
   logic [7:0]         write_ram_wdata;
   logic [18:0]        write_ram_addr;
   logic               write_ram_we_n;

   zbt_write_ctrl zbt_write_ctrl(
                                 .clk(clk30),
                                 .rst_n(rst_n),
                                 .gs_data(fpga_data),
                                 .gs_address(fpga_addr[18:0]),
                                 .pixel_write_enable(pixel_write_enable),
                                 .ram_data(write_ram_wdata),
                                 .ram_address(write_ram_addr),
                                 .ram_we_n(write_ram_we_n)
                                 );


   /**
    * RAM crossbar : deals with the switch of the RAMs
    **/
   logic [7:0]        ram1_wdata, ram1_rdata;
   logic [7:0]        ram2_wdata, ram2_rdata;
   assign ram1_rdata = ram1_data;
   assign ram2_rdata = ram2_data;
      
   cross_exchanger cross_exchanger(
                                   .clk(clk30),
                                   .ram_switch(ram_switch),
                                   .write_ram_wdata(write_ram_wdata),
                                   .write_ram_addr(write_ram_addr),
                                   .write_ram_we_n(write_ram_we_n),
                                   .read_ram_rdata(read_ram_rdata),
                                   .read_ram_addr(read_ram_addr),
                                   .ram1_addr(ram1_addr),
                                   .ram1_wdata(ram1_wdata),
                                   .ram1_rdata(ram1_rdata),
                                   .ram1_we_n(ram1_we_n),
                                   .ram1_oe_n(ram1_oe_n),
                                   .ram2_addr(ram2_addr),
                                   .ram2_wdata(ram2_wdata),
                                   .ram2_rdata(ram2_rdata),
                                   .ram2_we_n(ram2_we_n),
                                   .ram2_oe_n(ram2_oe_n)
                                   );

   /**
    * First and second RAM : external ZBT RAM
    **/
   assign ram1_clk = clk30;
   assign ram1_ce1_n = 0;
   assign ram1_bwa_n = 0;
   assign ram1_data = ram1_oe_n ? ram1_wdata : 8'hzz;

   assign ram2_clk = clk30;
   assign ram2_ce1_n = 0;
   assign ram2_bwa_n = 0;
   assign ram2_data = ram2_oe_n ? ram2_wdata : 8'hzz;


   /**
    * LED shift register
    **/
   logic [15:0]        config_data;        // data for TLC5951 configuration
   logic [8:0]         config_addr;        // configuration word addr
   logic               store_config;       // enable to store the config data
   logic               shift_ready;        // low when shifting out data

   led_shift_register led_shift_register(.clk(clk30),
                                         .rst_n(rst_n),

                                         .pixel_data(pixel_data),
                                         .pixel_addr(pixel_addr),
                                         .store_pixel(store_pixel),

                                         .config_data(config_data),
                                         .config_addr(config_addr),
                                         .store_config(store_config),

                                         .pixel_shift_start(pixel_shift_start),
                                         .config_shift_start(config_shift_start),
                                         .config_has_started(config_has_started),
                                         .ready(shift_ready),

                                         .gssck(gssck),
                                         .gssin(gssin),
                                         .gslat(gslat),
                                         .xblink(xblink),

                                         .gsckr(gsckr), .gsckg(gsckg), .gsckb(gsckb)
                                         );




   /**
    * Configuration data feeder to shifter
    **/
   always_ff @(posedge clk30 or negedge rst_n)
     if(~rst_n)
       begin
          config_addr <= 0;
          config_data <= 0;
          store_config <= 1;
       end
     else
       begin
          store_config <= 0;
          if(config_write_enable)
            begin
               // Send configuration data to led_shift_register's internal config data buffer
               config_addr <= fpga_addr[9:1];
               config_data <= fpga_data;
               store_config <= 1;
            end
       end


   // Unused pins
   assign dcsin = 0;
   assign dcsck = 0;

endmodule