# This file has been edited to keep it simple
source -echo -verbose ./dc_scripts/common_setup.tcl
source -echo -verbose ./dc_scripts/dc_setup.tcl

printvar target_library
printvar link_library

#################################################################################
# Read in the RTL Design
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

analyze $SOURCE_PATH -autoread
analyze -vcs "-sverilog -y $RTL_SOURCE +libext+.v+.sv" ${TOP_MODULE_FILE}  
elaborate ${TOP_LEVEL_MODULE} -lib work
# Compile Top module
current_design ${TOP_LEVEL_MODULE}
check_design > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_check_design.rpt
link

#################################################################################
# Read contraint file
#################################################################################
source -echo -verbose ./dc_scripts/constraints.tcl

set_cost_priority -delay
#set_preferred_routing_direction -layer {METAL METAL2 METAL3 METAL4 METAL5 METAL6} -direction horizontal
compile_ultra 

#################################################################################
# Write out Design
#################################################################################
write -format ddc     -hierarchy -output ${RESULTS_DIR}/${TOP_LEVEL_MODULE}_netlist.ddc
write -format verilog -hierarchy -output ${RESULTS_DIR}/${TOP_LEVEL_MODULE}_netlist.v

################################################################################
# Generate Final Reports
#################################################################################
check_timing > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_check_timing.rpt
report_timing -nworst 100 -sort_by slack  > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_final_timing.rpt
report_constraint -all_violators > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_final_constraints.rpt
report_qor > reports/sync_fifo_final_qor.rpt
if {[shell_is_in_topographical_mode]} {
  report_area -physical -nosplit > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_final_area.rpt
} else {
  report_area -nosplit > ${REPORTS_DIR}/${TOP_LEVEL_MODULE}_final_area.rpt
}
#exit