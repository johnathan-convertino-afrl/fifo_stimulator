//******************************************************************************
/// @file    tb_fifo.v
/// @author  JAY CONVERTINO
/// @date    2023.01.30
/// @brief   Generic FIFO test bench top.
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

module tb_fifo #(
  parameter IN_FILE_NAME = "in.bin",
  parameter OUT_FILE_NAME = "out.bin",
  parameter RAND_FULL = 0);
  //parameter or local param bus, user and dest width? and files as well? 
  
  localparam BUS_WIDTH  = 14;
  
  wire                      tb_stim_clk;
  wire                      tb_stim_rstn;
  wire                      tb_stim_valid;
  wire [(BUS_WIDTH*8)-1:0]  tb_stim_data;
  wire                      tb_stim_empty;
  wire                      tb_stim_ready;
  wire                      tb_stim_ack;
  
  wire                      tb_eof;
  
  clk_stimulus #(
    .CLOCKS(1), // # of clocks
    .CLOCK_BASE(1000000), // clock time base mhz
    .CLOCK_INC(1000), // clock time diff mhz
    .RESETS(1), // # of resets
    .RESET_BASE(2000), // time to stay in reset
    .RESET_INC(100) // time diff for other resets
  ) clk_stim (
    //clk out ... maybe a vector of clks with diff speeds.
    .clkv(tb_stim_clk),
    //rstn out ... maybe a vector of rsts with different off times
    .rstnv(tb_stim_rstn),
    .rstv()
  );
  
  write_fifo_stimulus #(
    .BYTE_WIDTH(BUS_WIDTH),
    .FILE(IN_FILE_NAME)
  ) write_fifo_stim (
    .rd_clk(tb_stim_clk),
    .rd_rstn(tb_stim_rstn),
    .rd_en(~tb_stim_ready),
    .rd_valid(tb_stim_valid),
    .rd_data(tb_stim_data),
    .rd_empty(tb_stim_empty),
    .eof(tb_eof)
  );

  
  read_fifo_stimulus #(
    .BYTE_WIDTH(BUS_WIDTH),
    .RAND_FULL(RAND_FULL),
    .FILE(OUT_FILE_NAME)
  ) read_fifo_stim (
    .wr_clk(tb_stim_clk),
    .wr_rstn(tb_stim_rstn),
    .wr_en(tb_stim_valid),
    .wr_ack(tb_stim_ack),
    .wr_data(tb_stim_data),
    .wr_full(tb_stim_ready),
    .eof(tb_eof)
  );
  
  // fst dump command
  initial begin
    $dumpfile ("tb_fifo.fst");
    $dumpvars (0, tb_fifo);
    #1;
  end
  
endmodule

