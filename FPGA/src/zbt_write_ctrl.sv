`default_nettype none
   
  /********* ZBT write controller
   * Module allowing to write into the ram. It is plugged on a cross exchanger so it does not know in which RAM it writes.
   * It sends the data to the RAM if the address two higher bits are 'b00.
   * 
   * Inputs:
   * clk 30MHz
   * gs_data[15:0] It comes from the gumstix via the module gumstix_interface.
   * gs_address[18:0] It comes from the gumstix via the module gumstix_interface. We do not receive the two major bits that stand for the command.
   * pixel_write_enable It comes from the gumstix via the module gumstix_interface. 1 if the pixel comes in.
   * 
   * Outputs:
   * ram_data[7:0] The RAM wants a byte.
   * ram_address[18:0] To adapt to the number of adresses of the RAM
   * ram_we_n It asks for writing in the RAM.
   * 
   * 
   **************/

  module zbt_write_ctrl(
                        clk,
                        rst_n,
                        gs_data,
                        gs_address,
                        pixel_write_enable,
                        ram_data,
                        ram_address,
                        ram_we_n
                        );
   
   input logic         clk;
   input logic         rst_n;
   input logic [15:0]  gs_data;
   input logic [18:0]  gs_address;
   input logic         pixel_write_enable;        
   
   output logic [7:0]  ram_data;
   output logic [18:0] ram_address;
   output logic        ram_we_n;

   //Internal logics
   logic               write_word1; // It signals that the module have asked to store the first part of the data.
   logic               write_word2; // It signals that the module have asked to dtore the second part of the data.
   logic [15:0]        gs_data_r, gs_data_rr;
   logic [18:0]        gs_address_r;

   always_ff @(posedge clk or negedge rst_n)
     if(~rst_n)
       begin
          write_word1 <= 0;
          write_word2 <= 0;
	  ram_we_n <= 1;
          gs_address_r <= 0;
          gs_data_r <= 0;
          gs_data_rr <= 0;
          ram_address <= 0;
          ram_data <= 0;
       end
     else
       begin
          // Default values.
          write_word1 <= 0;
          write_word2 <= 0;
	  ram_we_n <= 1;
	  
          // The incoming data are stored in a register.
          gs_address_r <= gs_address;
          gs_data_r <= gs_data;
          gs_data_rr <= gs_data_r;

          // If the Gumstix has data to store.
          if(pixel_write_enable)
            begin
               // It asks to store data in the next cycle.
               ram_we_n <= 0;
               ram_address <= gs_address[18:0];
	       write_word1 <= 1;
            end

          // If the module has asked to store the first part of the data.
          if(write_word1)
            begin
               ram_data <= gs_data_r[7:0];
               // It asks to store data in the next cycle.
               ram_we_n <= 0;
               ram_address <= (gs_address_r[18:0] | 1'b1);
               write_word2 <= 1;           
            end
          
          // If the module has asked to store the second part of the data.
          if(write_word2)
            begin
               ram_data <= gs_data_rr[15:8];           
            end
       end

endmodule // zbt_write_ctrl



