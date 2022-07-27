`include "../../inc/sync_fifo_defines.vh"

module sync_fifo_model #(
	parameter FIFO_DEPTH = `FIFO_DEPTH       , // FIFO depth
	parameter DATA_WIDTH = `DATA_WIDTH       , // Data width
	parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)  // Address width
)
(
	input                    			i_clk            , // Clock signal
	input                    			i_rst_n          , // Source domain asynchronous reset (active low)
	input                    			i_valid_s        , // Request write data into FIFO
	input  [ADDR_WIDTH-1:0]  			i_almostfull_lvl , // The number of empty memory locations in the FIFO at which the o_almostfull flag is active
	input  [DATA_WIDTH-1:0]  			i_datain         , // Push data in FIFO
	input                    			i_ready_m        , // Request read data from FIFO
	input  [ADDR_WIDTH-1:0]  			i_almostempty_lvl, // The number of empty memory locations in the FIFO at which the o_almostempty flag is active
	output logic                  o_ready_s        , // Status write data into FIFO (if FIFO not full then o_ready_s = 1)					
	output logic                  o_almostfull     , // FIFO almostfull flag (determined by i_almostfull_lvl)
	output logic                  o_full           , // FIFO full flag
	output logic                  o_valid_m        , // Status read data from FIFO (if FIFO not empty then o_valid_m = 1)
	output logic                  o_almostempty    , // FIFO almostempty flag (determined by i_almostempty_lvl)
	output logic                  o_empty          , // FIFO empty flag
	output logic [DATA_WIDTH-1:0] o_dataout          // Pop data from FIFO
);
	logic [ADDR_WIDTH:0]     size;
	logic [DATA_WIDTH - 1:0] fifo_mem [$:FIFO_DEPTH];

	assign o_valid_m = ~o_empty;
	assign o_ready_s = ~o_full ;

	initial begin 
		$display("==================================================");
		$display("Synchronous FIFO model");
		$display("FIFO_DEPTH :%d", FIFO_DEPTH);
		$display("DATA_WIDTH :%d", DATA_WIDTH);
		$display("==================================================\n");
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if(~i_rst_n) begin
			fifo_mem.delete();
		end
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if(~i_rst_n) begin
			o_almostfull   = 1'b0;
			o_full         = 1'b0;
			o_almostempty  = 1'b1;
			o_empty        = 1'b1;
		end else begin
			size = fifo_mem.size(); // update fifo size
			// write to FIFO
			if(i_valid_s && (size !=  FIFO_DEPTH)) begin 
				fifo_mem.push_front(i_datain);
			end		
			//read from FIFO
			if(i_ready_m && (size!=  0)) begin 
				fifo_mem.pop_back();
			end

			size = fifo_mem.size(); // update fifo size
			// Flag FIFO full
			if (size == FIFO_DEPTH) begin
				o_full = 1'b1;
				$display("@(%t): FIFO full!!", $realtime());
			end else  begin 
				o_full = 1'b0;
			end

			if(size >= i_almostfull_lvl) begin 
				o_almostfull = 1'b1;
				$display("@(%t): FIFO almost full with almostfull_lvl = %d", $realtime(), i_almostfull_lvl);
			end else begin 
				o_almostfull = 1'b0;
			end
			
			// Flag FIFO empty
			if (size == 0) begin
				o_empty = 1'b1;
				o_dataout = 'x;
				$display("@(%t): FIFO empty!! => o_dataout invalid", $realtime());
			end else begin 
				o_empty = 1'b0;
			end

			if(size <= i_almostempty_lvl) begin 
				o_almostempty = 1'b1;
				$display("@(%t): FIFO almost empty with almostempty_lvl = %d", $realtime(), i_almostempty_lvl);
			end else begin 
				o_almostempty = 1'b0;
			end
			o_dataout = fifo_mem[$];
		end
	end

	//check
	always @(*) begin 
		if(i_almostfull_lvl > FIFO_DEPTH) begin 
			$display("ERROR: i_almostfull_lvl invalid at %t", $realtime());
			$stop();
		end
		if(i_almostempty_lvl > FIFO_DEPTH) begin 
			$display("ERROR: i_almostempty_lvl invalid at %t", $realtime());
			$stop();
		end
	end

	always_ff @(posedge i_clk) begin
		if(o_empty && i_ready_m) begin 
			$display("ERROR: FIFO is empty, cannot be read at %t", $realtime());
		end

		if(o_full && i_valid_s) begin 
			$display("ERROR: FIFO is full, cannot be write at %t", $realtime());
		end

		if((i_datain =='x) && i_valid_s) begin 
			$display("ERROR: datain invalid %t", $realtime());
		end

	end	

endmodule