`include "sync_fifo_defines.vh"

module sync_fifo_model #(
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
	output [DATA_WIDTH-1:0] o_dataout          // Pop data from FIFO
);

	//============================================
	//      Internal signals and variables
	//============================================

	reg  [DATA_WIDTH-1:0] fifo_mem [0:DATA_WIDTH-1]; // FIFO memory
		 											 // Number of elements: MEM_DEPTH
		 											 // Data width of each element: DATA_WIDTH
	reg  [ADDR_WIDTH:0]   wr_ptr                   ; // Write pointer (Write address)
	reg  [ADDR_WIDTH:0]   rd_ptr                   ; // Read pointer (Read address)
	wire [ADDR_WIDTH:0]   num_elements             ; // Number of elements

	//============================================
	//           Write data control
	//============================================

	// Write pointer
	always @(posedge i_clk or negedge i_rst_n) begin : proc_wr_ptr
		if(~i_rst_n) begin
			wr_ptr <= 0;
		end else begin
			wr_ptr <= (i_valid_s & (!o_full)) ? wr_ptr + 1 : wr_ptr;
		end
	end

	// FIFO memory
	always @(posedge i_clk or negedge i_rst_n) begin : proc_fifo_mem
		if(~i_rst_n) begin
			fifo_mem <= 0;
		end else begin
			fifo_mem[wptr[ADDR_WIDTH-1:0]] <= (i_valid_s & (!o_full)) ? i_datain : fifo_mem[wr_ptr[ADDR_WIDTH-1:0]];
		end
	end

	//============================================
	//            Read data control
	//============================================

	// Read pointer
	always @(posedge i_clk or negedge i_rst_n) begin : proc_rd_ptr
		if(~i_rst_n) begin
			rd_ptr <= 0;
		end else begin
			rd_ptr <= (i_ready_m & (!o_empty)) ? rd_ptr + 1 : rd_ptr;
		end
	end

	// Read data
	assign o_dataout = fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];

	//============================================
	//                  Flags
	//============================================

	// Number of elements
	assign num_elements = wr_ptr + ((~rd_ptr) + 1); // Number of elements = write pointer - read pointer

	// Flag FIFO almost full
	assign o_almostfull = (num_elements[ADDR_WIDTH-1:0] >= i_almostfull_lvl);

	// Flag FIFO full
	assign o_full = (num_elements[ADDR_WIDTH-1:0] == FIFO_DEPTH);

	// Flag FIFO almost empty
	assign o_almostempty = (num_elements[ADDR_WIDTH-1:0] <= i_almostempty_lvl);

	// Flag FIFO empty
	assign o_empty = (num_elements == 0);

	// Flag ready for writing data
	assign o_ready_s = (~o_full);

	// Flag valid for reading data
	assign o_valid_m = (~o_empty);

endmodule