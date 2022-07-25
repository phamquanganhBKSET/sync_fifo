`include "sync_fifo_defines.vh"

module sync_fifo #(
	parameter FIFO_DEPTH = `FIFO_DEPTH       , // FIFO depth
	parameter DATA_WIDTH = `DATA_WIDTH       , // Data width
	parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)  // Address width
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
	output [FIFO_DEPTH-1:0] o_dataout          // Pop data from FIFO
);

	//============================================
	//      Internal signals and variables
	//============================================

	wire [ADDR_WIDTH:0] wr_addr; // Write address (Write pointer)
	wire [ADDR_WIDTH:0] rd_addr; // Read address (Read pointer)
	wire                wr_en  ; // Write enable

	//============================================
	//        Synchronous FIFO memory
	//============================================

	sync_fifo_mem sync_fifo_mem_inst (
		.clk    (i_clk                  ),
		.reset_n(i_rst_n                ),
		.wr_data(i_datain               ),
		.wr_addr(wr_addr[ADDR_WIDTH-1:0]),
		.wr_en  (wr_en                  ),
		.rd_addr(rd_addr[ADDR_WIDTH-1:0]),
		.rd_data(o_dataout              ) 
	);

	//============================================
	//             Write control
	//============================================

	write_control write_control_inst (
		.clk     (i_clk    ),
		.reset_n (i_rst_n  ),
		.wr_valid(i_valid_s),
		.wr_full (o_full   ),
		.wr_en   (wr_en    ),
		.wr_addr (wr_addr  ) 
	);

	//============================================
	//             Read control
	//============================================

	read_control read_control_inst (
		.clk     (i_clk    ),
		.reset_n (i_rst_n  ),
		.rd_ready(o_ready_s),
		.rd_empty(o_empty  ),
		.rd_addr (rd_addr  ) 
	);

	//============================================
	//             Comparator
	//============================================

	comparator comparator_inst (
		.wr_addr          (wr_addr          ),
		.rd_addr          (rd_addr          ),
		.i_almostfull_lvl (i_almostfull_lvl ),
		.i_almostempty_lvl(i_almostempty_lvl),
		.o_almostfull     (o_almostfull     ),
		.o_full           (o_full           ),
		.o_almostempty    (o_almostempty    ),
		.o_empty          (o_empty          ) 
	);

endmodule