/***********************************************************************************************************/
/***************************************************RoseAce*************************************************/
/***********************************************************************************************************/
/*                                             ram_controller.sv                                           */
/***********************************************************************************************************/
/* This module manage the RAM access. All the access are done in two clock cycles :                         
 *   -address presentation (with cs=1 and wr = 1 for write and 0 for read)                                 
 *   -cs = 1 and data transmission (in output or input direction in function of previous wr signal         
 * Access can be pipelined.                                                                                
 * cs must be assert during all the transmission (address and data).                                       
 * rw must be assert during address presentation for a writing access.                                                          
 * The address is 19 bits lenght and, the data are 8 bits lenght because, we just have connect the 8       
 * LSB bits on the 16 avaible on the ram.                                                                  
 *                                                                                                         
 * Input signals : clk               : clock.                                                              
 *                 we_n              : 0 for a writing access and 1 for a reading access.                  
 *                 cs                : chip select signal : 1 for enable the module, 0 else.               
 *                 address[18:0]     : addres for read and write access.                                   
 *                 dataw[7:0]        : data for writing access.                                            
 *                                                                                                         
 * Output signal : oe_n              : output enable for external RAM.                                     
 *                 ce1_n             : chip enable for external RAM.                                       
 *                 we1_n             : write enable for external RAM.                                      
 *                 bwa_n             : LSB byte selection for external RAM (not really usefull here).      
 *                 address_RAM[18:0] : address for external RAM.                                           
 *                 data_RAM[7:0]     : data for external RAM.                                              
 *                 datar[7:0]        : data for FPGA or ggumstix reading access.                           
 *                                                                                                         
 ***********************************************************************************************************/
module ram_controller(clk, 
                      we_n, 
                      cs, 
                      oe_n,
                      ce1_n, 
                      we1_n, 
                      bwa_n, 
                      address, 
                      datar, 
                      dataw, 
                      address_ram_output, 
                      data_ram_output);
   
   localparam data_size = 8;
   localparam address_size = 19;
   
   /*Input clock*/
   input clk;
   /*Input read/write (0 for read and 1 for write) and chip select (1 for selecting the chip)*/
   input  logic we_n, cs;
   /*Output to command RAM memory*/
   output logic bwa_n, we1_n, ce1_n, oe_n;
   /*Adress and data*/
   /*Use to communicate with the other module*/
   input  logic [address_size-1:0] address;
   input  logic [data_size-1:0]    dataw;
   output logic [data_size-1:0]    datar;
   /*Use to communicate with the RAM memory*/
   output logic [address_size-1:0] address_ram_output;
   inout  logic [data_size-1:0]    data_ram_output;

   /*Interal signals*/
   logic 			   write, read, write_old, read_old;
   
   
   /*Assign*/
   assign write = ~we_n && cs;
   assign read = we_n && cs;
   assign address_ram_output = address;
   assign data_ram_output = write_old ? dataw : {(data_size){1'bz}};
   assign datar = read_old ? data_ram_output : {(data_size){1'bz}};
   assign bwa_n = ~write_old;
   assign we1_n = ~write;
   assign oe_n = ~read;
   assign ce1_n = ~cs;

   always_ff@(posedge clk)
     begin
	write_old <= write;
	read_old <= read;
     end
   
endmodule


