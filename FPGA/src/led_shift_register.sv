`default_nettype none
  /**
   * There are 128 pixels on the rotor, split in 8 groups of 2 TLC5951 drivers, each driving 8 RGB LEDs.
   * This module stores the incoming pixels for one group. Then when send is high, it begins shifting
   * them bit by bit on GSSIN.
   * This module can also receive the configuration data to configure all TLC5951, store them in an
   * internal register and transfert them to the LED drivers one bit at a time.
   * The configuration data is transmit to this module through a 24 bit bus and a 4 bits address bus.
   * Configuration data are mapped this way :
   *    addr 0 : 2'b0, DC[13:0]    (G0, R0) driver 0
   *    addr 1 : 9'b0, DC[20:14]   (B0) driver 0
   *    addr 2 : 2'b0, DC[34:21]   (G1, R1) driver 0
   *    addr 3 : 9'b0, DC[41:35]   (B1) driver 0
   *    addr 4 : 2'b0, DC[55:42]   (G2, R2) driver 0
   *    addr 5 : 9'b0, DC[62:56]   (B2) driver 0
   *    addr 6 : 2'b0, DC[76:63]   (G3, R3) driver 0
   *    addr 7 : 9'b0, DC[83:77]   (B3) driver 0
   *    addr 8 : 2'b0, DC[97:84]   (G4, R4) driver 0
   *    addr 9 : 9'b0, DC[104:98]  (B4) driver 0
   *    addr A : 2'b0, DC[118:105] (G5, R5) driver 0
   *    addr B : 9'b0, DC[125:119] (B5) driver 0
   *    addr C : 2'b0, DC[139:126] (G6, R6) driver 0
   *    addr D : 9'b0, DC[146:140] (B6) driver 0
   *    addr E : 2'b0, DC[160:147] (G7, R7) driver 0
   *    addr F : 9'b0, DC[167:161] (B7) driver 0
   *    addr 10 : 2'b0, DC[13:0]    (G0, R0) driver 1
   *    addr 11 : 9'b0, DC[20:14]   (B0) driver 1
   *    addr 12 : 2'b0, DC[34:21]   (G1, R1) driver 1
   *    addr 13 : 9'b0, DC[41:35]   (B1) driver 1
   *    addr 14 : 2'b0, DC[55:42]   (G2, R2) driver 1
   *    addr 15 : 9'b0, DC[62:56]   (B2) driver 1
   *    addr 16 : 2'b0, DC[76:63]   (G3, R3) driver 1
   *    addr 17 : 9'b0, DC[83:77]   (B3) driver 1
   *    addr 18 : 2'b0, DC[97:84]   (G4, R4) driver 1
   *    addr 19 : 9'b0, DC[104:98]  (B4) driver 1
   *    addr 1A : 2'b0, DC[118:105] (G5, R5) driver 1
   *    addr 1B : 9'b0, DC[125:119] (B5) driver 1
   *    addr 1C : 2'b0, DC[139:126] (G6, R6) driver 1
   *    addr 1D : 9'b0, DC[146:140] (B6) driver 1
   *    addr 1E : 2'b0, DC[160:147] (G7, R7) driver 1
   *    addr 1F : 9'b0, DC[167:161] (B7) driver 1
   *    ...
   *    addr FE  : 9'b0, DC[160:147](G7, R7) driver F
   *    addr FF  : 2'b0, DC[167:161](B7) driver F
   *    addr 100 : BC[15:0]
   *    addr 101 : 8'b0, BC[23:16]
   *    addr 102 : 9'b0, FC[6:0]
   *
   * Pixel data are mapped this way :
   *    addr 0   : G[7:0] R[7:0] pixel 0
   *    addr 1   : 8'bxx  B[7:0] pixel 0
   *    addr 2   : G[7:0] R[7:0] pixel 1
   *    addr 3   : 8'bxx  B[7:0] pixel 1
   *    addr 4   : G[7:0] R[7:0] pixel 2
   *    addr 5   : 8'bxx  B[7:0] pixel 2
   *    ...
   *    addr 254 : G[7:0] R[7:0] pixel 127
   *    addr 255 : 8'bxx  B[7:0] pixel 127
   *
   * Inputs:
   *    clk                : clock of the FPGA, 30MHz.
   *    pixel_data[7:0]    : pixel component (R, G or B) to send to the LED driver (stored in a shift register)
   *    pixel_addr[8:0]    : [8:2] : the pixel number, [1:0] : 10=B, 01=G, 00=R
   *    store_pixel        : active high for one cycle. When active, the pixel is stored in an internal buffer.
   *    store_config       : active high for one cycle. When active, the configuration data are stored in an
   *                         internal buffer.
   *    config_data[16:0]  : configuration data (cf datasheet p31, and mapping above).
   *                         Stored in an internal register
   *    config_addr[8:0]   : indicates the config number word beeing received (cf mapping above).
   *
   *    pixel_shift_start  : active high for one cycle. When send is active, the internal pixel buffer is loaded in
   *                         a shift register and the pixels' bits are shifted out one by one on GSSIN at
   *                         GSSCK rate, MSB first. If a previous transmission was already happening,
   *                         this signal is ignored.
   *    config_shift_start : active high for one cycle. When send is active, the internal configuration buffer is loaded in
   *                         a shift register and the pixels' config bits are shifted out one by one on GSSIN at
   *                         GSSCK rate, MSB first. If a previous transmission was already happening,
   *                         this signal is ignored.
   *                         config_shift_start has priority over pixel_shift_start
   *   config_has_started  : active high for one cycle, to indicate that the config shit has just started.
   * 
   *
   * Outputs:
   *    ready           : high when ready to shift out data, low when shifting out data...
   *    gssck           : clock of bits beeing shifted out.
   *    gsdat           : data beeing shifted out.
   *    gslat           : latch pulse marking end of shift operation.
   *    xblink          : when xblink is low led driver output are diseable : it must be low when gslat
   *                      is asserted.
   *    gsckr           : red PWM clock (30MHz).
   *    gsckg           : green PWM clock (30MHz).
   *    gsckb           : blue PWM clock (30MHz).
   *
   * It is possible to store pixels even during a transmission, as they are stored in an internal buffer not
   * in the shift register.
   **/

  module led_shift_register(clk,
                            rst_n,

                            pixel_data,
                            pixel_addr,
                            store_pixel,
                            
                            config_data,
                            config_addr,
                            store_config,

                            pixel_shift_start,
                            config_shift_start,
                            config_has_started,
                            ready,

                            gssck, gssin, gslat,
                            xblink,
                            gsckr, gsckg, gsckb
                            );

   input  logic                  clk;           // 30MHz
   input  logic 		 rst_n;         // reset, active low
   input  logic [8:0] 		 pixel_addr;    // number of pixel + component's sub-address (cf. mapping above)
   input  logic [7:0] 		 pixel_data;    // R, G or B value of pixel currently stored
   input  logic 		 store_pixel;   // enable to store the pixel (1 cycle active only)
   
   input  logic [15:0] 		 config_data;   // data for TLC5951 configuration
   input  logic [8:0] 		 config_addr;   // configuration word addr (cf. mapping above)
   input  logic 		 store_config;  // enable to store the config data
   
   input  logic 		 pixel_shift_start;  // enable to begin shifting out pixels
   input  logic 		 config_shift_start; // enable to begin shifting out config data (priority over pixel)
   output logic                  config_has_started; // active high (1 cycle long) to indicate that config shit has started
   output logic                  ready;         // low when shifting out data

   output logic                  gssck;         // clock to shift out the pixels
   output logic [7:0]            gssin;         // data beeing shifted out
   output logic                  gslat;         // latch pulse for TLC5951 marking end of shift operation
   output logic                  xblink;        // when xblink is low, TLC outputs are disable
   output logic                  gsckr;         // red PWM clock
   output logic                  gsckg;         // green PWM clock
   output logic                  gsckb;         // blue PWM clock


   // Pixel buffer
   logic [7:0] 			 pixel_buffer_R[0:127];        // Buffer storing the incoming pixels (R value)
   logic [7:0]                   pixel_buffer_G[0:127];        // Buffer storing the incoming pixels (G value)
   logic [7:0]                   pixel_buffer_B[0:127];        // Buffer storing the incoming pixels (B value)

   // When a pixel comes in, store it.
   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       begin: P1
          integer i;
          for(i=0 ; i<128 ; i++)
            begin
               pixel_buffer_R[i] <= 0;
               pixel_buffer_G[i] <= 0;
               pixel_buffer_B[i] <= 0;
            end
       end
     else
       if(store_pixel)
         begin
            if(pixel_addr[1:0] == 2'b00)
              pixel_buffer_R[pixel_addr[8:2]] <= pixel_data;
            else if (pixel_addr[1:0] == 2'b01)
              pixel_buffer_G[pixel_addr[8:2]] <= pixel_data;
            else if (pixel_addr[1:0] == 2'b10)
              pixel_buffer_B[pixel_addr[8:2]] <= pixel_data;
         end

   // Configuration buffer
   logic [15:0]                  config_buffer[0:258];         //Buffer storing the incoming configuration

   // When a configuration word comes in, store it.
   always_ff@(posedge clk or negedge rst_n)
     if(~rst_n)
       begin: PC1
          integer i;
          for(i=0 ; i<259 ; i++)
            config_buffer[i] <= 0;
       end
     else
       if(store_config)
         config_buffer[config_addr] <= config_data;


   // State machine controlling the operations
   enum           {IDLE, SHIFTING, GSLAT0, GSLAT1, GSLAT2, XBLINK} state;
   integer        cycle;
   always_ff @(posedge clk or negedge rst_n)
     if(~rst_n)
       begin
          state <= IDLE;
          cycle <= 0;
          gslat <= 0;
          xblink <= 0;
          config_has_started <= 0;
       end
     else
       begin
          // Default output values
          xblink <= 1;
          config_has_started <= 0;
          
          case(state)
            IDLE :
              begin
                 // Put all output signals to a safe level
                 gslat <= 0;
                 cycle <= 0;

                 // When idle, is pixel_shift_start is asserted then begin pixel_shifting operation
                 if(pixel_shift_start)
                   begin
                      // If shifting out pixel data, then GSLAT must be low.
                      gslat <= 1'b0;
                      state <= SHIFTING;
                   end
                 
                 // When idle, is pixel_shift_start is asserted then begin pixel_shifting operation
                 if(config_shift_start)
                   begin
                      // If shifting out configuration data, then GSLAT must be high.
                      gslat <= 1'b1;
                      state <= SHIFTING;
                      config_has_started <= 1;
                   end

              end // case: IDLE

            SHIFTING :
              // The shifting operation lasts 576 cycles.
              begin
                 cycle <= cycle + 1;
                 if(cycle==575)
                   state <= GSLAT0;
              end

            GSLAT0 :
              // First cycle of pulse generation on GSLAT
              begin
                 gslat <= 0;
                 state <= GSLAT1;
              end // case: GSLAT

            GSLAT1 :
              // 2nd cycle of pulse generation on GSLAT
              begin
                 gslat <= 1;
                 state <= GSLAT2;
              end

            GSLAT2 :
              // 3rd cycle of pulse generation on GSLAT
              begin
                 gslat <= 0;
                 state <= XBLINK;
              end

            XBLINK:
              begin
                 // XBLINK keep at 0 for 1 clock cycle more
                 xblink <= 0;
                 // Reset gslat to a safe value
                 gslat <= 0;
                 // Go back to idle mode
                 state <= IDLE;
              end // case: XBLINK

            default :
              state <= IDLE;

          endcase
       end

   // Ready = not shifting
   assign ready = state != SHIFTING;

   // There are 8 shift registers : one for each pair of TLC5951. Each register is 288*2 bits
   // long, as each TLC is needs 288 bits.
   logic [288*2-1:0] gs_data[0:7];


   // The shift registers can be :
   //   - reset, when in reset startup phase
   //   - written to, just before starting the shifting operation
   //   - configured as shift registers during shifting operation

   always_ff @(posedge clk or negedge rst_n)
     if(~rst_n)
       begin: P2
          integer i;
          for(i=0 ; i<8 ; i++)
            gs_data[i] <= 575'h0;
       end
     else
       if(state == IDLE)
         begin: P3
            integer i;
            if(pixel_shift_start)
              for(i=0 ; i<8 ; i++)
                gs_data[i] <= {// Second TLC (MSB first)
                               4'h0, pixel_buffer_B[16*i+15][7:0], 4'h0, pixel_buffer_G[16*i+15][7:0], 4'h0, pixel_buffer_R[16*i+15][7:0],
                               4'h0, pixel_buffer_B[16*i+14][7:0], 4'h0, pixel_buffer_G[16*i+14][7:0], 4'h0, pixel_buffer_R[16*i+14][7:0],
                               4'h0, pixel_buffer_B[16*i+13][7:0], 4'h0, pixel_buffer_G[16*i+13][7:0], 4'h0, pixel_buffer_R[16*i+13][7:0],
                               4'h0, pixel_buffer_B[16*i+12][7:0], 4'h0, pixel_buffer_G[16*i+12][7:0], 4'h0, pixel_buffer_R[16*i+12][7:0],
                               4'h0, pixel_buffer_B[16*i+11][7:0], 4'h0, pixel_buffer_G[16*i+11][7:0], 4'h0, pixel_buffer_R[16*i+11][7:0],
                               4'h0, pixel_buffer_B[16*i+10][7:0], 4'h0, pixel_buffer_G[16*i+10][7:0], 4'h0, pixel_buffer_R[16*i+10][7:0],
                               4'h0, pixel_buffer_B[16*i+09][7:0], 4'h0, pixel_buffer_G[16*i+09][7:0], 4'h0, pixel_buffer_R[16*i+09][7:0],
                               4'h0, pixel_buffer_B[16*i+08][7:0], 4'h0, pixel_buffer_G[16*i+08][7:0], 4'h0, pixel_buffer_R[16*i+08][7:0],
                               // First TLC
                               4'h0, pixel_buffer_B[16*i+07][7:0], 4'h0, pixel_buffer_G[16*i+07][7:0], 4'h0, pixel_buffer_R[16*i+07][7:0],
                               4'h0, pixel_buffer_B[16*i+06][7:0], 4'h0, pixel_buffer_G[16*i+06][7:0], 4'h0, pixel_buffer_R[16*i+06][7:0],
                               4'h0, pixel_buffer_B[16*i+05][7:0], 4'h0, pixel_buffer_G[16*i+05][7:0], 4'h0, pixel_buffer_R[16*i+05][7:0],
                               4'h0, pixel_buffer_B[16*i+04][7:0], 4'h0, pixel_buffer_G[16*i+04][7:0], 4'h0, pixel_buffer_R[16*i+04][7:0],
                               4'h0, pixel_buffer_B[16*i+03][7:0], 4'h0, pixel_buffer_G[16*i+03][7:0], 4'h0, pixel_buffer_R[16*i+03][7:0],
                               4'h0, pixel_buffer_B[16*i+02][7:0], 4'h0, pixel_buffer_G[16*i+02][7:0], 4'h0, pixel_buffer_R[16*i+02][7:0],
                               4'h0, pixel_buffer_B[16*i+01][7:0], 4'h0, pixel_buffer_G[16*i+01][7:0], 4'h0, pixel_buffer_R[16*i+01][7:0],
                               4'h0, pixel_buffer_B[16*i+00][7:0], 4'h0, pixel_buffer_G[16*i+00][7:0], 4'h0, pixel_buffer_R[16*i+00][7:0]
                               };
            if(config_shift_start)
              for(i=0 ; i<8 ; i++)
                gs_data[i] <= {// Second TLC5951
                               89'b0,                                                      // Higher 89 bits : unused
                               config_buffer[258][6:0],                                    // FC[6:0]
                               config_buffer[257][7:0],                                    // BC[23:16]
                               config_buffer[256],                                         // BC[15:0]
                               config_buffer[32*i+31][6:0], config_buffer[32*i+30][13:0],  // DC7 (R,G,B) driver 1
                               config_buffer[32*i+29][6:0], config_buffer[32*i+28][13:0],  // DC6 (R,G,B) driver 1
                               config_buffer[32*i+27][6:0], config_buffer[32*i+26][13:0],  // DC5 (R,G,B) driver 1
                               config_buffer[32*i+25][6:0], config_buffer[32*i+24][13:0],  // DC4 (R,G,B) driver 1
                               config_buffer[32*i+23][6:0], config_buffer[32*i+22][13:0],  // DC3 (R,G,B) driver 1
                               config_buffer[32*i+21][6:0], config_buffer[32*i+20][13:0],  // DC2 (R,G,B) driver 1
                               config_buffer[32*i+19][6:0], config_buffer[32*i+18][13:0],  // DC1 (R,G,B) driver 1
                               config_buffer[32*i+17][6:0], config_buffer[32*i+16][13:0],  // DC0 (R,G,B) driver 1

                               // First TLC5951
                               89'b0,                                                      // Higher 89 bits : unused
                               config_buffer[258][6:0],                                    // FC[6:0]
                               config_buffer[257][7:0],                                    // BC[23:16]
                               config_buffer[256],                                         // BC[15:0]
                               config_buffer[32*i+15][6:0], config_buffer[32*i+14][13:0],  // DC7 (R,G,B) driver 0
                               config_buffer[32*i+13][6:0], config_buffer[32*i+12][13:0],  // DC6 (R,G,B) driver 0
                               config_buffer[32*i+11][6:0], config_buffer[32*i+10][13:0],  // DC5 (R,G,B) driver 0
                               config_buffer[32*i+9][6:0],  config_buffer[32*i+8][13:0],   // DC4 (R,G,B) driver 0
                               config_buffer[32*i+7][6:0],  config_buffer[32*i+6][13:0],   // DC3 (R,G,B) driver 0
                               config_buffer[32*i+5][6:0],  config_buffer[32*i+4][13:0],   // DC2 (R,G,B) driver 0
                               config_buffer[32*i+3][6:0],  config_buffer[32*i+2][13:0],   // DC1 (R,G,B) driver 0
                               config_buffer[32*i+1][6:0],  config_buffer[32*i+0][13:0]    // DC0 (R,G,B) driver 0
                               };

         end
       else if(state == SHIFTING)
         begin: P4
            integer i;
            for(i=0 ; i<8 ; i++)
              gs_data[i][575:1] <= gs_data[i][574:0];
         end


   // The shift registers outputs are connected to GSSIN's
   always_comb
     begin: P5
        integer i;
        for(i=0 ; i<8 ; i++)
          gssin[i] <= gs_data[i][575];
     end

   // gssck generation : to avoid conflicts, change gssin on falling edge of gssck
   assign gssck = (state == SHIFTING) ? ~clk : 1'b0;


   // GS PWM clock managment
   assign gsckr = clk;
   assign gsckg = clk;
   assign gsckb = clk;

endmodule
