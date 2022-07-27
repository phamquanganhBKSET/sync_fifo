`include "../inc/sync_fifo_defines.vh"

module sync_fifo_mem #(
	parameter MEM_DEPTH  = `FIFO_DEPTH      , // Memory depth
	parameter DATA_WIDTH = `DATA_WIDTH      , // Data width
	parameter ADDR_WIDTH = $clog2(MEM_DEPTH) // Address width
)
(
	input					clk    , // Clock signal
	input					reset_n, // Synchonous reset
	input  [DATA_WIDTH-1:0] wr_data, // Write data
	input  [ADDR_WIDTH-1:0] wr_addr, // Write address
	input					wr_en  , // Write enable
	input  [ADDR_WIDTH-1:0] rd_addr, // Read address
	output [DATA_WIDTH-1:0] rd_data  // Read data
);

	//============================================
	//      Internal signals and variables
	//============================================

	reg [DATA_WIDTH-1:0] fifo_mem [0:MEM_DEPTH-1]; // FIFO memory
                                                 // Number of elements: MEM_DEPTH
                                                 // Data width of each element: DATA_WIDTH 

	//============================================
	//               Read data
	//============================================

	assign rd_data = fifo_mem[rd_addr];

	//============================================
	//           Write data to memory
	//============================================

	always @(posedge clk) begin : proc_wr_data
		fifo_mem[wr_addr] <= wr_en ? wr_data : fifo_mem[wr_addr];
	end

endmodule