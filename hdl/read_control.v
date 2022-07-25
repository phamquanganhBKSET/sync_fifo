`include "sync_fifo_defines.vh"

module read_control #(
	parameter DATA_WIDTH = `DATA_WIDTH
)
(
	input                 clk     , // Clock signal
	input                 reset_n , // Source domain asynchronous reset (active low)
	input                 rd_ready, // Request read data from FIFO
	input                 rd_empty, // FIFO empty flag
	output [ADDR_WIDTH:0] rd_addr   // Read address
);

	//============================================
	//      Internal signals and variables
	//============================================

	wire rd_en; // Read enable

	//============================================
	//               Read address
	//============================================

	always @(posedge clk or negedge reset_n) begin : proc_rd_addr
		if(~reset_n) begin
			rd_addr <= 0;
		end else begin
			rd_addr <= rd_en ? rd_addr + 1 : rd_addr;
		end
	end

	//============================================
	//                Read enable
	//============================================

	assign rd_en = rd_ready & (!rd_empty);

endmodule