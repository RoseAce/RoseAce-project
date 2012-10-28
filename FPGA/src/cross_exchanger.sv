`default_nettype none

  module cross_exchanger(
			 clk,
			 ram_switch,
			 write_ram_wdata,
			 write_ram_addr,
			 write_ram_we_n,
			 read_ram_rdata,
			 read_ram_addr,
			 ram1_addr,
			 ram1_wdata,
			 ram1_rdata,
			 ram1_we_n,
                         ram1_oe_n,
			 ram2_addr,
			 ram2_wdata,
			 ram2_rdata,
			 ram2_we_n,
                         ram2_oe_n
			 );

   input  logic           clk;
   input  logic 	  ram_switch; //To switch between the 2 ram
   
   //gumstix side
   input  logic [7:0] 	  write_ram_wdata;
   input  logic [18:0] 	  write_ram_addr;
   input  logic 	  write_ram_we_n;

   //led side
   output logic [7:0] 	  read_ram_rdata;
   input  logic [18:0] 	  read_ram_addr;

   //first ram side (the one which exists for the moment)
   output logic [18:0] 	  ram1_addr;
   output logic [7:0] 	  ram1_wdata;
   input  logic [7:0] 	  ram1_rdata;
   output logic 	  ram1_we_n;
   output logic 	  ram1_oe_n;

   //second ram side (pull down for the moment)
   output logic [18:0] 	  ram2_addr;
   output logic [7:0] 	  ram2_wdata;
   input  logic [7:0] 	  ram2_rdata;
   output logic 	  ram2_we_n;
   output logic 	  ram2_oe_n;

   //ram_switch==1 : Reading the right ram   
   assign read_ram_rdata = (ram_switch) ? ram1_rdata : ram2_rdata;

   // Produce output on falling clock edge, so that RAM can sample them without propagation delays problems.
   always_ff @(negedge clk)
     begin
        ram1_addr  <= (ram_switch) ? read_ram_addr : write_ram_addr;
        ram1_wdata <= write_ram_wdata;
        ram1_we_n  <= (ram_switch) ? 1'b1 : write_ram_we_n;
        ram1_oe_n <= ~ram1_we_n;
     end
        
   always_ff @(negedge clk)
     begin
        ram2_addr  <= (ram_switch) ? write_ram_addr : read_ram_addr;
        ram2_wdata <= write_ram_wdata;
        ram2_we_n  <= (ram_switch) ? write_ram_we_n : 1'b1;
        ram2_oe_n  <= ~ram2_we_n;
     end

endmodule // cross_exchanger