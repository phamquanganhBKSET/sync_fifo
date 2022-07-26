reset_design

set lib_name cb13fs120_tsmc_max

# Create clock with specify frequency as you choice, with waveform pattern: 0ns: falling edge; T/2 ns: rising edge; T ns: falling edge
create_clock -period $CLOCK_PERIOD [get_ports i_clk]

# Clock has max skew equal 5% of clock cycle
# Clock has max jitter equal 2% of clock cycle
# Timing margin equal 2% of clock cycle
set_clock_uncertainty -setup [expr {2 * $MAX_SKEW + $MAX_JITTER_TIME + $MARGIN_TIME}] [get_ports i_clk]

 #Clock has max transition time equal 10% clock cycle
set_clock_transition -max $MAX_TRANSITION_TIME [get_clock i_clk]

# Clock has source latency, maximum time about 1.2ns
set_clock_latency -source -max 1.2 [get_clock i_clk]

#All data from external block consume 40% clock cycle before goto input pins of synchronus FIFO.
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_rst_n           ]
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_valid_s         ]
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_almostfull_lvl* ]
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_datain*         ]
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_ready_m         ]
set_input_delay -max [expr {$CLOCK_PERIOD * 0.4}] -clock i_clk [get_ports i_almostempty_lvl*]

# External block need 60% clock cycle to capture data without error from FIFO output.
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_ready_s    ]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_almostfull ]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_full       ]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_valid_m    ]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_almostempty]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_empty      ]
set_output_delay -max [expr {$CLOCK_PERIOD * 0.6}] -clock i_clk [get_ports o_dataout*   ]