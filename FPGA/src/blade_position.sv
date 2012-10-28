`default_nettype none
/**
 * This module manage the encoding wheel signals and command the other module of the calculation block.
 * The encoding wheel give 16384 different positions and, the module give just 1024 different positions.
 * So, we will count 16384/1024 = 16 different positions of the wheel before changing our position.
 *
 * Input signal :  clk            : clock (30MHz).
 *                 a_signal       :
 *                 b_signal       :
 *                 index_signal   : high at the beginning of a revolution.
 *                 rst_n          : reset signal (active low).
 *
 * Output signal : position [9:0] : absolute position
 *                 led [6:0]      : LED which must be turned on
 *                 led_subcycle[3:0] : there are 12 cycles by LED.

 *
 **********************************************************************************************************
 */

module blade_position(clk,
                      rst_n,
                      a_signal,
                      b_signal,
                      index_signal,
                      position,     // Theta (in polar coordinates)
                      led,          // Rho (in polar coordinates)
                      led_subcycle, 
		      set_zero,
		      zero_seted);

   localparam number_position_octant = 2**(10-3);
   // This parameter is necessary because the 0 of the encoding wheel is not the vertical position

   /*Input clock*/
   input  logic                                clk;
   input  logic 			       rst_n;
   
   /*Encoding wheel interface*/
   input  logic 			       a_signal;
   input  logic 			       b_signal;
   input  logic 			       index_signal;
   input  logic 			       set_zero;
   output logic 			       zero_seted;
   output logic [9:0] 			       position;
   output logic [6:0]                          led;
   output logic [3:0]                          led_subcycle;


   /*To be sure that a_signal, b_signal and index_signal will not be sampled on VCC/2, the enter on the module on 2 register*/
   logic 				       a_signal_r, a_signal_rr;
   logic 				       b_signal_r, b_signal_rr;
   logic 				       index_signal_r, index_signal_rr;
   logic [9:0] 				       offset_position;

   always_ff@(posedge clk)
     begin
        // De-metastabilization
        a_signal_r <= a_signal;
        a_signal_rr <= a_signal_r;
        b_signal_r <= b_signal;
        b_signal_rr <= b_signal_r;
        index_signal_r <= index_signal;
        index_signal_rr <= index_signal_r;
     end 

   // On each "a" rising edge, increment position
   logic         a_signal_rrr;
   logic         rising_edge;
   logic         index_signal_rrr;
   logic         index_rising_edge;
   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       begin
          a_signal_rrr <= 0;
          rising_edge <= 0;
	  index_signal_rrr <= 0;
          index_rising_edge <= 0;
       end
     else
       begin
          // Save the previous data
          a_signal_rrr <= a_signal_rr;
          // If a front edge is detected
          rising_edge <= a_signal_rr && ~a_signal_rrr;

	  // Save the previous data
          index_signal_rrr <= index_signal_rr;
          // If a front edge is detected
          index_rising_edge <= index_signal_rr && ~index_signal_rrr;
       end


   // Handle position counter
   logic [14:0]  position_counter;

   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       position_counter <= 0;
     else if (index_rising_edge)
       begin
	  led_subcycle <= 0;
	  led <= 0;
	  if (position_counter[9])
	    // We round to the closer (trick inside)
	    position_counter[14:10] <= position_counter[14:10] + 1;
	  // Get back to the good 1/16 of turn
	  position_counter[9:0] <= 10'b0;
       end
     else
       begin 
          // Led subcycle : count each clock cycles, from 0 to 11
          led_subcycle <= (led_subcycle != 11) ? led_subcycle + 1 : 0;
          if ((led_subcycle == 11) && (led != 127))
            led <= led + 1;
	  
          if(rising_edge)
            begin
	       position_counter <= b_signal_rr ? position_counter + 1 : position_counter - 1;
	       if(position_counter[3:0] == 4'b1111) 
                 begin
                    led <= 0;
                    led_subcycle <= 0;
                 end
            end
       end 

   
   assign position = position_counter[13:4] + offset_position;

   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       offset_position <= 0;
     else
	  if (set_zero && !zero_seted)
	    begin
	       zero_seted <= 1;
	       offset_position <= position - offset_position;
	    end
	  else
	    zero_seted <= 0;

   


endmodule // blade_position
