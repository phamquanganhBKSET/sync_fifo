`include "sync_fifo_defines.vh"

module sync_fifo_tb 
#(
	parameter FIFO_DEPTH = 8,
	parameter DATA_WIDTH = 32,
	parameter WIDTH      = 8
) ();

logic                  i_clk            ;
logic                  i_rst_n          ;
logic                  i_valid_s        ;
logic                  i_ready_m        ;
logic [WIDTH-1:0]      i_almostempty_lvl;
logic [WIDTH-1:0]      i_almostfull_lvl ;
logic [DATA_WIDTH-1:0] i_datain         ;
wire                   o_almostfull     ;
wire                   o_full           ;
wire                   o_ready_s        ;
wire                   o_valid_m        ;
wire                   o_almostempty    ;
wire                   o_empty          ;
wire  [DATA_WIDTH-1:0] o_dataout        ;


sync_fifo #(
	.FIFO_DEPTH (FIFO_DEPTH),
	.DATA_WIDTH (DATA_WIDTH),
	.WIDTH      (WIDTH)
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
	i_datain = $random();
	i_valid_s = 1;
	@(negedge i_clk);
	i_valid_s = 0;
	@(negedge i_clk);
	i_datain = $random();
	i_valid_s = 1;

	// Write to overflow
	repeat(10) begin
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

	// Write data
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

	// Read and write simultaneously when FIFO is empty
	repeat(10) begin
		@(negedge i_clk);
		i_datain = $random();
		i_valid_s = 1;
		i_ready_m = 1;
	end
	@(negedge i_clk);
	i_valid_s = 0;
	i_ready_m = 0;

	$finish();
end

endmodule