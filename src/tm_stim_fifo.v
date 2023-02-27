//******************************************************************************
/// @file    tm_stim_fifo.v
/// @author  JAY CONVERTINO
/// @date    2023.01.30
/// @brief   Generic FIFO test bench modules (stimulus).
///
/// @LICENSE MIT
///  Copyright 2023 Jay Convertino
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to 
///  deal in the Software without restriction, including without limitation the
///  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
///  sell copies of the Software, and to permit persons to whom the Software is 
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in 
///  all copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
///  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.
//******************************************************************************

`timescale 1 ns/10 ps
  
//******************************************************************************
/// @brief Simulator core to read file data, and output it to write fifo dut.
//******************************************************************************
module write_fifo_stimulus #(
    parameter BYTE_WIDTH  = 1,          /**< bus width in bytes for data bus */
    parameter BYTE_SWAP   = 0,
    parameter FWFT        = 0,
    parameter FILE        = "test.bin"  /**< input file name    */
  )
  (
    input                         rd_clk,
    input                         rd_rstn,
    input                         rd_en,
    output  reg                   rd_valid,
    output  [(BYTE_WIDTH*8)-1:0]  rd_data,
    output  reg                   rd_empty,
    output  reg                   eof
  );
  

  reg r_b_fwft;
  // axis data register for read in data
  reg [(BYTE_WIDTH*8)-1:0] r_rd_data;
  // axis data register for output data
  reg [(BYTE_WIDTH*8)-1:0] rr_rd_data;
  
  
  // local variables
  integer bytes_read;
  
  // generate variables
  genvar gen_index;
  
  //****************************************************************************
  /// @brief  generate block to change endianness of input read use this if data
  ///         is in an order you do not expect.
  //****************************************************************************
  generate
    if(BYTE_SWAP == 1) begin
      for(gen_index = 0; gen_index < BYTE_WIDTH; gen_index = gen_index + 1) begin
        assign rd_data[8*gen_index +: 8] = rr_rd_data[((BYTE_WIDTH*8)-(gen_index*8)-1) -:8];
      end
    end else begin
      assign rd_data = rr_rd_data;
    end
  endgenerate
  
  //****************************************************************************
  /// @brief block for fifo read output data
  //****************************************************************************
  // positive edge clock
  always @(posedge rd_clk) begin
    // reset signal on negative edge
    if(rd_rstn == 1'b0) begin
      // reset signals
      rd_valid <= 0;
      rd_empty <= 1;
      
      r_rd_data  <= 0;
      rr_rd_data <= 0;
      
      r_b_fwft <= FWFT;
      
      eof <= 0;
      
      bytes_read = 0;
    // out of reset, run on posedge clock
    end else begin
      eof <= eof;
      // first word fall through if r_b_fwft is 1.
      
      if(r_b_fwft || rd_en) begin
        bytes_read = $read_binary_file(FILE, r_rd_data);
        
        rr_rd_data  <= r_rd_data;
        rd_valid    <= 1'b1;
        rd_empty    <= 1'b0;
        
        r_b_fwft <= 1'b0;
        
        if(bytes_read < 0) begin
          eof <= 1'b1;
        end
        
        if(bytes_read == 0) begin
          rr_rd_data  <= 0;
          rd_valid    <= 1'b0;
          rd_empty    <= 1'b1;
        end
      end
    end
  end
  
endmodule

//******************************************************************************
/// @brief  Simulator core to write file data, from input over write fifo dut.
///         This module will keep a constant ready to the dut.
//******************************************************************************
module read_fifo_stimulus #(
    parameter BYTE_WIDTH  = 1,          /**< bus width in bytes for data bus */
    parameter ACK_ENA     = 0,          /**< enable ack if set to 1 (does nothing at the moment, ack is not used*/
    parameter RAND_FULL   = 0,          /**< randomize the full output signal */
    parameter FILE        = "out.bin"   /**< input file name    */
  )
  (
    input                         wr_clk,
    input                         wr_rstn,
    input                         wr_en,
    output  reg                   wr_ack,
    input   [(BYTE_WIDTH*8)-1:0]  wr_data,
    output  reg                   wr_full,
    input                         eof
  );
  
  integer num_wrote = 0;
  
  //****************************************************************************
  /// @brief block for slave axis input data
  //****************************************************************************
  // positive edge clock
  always @(posedge wr_clk) begin
    // reset signal on negative edge
    if(wr_rstn == 1'b0) begin
      // reset signals
      wr_full <= 0;
      wr_ack  <= 0;
      
      num_wrote <= 0;
    // out of reset, run on posedge clock
    end else begin
      wr_full <= (RAND_FULL != 0 ? $random%2 : 0);;
      wr_ack  <= 0;

      if(wr_en == 1) begin      
        num_wrote = $write_binary_file(FILE, wr_data);
      end
      
      if(eof == 1) begin
        $finish();
      end

    end
  end
  
endmodule

