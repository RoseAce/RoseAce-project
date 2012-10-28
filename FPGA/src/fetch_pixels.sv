`default_nettype none

  /*
   * This module takes a LED coordinates (rho and theta = led and position) and
   * fetches its components (RGB) in RAM.
   * 
   * /*\ WARNING : Curently we are in quadrant and not in octant, some comments and code might seem strange because of that. /*\
   **/

  module fetch_pixels(
		      clk,
		      rst_n,
		      position,
		      led,
		      led_subcycle,
		      ram_addr,
		      ram_rdata,
		      pixel_addr,
		      pixel_data,
		      store_pixel,
		      pixel_shift_start,
		      data_from_rom,
		      rom_addr
		      );

   input  logic         clk;       // clock signal (30 Mhz)
   input  logic 	rst_n;     // reset signal (active low)
   input  logic [9:0] 	position;  // blade's current position
   input  logic [6:0] 	led;       // current led's number
   input  logic [3:0] 	led_subcycle;  // current clock cycle for the current LED
   input  logic [15:0] 	data_from_rom;
   output logic [18:0] 	ram_addr;  // RAM addresses
   input  logic [7:0] 	ram_rdata; // Data from RAM

   output logic [8:0] 	pixel_addr;  // Output pixel address in the shift register's internal register
   // cf. mapping in led_shift_register.v
   output logic [7:0] 	pixel_data;  // Output pixel components (RGB)
   output logic         store_pixel; // high for one cycle, when pixel's components has been calculated and should
   // be stored in the shift register
   output logic         pixel_shift_start; // When end LED has been stored, then assert this signal for one cycle
   // to begin the shifting operation.
   output logic [14:0]	rom_addr;
   

   logic 		invert;
   logic 		x_sign;
   logic 		y_sign;


   /**
    * We need to get the pixel address of the image
    * with the pre calculation of the positions
    * and delay of one cycle all the other signals
    **/

   logic [7:0] 		x_inverted, y_inverted;

   //Get the position in the ram of the led that position we want
   assign rom_addr = {position[7:0], led};
   //If necessary for this octant we're inverting x and y
   assign x_inverted = (invert) ? 9'h100 - data_from_rom[15:8] : data_from_rom[7:0];
   assign y_inverted = (invert) ? 9'h100 - data_from_rom[7:0] : data_from_rom[15:8];

   logic [6:0] 		led_r;
   logic [3:0] 		led_subcycle_r;
   
   //Register the usefull information to be synchronous
   always_ff @(posedge clk or negedge rst_n)
     if(~rst_n)
       begin
	  led_r <= 0;
	  led_subcycle_r <= 0;
       end
     else
       begin
	  led_r <= led;
	  led_subcycle_r <= led_subcycle;
       end

   // Exchanging the sign of x and y if necessary in the current octant
   // The formula in a little different between the 2 side of the blade (a '-' sign)
   always_comb
     begin
	ram_addr[9:2] = (x_sign) ? x_inverted : x_inverted - 2*(x_inverted - 128);
	ram_addr[17:10] = (y_sign) ? y_inverted : y_inverted - 2*(y_inverted - 128);
     end

   /**
    * For each LED, we must fetch 3 chars : R, G and B
    **/
   assign ram_addr[1:0] = led_subcycle[3:2];
   assign ram_addr[18] = 0;

   assign pixel_addr  = {led_r, led_subcycle_r[3:2]};
   assign pixel_data  = ram_rdata;
   assign store_pixel = led_subcycle_r[1:0] == 2'b11;

   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       pixel_shift_start <= 0;
     else
       pixel_shift_start <= (led_r==127) && (led_subcycle_r==11);


   /**
    * pre calculation result : 1 inversion, 0 not
    * x_sign         : sign of the x coordinate on the pre calculation result.
    * y_sign         : sign of the y coordinate on the pre calculation result.
    * For the 2 previous signal : 1 positive and 0 negative
    **/

   // Compute the octant where the propeller is
   logic [1:0]  current_quadrant;
   assign current_quadrant = position[9:8];

   // Compute the x, y and invert signals
   // Must be shifted 1 clock cycle
   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       begin
	  y_sign <= 0;          
	  x_sign <= 0;
	  invert <= 0;
       end
     else
       begin
          invert <= current_quadrant[0];
          x_sign <= ~(current_quadrant[0] ^ current_quadrant[1]);
          y_sign <= ~current_quadrant[1];        
       end
   
endmodule // fetch_pixels
