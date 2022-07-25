`include "sync_fifo_defines.vh"

module write_control #(
	parameter DATA_WIDTH = `DATA_WIDTH
)
(
	input                 clk     , // Clock signal
	input                 reset_n , // Source domain asynchronous reset (active low)
	input                 wr_valid, // Request write data into FIFO
	input                 wr_full , // FIFO full flag
	output                wr_en   , // Write data
	output [ADDR_WIDTH:0] wr_addr   // Write address
);

	//============================================
	//               Write address
	//============================================

	always @(posedge clk or negedge reset_n) begin : proc_wr_addr
		if(~reset_n) begin
			wr_addr <= 0;
		end else begin
			wr_addr <= wr_en ? wr_addr + 1 : wr_addr;
		end
	end

	//============================================
	//                Write enable
	//============================================

	assign wr_en = wr_valid & (!wr_full);

endmodule