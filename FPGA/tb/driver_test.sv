
/**
 * This module will give to the test_led_driver all the necessary signal to see the evolution of it output.
 * All the signal are generated in this module.
 * This module is not synthesizable.
 **/ 

module driver_test;

   logic        clk;    // system clk
   logic 	rst_n;  // reset signal (low active)
   logic 	gssck;  // data led driver clock
   logic [7:0] 	gssin;  // data led driver bus (8 bus with 2 LED driver for each of them)
   logic 	gslat;  // latch pulse for TLC5951 marking end of shift operation
   logic 	xblink; // when xblink is low, TLC outputs are disable
   logic 	gsckr;  // red PWM clock
   logic 	gsckg;  // green PWM clock
   logic 	gsckb;  // blue PWM clock
   logic [7:0] 	address;// address for the external RAM
   logic [23:0] datar;  // reading data for external RAM
   logic        write;  // write signal for the external address (1=write and 0=read)
   
      
   //test_led_shift_register module
   test_led_shift_register int1(.clk(clk), .rst_n(rst_n),
                                .address(address), .datar(datar), .we(write),
                                .gssck(gssck), .gssin(gssin), .gslat(gslat), 
                                .xblink(xblink),
                                .gsckr(gsckr), .gsckg(gsckg), .gsckb(gsckb));
   
   // Initialisation
   initial
     begin
        clk = 0;
        // Reset is low at the begining (so reset signal is active) and turn high after
        rst_n = 0;
        // Write is low : test_led_shift_register can always read data
        write = 0;
        // Data are not usefull so, there are always at the same value
        datar = 23'haaaaaa;
     end
   
   // Clock generation : 30 MHz
   always
     #17 clk <= ~clk;

   // Reset signal generation
   initial
     begin
        repeat(5) @(negedge clk);
        rst_n <= 1;
     end

   // write signal generation
   // This simulate an writing access to the internal RAM by the gumstix
   initial
     begin
        repeat(800) @(negedge clk);
        write <= 1;
        repeat(6) @(negedge clk);
        write <= 0;
     end
          
   
   
endmodule // driver_test

   