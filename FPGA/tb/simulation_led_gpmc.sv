`default_nettype none
`timescale 1 ps / 1 ps

// This module is to implement a simulation of the interface between the leds and the gumstix through the gpmc.

module simulation_led_gpmc;


   // Clock signal
   logic         clk12;

   // Gumstix signals
   logic         gumstix_clk;  // GPMC clock (40 MHz)
   logic         n_cs;         // GPMC chip select (active low)
   logic         n_adv;        // GPMC address valid (active low)
   logic         n_we;         // GPMC write enable (active low)
   logic         n_oe;         // GPMC output enable (active low)
   logic [15:0]  addr_data;    // GPMC address (LSB) and data bus (communication is multiplexed)
   logic [20:17] address;      // GPMC addres bus (MSB)

   // LED driver signal
   logic         gssck; // clock to shift out the pixels
   logic [7:0]   gssin; // data beeing shifted out
   logic         gslat; // latch pulse for TLC5951 marking end of shift operation
   logic         xblink;// when xblink is low, TLC s are disable
   logic         gsckr; // red PWM clock
   logic         gsckg; // green PWM clock
   logic         gsckb; // blue PWM clock
   logic         dcsck; // clock to shift out dc data (not used)
   logic [7:0]   dcsin; // dedicated bus for dc data (not used)

   // Encoding wheel signals
   logic         a, b, index;
   integer       counter_index;


   // RAM signals
   logic         ram1_clk;
   logic         ram1_oe_n;         // output enable (active low : 0 for reading access)
   logic         ram1_ce1_n;        // chip enable (active low : 0 for writing and reading access)
   logic         ram1_we_n;        // write enable (active low : 0 for a writing access)
   logic         ram1_bwa_n;        // use to select 8 LSB bits (active low)
   logic [18:0]  ram1_addr;
   wire [7:0] 	 ram1_data;

   top fpga_top(.clk12(clk12),

                .gumstix_clk(gumstix_clk),
                .gumstix_nCS(n_cs),
                .gumstix_nADV(n_adv),
                .gumstix_nWE(n_we),
                .gumstix_nOE(n_oe),
                .gumstix_ad(addr_data),
                .gumstix_addr(address),

                .a(a),
                .b(b),
                .index(index),

                .gssck(gssck),
                .gssin(gssin),
                .gslat(gslat),
                .xblink(xblink),
                .gsckr(gsckr),
                .gsckg(gsckg),
                .gsckb(gsckb),
                .dcsck(dcsck),
                .dcsin(dcsin),

                .ram1_clk(ram1_clk),
                .ram1_oe_n(ram1_oe_n),
                .ram1_ce1_n(ram1_ce1_n),
                .ram1_we_n(ram1_we_n),
                .ram1_bwa_n(ram1_bwa_n),
                .ram1_addr(ram1_addr),
                .ram1_data(ram1_data)
                );

   wire [9:0] 	 dummy = 10'hzzz;
   cy1357 fake_ram(
                   .d({dummy,ram1_data}),
                   .clk(ram1_clk),
                   .a(ram1_addr),
                   .bws({1'b1, ram1_bwa_n}),
                   .we_b(ram1_we_n),
                   .adv_lb(1'b0),
                   .ce1b(ram1_ce1_n),
                   .ce2(1'b1),
                   .ce3b(1'b0),
                   .oeb(ram1_oe_n),
                   .cenb(1'b0),
                   .mode(1'b0)
                   );

   // Other signals
   integer       counter;
   logic         gumstix_clk_enable;

   // Signals initialisation
   initial
     begin
        gumstix_clk <= 0;
        n_cs <= 0;
        n_adv <= 1;
        n_we <= 1;
        n_oe <= 1;
        addr_data <= 0;
        address <= 0; 
        a <= 0;
        b <= 0;
        index <=0;
        counter <= 0;
     end

   // Clock generation : 12 MHz
   initial
     clk12 = 0;
   always
     #83.333ns clk12 <= ~clk12;

   // Gumstix clock generation : 40 MHz
   initial
     gumstix_clk_enable  = 0;
   always
     begin
        #12ns;
        if(gumstix_clk_enable)
          gumstix_clk <= ~gumstix_clk;
     end

   // Encoding wheel signals generation
   always
     begin
        #1907ns b <= ~b;
        #1907ns a <= ~a;
     end

   // Index  generation   
   always_ff @(negedge b)
     begin
        index <= 0;
        counter_index <= counter_index+1;
        if(counter==4095)
          begin
             index <= 1;
             counter_index <= 0;
          end
     end


   
   task gumstix_write_short;
      input [20:0] addr;
      input [15:0] data;

      begin
         if(addr[0] != 0)
           begin
              $display("ERROR : unaligned short address");
              $display("\t", addr);
              $stop;
           end
         n_cs <= 1;
         gumstix_clk_enable <= 1;
         n_we <= 1;
         n_adv <= 0;
         addr_data <= addr[16:1];
         address   <= addr[20:17];

         repeat(2)
           begin
              @(posedge gumstix_clk);
              @(negedge gumstix_clk);
           end
         n_adv <= 1;
         n_we <= 0;
         addr_data <= data;
         repeat(3)
           begin
              @(posedge gumstix_clk);
              @(negedge gumstix_clk);
           end
         n_cs <= 0;
         n_we <= 1;
         @(negedge gumstix_clk);
         @(negedge gumstix_clk);
         gumstix_clk_enable <= 0;
      end
   endtask;


   task gumstix_write_long;
      input [20:0] addr;
      input [31:0] data;

      begin
         if(addr[1:0] != 0)
           begin
              $display("ERROR : unaligned long address");
              $display("\t", addr);
              $stop;
           end
         gumstix_write_short(addr, data[15:0]);
         gumstix_write_short(addr+2, data[31:16]);
      end
   endtask


   // Gumstix signal generation
   initial
     begin
        integer i;
        // Waiting for the initialization of the FPGA
        while(fpga_top.rst_n !== 1) @(posedge clk12);
        repeat(50) @(negedge clk12);

        //Send command to switch the RAM
        gumstix_write_short(21'h100000, 'h0);

        // Send config data to the FPGA
        gumstix_write_long(21'h080000, 'haa55aa55);
        gumstix_write_long(21'h080004, 'hffffffff);
        gumstix_write_long(21'h080200, 'hffffff);   // BC
	gumstix_write_short(21'h080204, 'h78);      // FC

        // Set SEND_CONFIG bit in control register, set external RAM to write
        gumstix_write_short(21'h100000, 16'h1);

        // Send some pixels to the FPGA
        for(i=128*510 ; i<128*513 ; i++)
          begin
             gumstix_write_short(i*4, i);
             gumstix_write_short(i*4+2, i);
          end

        
        
	
        // Set external RAM in read mode
        gumstix_write_short(21'h100000, 16'h4);

        repeat(100) @(negedge clk12);


     end



   
endmodule