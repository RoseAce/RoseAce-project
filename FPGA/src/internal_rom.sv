/***********************************************************************************************************/
/****************************************************RoseAce************************************************/
/***********************************************************************************************************/
/*                                             internal_rom.sv                                             */
/***********************************************************************************************************/
/* This module is a ROM. The ROM will store the pre calculations on the FPGA.                              
 * Precalculation are stored just for an octant. The other pre calculation must be calculated              
 * thanks to symmetry.                                                                                     
 *                                                                                                           
 * Input signal  : clk           : clock signal.                                                           
 *                 address[15:0] : address for reading data.                                               
 *                                                                                                         
 * Output signal : data[19:0]    : reading data. 
 *                                              
 * Pre calculations are store using the following organisation (x and y are the coordinates of the pixel)
 * floating part of y | integer part of y  | floating part of x | integer part of x
 *        2 bits      |        8 bits      |       2 bits       |      8 bits                                                                                       
 * /!\ WARNING : Currently we are in quadrant and not octant so we DON'T have floating part /!\
 *                                                                                                         
 ***********************************************************************************************************/

module internal_rom(clk, 
                    address, 
                    data);

   
   /*Clock input*/
   input clk;
   /*Adress input*/
   input [14:0] address;
   /*Data output*/

   output logic [19:0] data;

   /*ROM memory*/
   logic [15:0]        mem[(2**15)-1:0]; // We are in quadrant at this moment, so only 16 bits but 2**15 instead of 2**14 data

   /*Initailisation of the memory with pre calculations*/
   initial
     begin
	$readmemh("../../pre_calcul/pre_calcul.lst", mem);
     end

   /*Output data*/
   always_ff@(posedge clk)
     data <= mem[address];
   
endmodule // internal_rom
