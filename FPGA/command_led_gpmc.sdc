#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 11.1 Build 259 01/25/2012 Service Pack 2 SJ Full Version
#
#************************************************************

# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk12" -period 83.333ns [get_ports {clk12}]
create_clock -name "gumstix_clk" -period 24ns [get_ports {gumstix_clk}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu
set_max_delay -from [all_inputs] -to [get_registers *] 5.000ns

# tco
set_max_delay -from [get_registers *] -to [all_outputs] 15.000ns

#tpd
set_max_delay -from [all_inputs] -to [all_outputs] 15.000ns

# tpd constraints
#set_max_delay 20.000ns -from [get_ports {*}] -to [get_ports {*}]
#set_min_delay 1.000ns -from [get_ports {*}] -to [get_ports {*}]

# Remove async reset checking
set_false_path -from [get_registers {count*}] -to [get_registers *]
