`include "../../inc/sync_fifo_defines.vh"

`timescale 1 ns / 1 ps

module sync_fifo_model #(
    parameter FIFO_DEPTH  = `FIFO_DEPTH       , // FIFO depth
    parameter DATA_WIDTH  = `DATA_WIDTH       , // Data width
    parameter ADDR_WIDTH  = $clog2(FIFO_DEPTH), // Address width
    parameter FALLTHROUGH = "TRUE"              // First word fall-through
)
(
    input                   i_clk            , // Clock signal
    input                   i_rst_n          , // Source domain asynchronous reset (active low)
    input                   i_valid_s        , // Request write data into FIFO
    input  [ADDR_WIDTH-1:0] i_almostfull_lvl , // The number of empty memory locations in the FIFO at which the o_almostfull flag is active
    input  [DATA_WIDTH-1:0] i_datain         , // Push data in FIFO
    input                   i_ready_m        , // Request read data from FIFO
    input  [ADDR_WIDTH-1:0] i_almostempty_lvl, // The number of empty memory locations in the FIFO at which the o_almostempty flag is active
    output                  o_ready_s        , // Status write data into FIFO (if FIFO not full then o_ready_s = 1)                 
    output                  o_almostfull     , // FIFO almostfull flag (determined by i_almostfull_lvl)
    output                  o_full           , // FIFO full flag
    output                  o_valid_m        , // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
    output                  o_almostempty    , // FIFO almostempty flag (determined by i_almostempty_lvl)
    output                  o_empty          , // FIFO empty flag
    output [DATA_WIDTH-1:0] o_dataout          // Pop data from FIFO
);

    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire [  ADDR_WIDTH:0] wptr, rptr, wq2_rptr, rq2_wptr;
    
    // Flag ready for writing data
    assign o_ready_s = (~o_full);

    // Flag valid for reading data
    assign o_valid_m = (~o_empty);

    // The module handling the write requests
    wptr_full
    #(ADDR_WIDTH)
    wptr_full (
    .awfull   (o_almostfull),
    .wfull    (o_full),
    .waddr    (waddr),
    .wptr     (wptr),
    .wq2_rptr (rptr),
    .winc     (i_valid_s),
    .wclk     (i_clk),
    .wrst_n   (i_rst_n)
    );

    // The DC-RAM 
    fifomem
    #(DATA_WIDTH, ADDR_WIDTH, FALLTHROUGH)
    fifomem (
    .rclken (i_ready_m),
    .rclk   (i_clk),
    .rdata  (o_dataout),
    .wdata  (i_datain),
    .waddr  (waddr),
    .raddr  (raddr),
    .wclken (i_valid_s),
    .wfull  (o_full),
    .wclk   (i_clk)
    );

    // The module handling read requests
    rptr_empty
    #(ADDR_WIDTH)
    rptr_empty (
    .arempty  (o_almostempty),
    .rempty   (o_empty),
    .raddr    (raddr),
    .rptr     (rptr),
    .rq2_wptr (wptr),
    .rinc     (i_ready_m),
    .rclk     (i_clk),
    .rrst_n   (i_rst_n)
    );

endmodule

`resetall
