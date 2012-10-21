`default_nettype none

  /**
   * This module transfert some configuration data to the led_gs_shift_register module
   * and then some pixels.
   **/
   
  module config_shift_register(clk, 
                               rst_n,
                               config_data,
			       config_number,
			       store_config,
                                               
			       config_select,
			       shift_start,
                               shift_ready,
                               config_done
                               );
   
   
   input  logic        clk;           // clock (30MHz)
   input  logic        rst_n;         // reset signal (active low)
   
   output logic [23:0] config_data;
   output logic [7:0]  config_number;
   output logic        store_config;

   output logic        shift_start;
   input  logic        shift_ready;
   output logic        config_select;
   output logic        config_done;

   // Config data ROM
   logic [23:0]        config_rom[0:129];

   // Config data ROM initialisation
   initial
     $readmemh("../rom_files/rom_config.lst", config_rom);

   // State machine to transfert config data to the led driverd (TLC5951)
   enum         {IDLE, LOAD_CONFIG, SEND_CONFIG, WAIT_CONFIG_START, WAIT_CONFIG_DONE, STOP} state;
   integer      counter;

   always_ff @(posedge clk or negedge rst_n)
     begin
        if(rst_n==0)
          begin
             state <= IDLE;
             counter <= 0;
             shift_start <= 0;
             store_config <= 0;
             config_data <= 0;
             config_number <= 0;
             config_select <= 0;
             config_done <= 0;
          end
        else
          begin
             // Default values
             store_config <= 0;
             shift_start <= 0;
             
             case(state)
               IDLE:
                 begin
                    state <= LOAD_CONFIG;
                    counter <= 0;
                 end
               
               LOAD_CONFIG:
                 begin
                    // Send data configuration to the led driver
                    config_data <= config_rom[counter];
                    config_number <= counter;
                    store_config <= 1;
                    // Next number config
                    counter <= counter+1;
                    // When all config data are sent, shift out the config data
                    if(counter==129)
                         state <= SEND_CONFIG;
                 end // case: LOAD_CONFIG

               SEND_CONFIG:
                 begin
                    // Send configuration to the led
                    config_select <= 1;
                    shift_start <= 1;
                    state <= WAIT_CONFIG_START;
                 end

               WAIT_CONFIG_START:
                 // Wait for the transmission to begin
                 if(~shift_ready)
                   state <= WAIT_CONFIG_DONE;
                 
               WAIT_CONFIG_DONE:
                 // Wait for all data to have been shifted out to TLC
                 begin
                    if(shift_ready)
                      state <= STOP;
                 end
                 
               STOP:
                 begin
                    // Final state : reset signals to safe values
                    config_select <= 0;
                    shift_start <= 0;
                    counter <= 0;
                    config_done <= 1;
                    // Stay here
                    state <= STOP;
                 end
                    
               default:
                 state <= IDLE;
             
             endcase
          end // else: !if(rst_n==0)
     end // block: STATE_MACHINE

endmodule // test_led_shift_register

       

