`default_nettype none

  /**
   * This file was only used for testing before having the real SRAMs soldered.
   **/

  module zbtram(
                clk,
                addr,
                rdata,
                wdata,
                we_n
                );
   
   input  logic        clk;
   input  logic [12:0] addr; 
   output logic [7:0]  rdata;
   input  logic [7:0]  wdata;
   input  logic        we_n;
   
   // Internal table
   logic [7:0] 	       ram[0:5119]; //This allows us to store 10 radius of 384 bytes.
   
   // Internal signals
   logic               we_n_r;
   logic [12:0]        addr_r;
   
   always_ff @(posedge clk)
     begin
        we_n_r <= we_n;
        addr_r <= addr;
        
        if(~we_n_r)
          ram[addr_r] <= wdata;
        rdata <= ram[addr];
     end
   
endmodule // zbtram