// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

`default_nettype none

/**
 * This module handles writes comming from the gumstix and format them to a friendly way for the FPGA.
 *
 * Data are received from the gumstix via the GPMC interface using the following convention :
 *   - 20 bits of addresses are transmitted : addr[20:1]. The lowest bit (0) is *NOT* transmitted.
 *   - 16 bits of data.
 *   - BWE0_n and BWE1_n are not routed ont he PCB. Thus only 16bits accesses are possible.
 *   - the GPMC bus is multiplexed : ad[15:0] is used to carry address[16:1] as well as data[15:0]
 *
 * Gumstix signals  : clk                 : GPMC clock (~40Mhz)
 *                    gumstix_ad[15:0]    : multiplexed transmission data / address bus (addr[0] is not sent)
 *                    gumstix_addr[20:17] : 4 highest bits of address (20:17), not multiplexed
 *                    nCS                 : gumstix chip select (active low).
 *                    nADV                : gumstix address valid (0 when address can be read by FPGA)
 *                    nWE                 : gumstix write enable (0 when gumstix write on memory)
 *                    nOE                 : gumstix output enable (1 when gumstix drives the bus during the data phase)
 *
 * To resynchronize address and data from gumstix's clock domain to FPGA's clock domain, both are posted
 * through a FIFO 36 bits wide (20 for addresses, 16 for data). The FPGA should consume FIFO's data quick
 * enough so that the FIFO does not overflow. Should the fifo become full (it should not !), its content is not
 * overwritten.
 *
 * FPGA interface :
 *   - clk        : FPGA clock (30MHz)
 *   - addr[20:0] : addresses sent by Gumstix (bit 0 will always be 0)
 *   - data[15:0] : data sent by Gumstix
 *   - valid      : indicate that there is valid data / addr to be consumed by the FPGA.
 *                  Stays active (1) until ack.
 *   - ack        : input to acknwoledge data and addr. On the next cycle, the new data / addr will be
 *                   presented if there are some. If there aren't, valid will become low.
 *
 ***********************************************************************************************************/

module gumstix_interface (gumstix_clk,
                          gumstix_ad,
                          gumstix_addr,
                          gumstix_nCS,
                          gumstix_nADV,
                          gumstix_nWE,
                          gumstix_nOE,

                          clk30,
                          addr,
                          data,
                          valid,
                          ack
                          );

   input logic          gumstix_clk;   // GPMC clock (~ 40Mhz)
   input logic [15:0]   gumstix_ad;    // Gumstix multiplexed address and data bus (addr[16:1] / data[15:0])
   input logic [20:17]  gumstix_addr;  // The 4 highest bits of the address (not multiplexed)
   input logic          gumstix_nCS;   // GPMC chip select
   input logic          gumstix_nADV;  // GPMC address valid (1 when FPGA can read address)
   input logic          gumstix_nWE;   // GPMC write enable (1 when gumstix write on memory)
   input logic          gumstix_nOE;   // GPMC output enable (1 when gumstix read on memory)
   
   input logic          clk30;// FPGA clock (30MHz)                       
   output logic [20:0]  addr; // FPGA address bus (21 bits, bit 0 is always 0)
   output logic [15:0]  data; // FPGA data bus
   output logic         valid;
   input logic          ack;
   
   // Memorize the 3 last addr_data and address
   logic [15:0]         gumstix_ad_r, gumstix_ad_rr, gumstix_ad_rrr;       // gumstix addr_data on the 3 last cycles
   logic [20:17]        gumstix_addr_r, gumstix_addr_rr, gumstix_addr_rrr; // gumstix address on the 3 last cycles
   logic                gumstix_nWE_r, gumstix_nWE_rr;
   
   always_ff @(negedge gumstix_clk)
     begin
        gumstix_ad_r     <= gumstix_ad;
        gumstix_ad_rr    <= gumstix_ad_r;
        gumstix_ad_rrr   <= gumstix_ad_rr;

        gumstix_addr_r   <= gumstix_addr;
        gumstix_addr_rr  <= gumstix_addr_r;
        gumstix_addr_rrr <= gumstix_addr_rr;

        gumstix_nWE_r    <= gumstix_nWE;
        gumstix_nWE_rr   <= gumstix_nWE_r;
     end

   // Handles FIFO writes
   logic                       fifo_wrfull;
   logic [35:0]                fifo_data_in; // the data sent to the fifo
   logic                       fifo_wrreq;   // the request to write in the fifo

   always_ff @(negedge gumstix_clk)
     begin
        // Default value
        fifo_wrreq <= 0;

        // If on the previous falling clock edge WEn was low and on the still previous falling clock edge WEn was high 
        // then latch data and adresses which were valid 3 clock cycles before
        if((gumstix_nWE_r == 0) && (gumstix_nWE_rr == 1) & (gumstix_nCS == 0))
          if(~fifo_wrfull)
            begin
               fifo_wrreq   <= 1;
               fifo_data_in <= {gumstix_addr_rrr, gumstix_ad_rrr, gumstix_ad};
            end
     end

   // Handles FIFO reads
   logic [35:0]       fifo_data_out;
   logic              fifo_rdreq;    // This signal is a read ***ACK*** (not request !!!)
   logic              fifo_rdempty;

   assign valid      = ~fifo_rdempty;
   assign fifo_rdreq = ack;
   assign addr       = {fifo_data_out[35:16], 1'b0};
   assign data       = fifo_data_out[15:0];


   // FIFO instantiation
   fifo fifo_inst(
                  .wrclk(gumstix_clk),
                  .wrreq(fifo_wrreq),
                  .wrfull(fifo_wrfull),
                  .data(fifo_data_in),

                  .rdclk(clk30),
                  .rdreq(fifo_rdreq),
                  .q(fifo_data_out),
                  .rdempty(fifo_rdempty)
                  );


endmodule // gumstix_interface

