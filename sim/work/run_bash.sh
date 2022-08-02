#!/bin/bash:

TOP_TB=sync_fifo_tb

# prepare for sim
alias vlb='reset; rm -rf  wlft*  vsim.wlf; rm -rf work; vlib work'

# compile source code
alias vlgr='vlog +cover=bcefs -f filelist_rtl.f -l ./log/vlogr.log'
alias vlgt='vlog -f filelist_tb.f -l ./log/vlogt.log'

# run simulation
alias vsm='vsim -c work.${TOP_TB} -wlf vsim.wlf -voptargs=+acc -l ./log/vsim.log -do "add wave -r /${TOP_TB}/*; run -all; quit"'
alias viw='vsim -view vsim.wlf -do wave.do &'
alias vc='mkdir log; vlb; vlgr; vlgt; vsm'
vc

