################################################################################
# User-defined Project Path
################################################################################
set TOP_LEVEL_MODULE  sync_fifo
set PROJECT_DIR       ../../sync_fifo
set SCRIPT_DIR        ../../sync_fifo/syn/dc_scripts

################################################################################
# RTL Source code
################################################################################
set RTL_SOURCE         $PROJECT_DIR/hdl
set INCLUDE_SOURCE     $PROJECT_DIR/inc
set TOP_MODULE_FILE    ${RTL_SOURCE}/sync_fifo.v

##########################################################################################
# User-defined variables for logical library setup in dc_setup.tcl
##########################################################################################
set SOURCE_PATH "$RTL_SOURCE $INCLUDE_SOURCE";

set ADDITIONAL_SEARCH_PATH        "ref/libs/mw_lib/sc/LM $RTL_SOURCE $INCLUDE_SOURCE" ;# Directories containing logical libraries,
                                                                                          # logical design and script files.

set TARGET_LIBRARY_FILES          sc_max.db                   ;#  Logical technology library file

set SYMBOL_LIBRARY_FILES          sc.sdb                      ;#  Symbol library file

##########################################################################################
# User-defined variables for physical library setup in dc_setup.tcl
##########################################################################################

set MW_DESIGN_LIB                  SYNC_FIFO_LIB                      ;# User-defined Milkyway design library name

set MW_REFERENCE_LIB_DIRS         ref/libs/mw_lib/sc                 ;# Milkyway reference libraries

set TECH_FILE                     ref/libs/tech/cb13_6m.tf           ;#  Milkyway technology file

set TLUPLUS_MAX_FILE              ref/libs/tlup/cb13_6m_max.tluplus  ;#  Max TLUPlus file

set MAP_FILE                      ref/libs/tlup/cb13_6m.map          ;#  Mapping file for TLUplus

################################################################################
# Clock Information
################################################################################

set CLOCK_PERIOD         4.85  
set MAX_SKEW             [expr {$CLOCK_PERIOD * 0.05}]
set MAX_JITTER_TIME      [expr {$CLOCK_PERIOD * 0.02}]
set MARGIN_TIME          [expr {$CLOCK_PERIOD * 0.02}]
set MAX_TRANSITION_TIME  [expr {$CLOCK_PERIOD * 0.1 }]