`include "../inc/sync_fifo_defines.vh"

module comparator #(
	parameter FIFO_DEPTH = `FIFO_DEPTH       , // FIFO depth
	parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)  // Address width
)
(
	input  [ADDR_WIDTH:0]   wr_addr          , // Write address
	input  [ADDR_WIDTH:0]   rd_addr          , // Read address
	input  [ADDR_WIDTH-1:0] i_almostfull_lvl , // The number of empty memory locations in the FIFO at which the o_almostfull flag is active
	input  [ADDR_WIDTH-1:0] i_almostempty_lvl, // The number of empty memory locations in the FIFO at which the o_almostempty flag is active
	output                  o_ready_s        , // Status write data into FIFO (if FIFO not full then o_ready_s = 1)					
	output                  o_almostfull     , // FIFO almostfull flag (determined by i_almostfull_lvl)
	output                  o_full           , // FIFO full flag
	output                  o_valid_m        , // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
	output                  o_almostempty    , // FIFO almostempty flag (determined by i_almostempty_lvl)
	output                  o_empty            // FIFO empty flag
);

	//============================================
	//      Internal signals and variables
	//============================================

	wire [ADDR_WIDTH:0] num_elements; // Number of elements

	//============================================
	//            Number of elements
	//============================================

	assign num_elements = wr_addr + ((~rd_addr) + 1); // Number of elements = write address - read address

	//============================================
	//                  Flags
	//============================================

	// Flag FIFO almost full
	assign o_almostfull = (num_elements >= i_almostfull_lvl);

	// Flag FIFO full
	assign o_full = (num_elements == FIFO_DEPTH);

	// Flag FIFO almost empty
	assign o_almostempty = (num_elements <= i_almostempty_lvl);

	// Flag FIFO empty
	assign o_empty = (num_elements == 0);

	// Flag ready for writing data
	assign o_ready_s = (~o_full);

	// Flag valid for reading data
	assign o_valid_m = (~o_empty);

endmodule