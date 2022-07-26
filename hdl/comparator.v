`include "../inc/sync_fifo_defines.vh"

module comparator #(
	parameter FIFO_DEPTH = `FIFO_DEPTH       , // FIFO depth
	parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)  // Address width
)
(
	input					clk              , // Clock signal
	input					reset_n          , // Source domain asynchronous reset (active low)
	input                   i_valid_s        ,
	input                   i_ready_m        , // Request read data from FIFO
	input  [ADDR_WIDTH:0]   wr_addr          , // Write address
	input  [ADDR_WIDTH:0]   rd_addr          , // Read address
	input  [ADDR_WIDTH-1:0] i_almostfull_lvl , // The number of empty memory locations in the FIFO at which the o_almostfull flag is active
	input  [ADDR_WIDTH-1:0] i_almostempty_lvl, // The number of empty memory locations in the FIFO at which the o_almostempty flag is active
	output                  o_ready_s        , // Status write data into FIFO (if FIFO not full then o_ready_s = 1)					
	output                  o_almostfull     , // FIFO almostfull flag (determined by i_almostfull_lvl)
	output reg              o_full           , // FIFO full flag
	output                  o_valid_m        , // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
	output                  o_almostempty    , // FIFO almostempty flag (determined by i_almostempty_lvl)
	output reg              o_empty            // FIFO empty flag
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
	always @(posedge clk or negedge reset_n) begin : proc_o_full
		if(~reset_n) begin
			o_full <= 0;
		end else if ((((num_elements == (FIFO_DEPTH-1)) & i_valid_s) | (num_elements == FIFO_DEPTH))  & (!i_ready_m)) begin
			o_full <= 1;
		end
		else begin
			o_full <= 0;
		end
	end


	// Flag FIFO almost empty
	assign o_almostempty = (num_elements <= i_almostempty_lvl);

	// Flag FIFO empty
	always @(posedge clk or negedge reset_n) begin : proc_o_empty
		if(~reset_n) begin
			o_empty <= 1;
		end else if ((((num_elements == 1) & i_ready_m) | (num_elements == 0)) & (!i_valid_s)) begin
			o_empty <= 1;
		end
		else begin
			o_empty <= 0;
		end
	end

	// Flag ready for writing data
	assign o_ready_s = (~o_full);

	// Flag valid for reading data
	assign o_valid_m = (~o_empty);

endmodule