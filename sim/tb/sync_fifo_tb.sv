`include "../../inc/sync_fifo_defines.vh"

`timescale 1ns/1ps

module sync_fifo_tb 
#(
	parameter FIFO_DEPTH = `FIFO_DEPTH       , // FIFO depth
	parameter DATA_WIDTH = `DATA_WIDTH       , // Data width
	parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)  // Address width
) ();

logic                   i_clk            ; // Clock signal
logic                   i_rst_n          ; // Source domain asynchronous reset (active low)
logic                   i_valid_s        ; // Request write data into FIFO
logic  [ADDR_WIDTH-1:0] i_almostfull_lvl ; // The number of empty memory locations in the FIFO at which the o_almostfull flag is active
logic  [DATA_WIDTH-1:0] i_datain         ; // Push data in FIFO
logic                   i_ready_m        ; // Request read data from FIFO
logic  [ADDR_WIDTH-1:0] i_almostempty_lvl; // The number of empty memory locations in the FIFO at which the o_almostempty flag is active
wire                    o_ready_s        ; // Status write data into FIFO (if FIFO not full then o_ready_s = 1)
wire                    o_almostfull     ; // FIFO almostfull flag (determined by i_almostfull_lvl)
wire                    o_full           ; // FIFO full flag
wire                    o_valid_m        ; // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
wire                    o_almostempty    ; // FIFO almostempty flag (determined by i_almostempty_lvl)
wire                    o_empty          ; // FIFO empty flag
wire   [DATA_WIDTH-1:0] o_dataout        ; // Pop data from FIFO

wire                    mo_ready_s       ; // Model: Status write data into FIFO (if FIFO not full then o_ready_s = 1)
wire                    mo_almostfull    ; // Model: FIFO almostfull flag (determined by i_almostfull_lvl)
wire                    mo_full          ; // Model: FIFO full flag
wire                    mo_valid_m       ; // Model: Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
wire                    mo_almostempty   ; // Model: FIFO almostempty flag (determined by i_almostempty_lvl)
wire                    mo_empty         ; // Model: FIFO empty flag
wire   [DATA_WIDTH-1:0] mo_dataout       ; // Model: Pop data from FIFO

reg 					err_ready_s    	 ; // Status write data into FIFO (if FIFO not full then o_ready_s = 1)
reg 					err_full       	 ; // FIFO full flag
reg 					err_valid_m    	 ; // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
reg 					err_empty      	 ; // FIFO empty flag
reg 					err_dataout    	 ; // Pop data from FIFO

always_ff @(posedge i_clk or negedge i_rst_n) begin : proc_err
    if(~i_rst_n) begin
        err_ready_s <= 0;
        err_full    <= 0;
        err_valid_m <= 0;
        err_empty   <= 0;
        err_dataout <= 0;
    end else begin
        err_ready_s <= (o_ready_s !== mo_ready_s);
        err_full    <= (o_full    !== mo_full   );
        err_valid_m <= (o_valid_m !== mo_valid_m);
        err_empty   <= (o_empty   !== mo_empty  );
        err_dataout <= o_empty ? 0 : (o_dataout !== mo_dataout);
    end
end

sync_fifo #(
	.FIFO_DEPTH(FIFO_DEPTH), // FIFO depth
	.DATA_WIDTH(DATA_WIDTH), // Data width
	.ADDR_WIDTH(ADDR_WIDTH)  // Address width
) DUT (
	.i_clk            (i_clk            ),
	.i_rst_n          (i_rst_n          ),
	.i_valid_s        (i_valid_s        ),
	.i_ready_m        (i_ready_m        ),
	.i_almostempty_lvl(i_almostempty_lvl),
	.i_almostfull_lvl (i_almostfull_lvl ),
	.i_datain         (i_datain         ),
	.o_almostfull     (o_almostfull     ),
	.o_full           (o_full           ),
	.o_ready_s        (o_ready_s        ),
	.o_valid_m        (o_valid_m        ),
	.o_almostempty    (o_almostempty    ),
	.o_empty          (o_empty          ),
	.o_dataout        (o_dataout        )
);

sync_fifo_model #(
	.FIFO_DEPTH(FIFO_DEPTH), // FIFO depth
	.DATA_WIDTH(DATA_WIDTH), // Data width
	.ADDR_WIDTH(ADDR_WIDTH)  // Address width
) model (
	.i_clk            (i_clk             ),
	.i_rst_n          (i_rst_n           ),
	.i_valid_s        (i_valid_s         ),
	.i_ready_m        (i_ready_m         ),
	.i_almostempty_lvl(i_almostempty_lvl ),
	.i_almostfull_lvl (i_almostfull_lvl  ),
	.i_datain         (i_datain          ),
	.o_almostfull     (mo_almostfull     ),
	.o_full           (mo_full           ),
	.o_ready_s        (mo_ready_s        ),
	.o_valid_m        (mo_valid_m        ),
	.o_almostempty    (mo_almostempty    ),
	.o_empty          (mo_empty          ),
	.o_dataout        (mo_dataout        )
);

always #10 i_clk = ~i_clk;

initial begin 
    i_clk             = 0;
    i_rst_n           = 0;
    i_valid_s         = 0;
    i_ready_m         = 0;
    i_almostempty_lvl = 2;
    i_almostfull_lvl  = 5;
    i_datain          = 0;
    @(negedge i_clk);
    i_rst_n = 1;
    // Read and write simultaneously when FIFO is empty
    repeat(10) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_datain = $random();
    i_valid_s = 1;
    @(negedge i_clk);
    i_valid_s = 0;
    @(negedge i_clk);
    i_datain = $random();
    i_valid_s = 1;
    // Write to overflow
    repeat(5) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    // Read to empty
    repeat(10) begin
        @(negedge i_clk);
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_ready_m = 0;
    // Write to full
    repeat(10) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    // Read and write simultaneously when FIFO is full
    repeat(10) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    i_ready_m = 0;
    // Read data
    repeat(5) begin
        @(negedge i_clk);
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_ready_m = 0;
    // Read and write simultaneously when FIFO is not full
    repeat(10) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    i_ready_m = 0;
    // Write -> read when FIFO is not full
    repeat(10) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
        i_ready_m = 0;
        @(negedge i_clk);
        i_valid_s = 0;
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    i_ready_m = 0;
    // Read data
    repeat(2) begin
        @(negedge i_clk);
        i_ready_m = 1;
    end
    @(negedge i_clk);
    i_ready_m = 0;
    // Write data
    repeat(5) begin
        @(negedge i_clk);
        i_datain = $random();
        i_valid_s = 1;
    end
    @(negedge i_clk);
    i_valid_s = 0;
    // Read to empty
    repeat(10) begin
        i_ready_m = 1;
        @(negedge i_clk);
    end
    i_ready_m = 0;
    
    @(negedge i_clk);
    i_valid_s = 0;
    i_ready_m = 0;
    $stop();
end
endmodule