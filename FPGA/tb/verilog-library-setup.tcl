#This file contains the commands to create libraries and compile the library file into those libraries.

set path_to_quartus /opt/altera/quartus/
set type_of_sim compile_all

# The type_of_sim should be one of the following values
# compile_all: Compiles all Altera libraries 
# functional: Compiles all libraries that are required for a functional simulation
# ip_functional: Compiles all libraries that are required functional simulation of Altera IP cores
# stratix_gx: Compiles all libraries that are required for a functional simulation of a StratixGX design
# apex20ke: Compiles all libraries that are required for an APEX20KE timing simulation
# apex20k: Compiles all libraries that are required for an APEX20K timing simulation
# apexii: Compiles all libraries that are required for an APEXII timing simulation
# cyclone: Compiles all libraries that are required for an CYCLONE timing simulation
# cycloneii: Compiles all libraries that are required for an CYCLONEII timing simulation
# cycloneiii: Compiles all libraries that are required for an CYCLONEIII timing simulation
# flex10ke: Compiles all libraries that are required for an FLEX10KE timing simulation
# flex6000: Compiles all libraries that are required for an FLEX6000 timing simulation
# hardcopy: Compiles all libraries that are required for an HARDCOPY timing simulation
# hardcopyii: Compiles all libraries that are required for an HARDCOPYII timing simulation
# max: Compiles all libraries that are required for an MAX timing simulation
# maxii: Compiles all libraries that are required for an MAXII timing simulation
# mercury: Compiles all libraries that are required for an MERCURY timing simulation
# stratix: Compiles all libraries that are required for an STRATIX timing simulation
# stratixii: Compiles all libraries that are required for an STRATIXII timing simulation
# stratixiii: Compiles all libraries that are required for an STRATIXIII timing simulation
# stratixgx_timing: Compiles all libraries that are required for an STRATIXGX timing simulation
# stratixiigx_timing: Compiles all libraries that are required for an STRATIXIIGX timing simulation
# arriagx_timing: Compiles all libraries that are required for an ARRIAGX timing simulation

if {[string equal $type_of_sim "compile_all"]} {
# compiles all libraries
	vlib lpm_ver
	vlib altera_mf_ver	
	vlib altera_prim_ver	
	vlib sgate_ver
	vlib altgxb_ver
	vlib stratixgx_gxb_ver
	vlib stratixgx_ver
	vlib stratixiigx_hssi_ver
	vlib stratixiigx_ver
	vlib arriagx_gxb_ver
	vlib arriagx_ver
	vlib apex20ke_ver
	vlib apex20k_ver
	vlib apexii_ver
	vlib cyclone_ver
	vlib cycloneii_ver
	vlib cycloneiii_ver
	vlib flex10ke_ver
	vlib flex6000_ver
	vlib hcstratix_ver
	vlib hardcopyii_ver
	vlib max_ver
	vlib maxii_ver
	vlib mercury_ver
	vlib stratix_ver
	vlib stratixii_ver
	vlib stratixiii_ver
	vmap lpm_ver lpm_ver
	vmap altera_mf_ver altera_mf_ver
	vmap sgate_ver sgate_ver
	vmap altgxb_ver altgxb_ver	
	vmap stratixgx_ver stratixgx_ver
	vmap stratixgx_gxb_ver stratixgx_gxb_ver
	vmap apex20k_ver apex20k_ver
	vmap apexii_ver apexii_ver
	vmap cyclone_ver cyclone_ver	
	vmap cycloneii_ver cycloneii_ver
	vmap cycloneiii_ver cycloneiii_ver
	vmap flex10ke_ver flex10ke_ver	
	vmap flex6000_ver flex6000_ver
	vmap hcstratix_ver hcstratix_ver
	vmap hardcopyii_ver hardcopyii_ver
	vmap max_ver max_ver
	vmap maxii_ver maxii_ver
	vmap mercury_ver mercury_ver
	vmap stratix_ver stratix_ver
	vmap stratixii_ver stratixii_ver
	vmap stratixiii_ver stratixiii_ver
	vmap stratixiigx_ver stratixiigx_ver
	vmap stratixiigx_hssi_ver stratixiigx_hssi_ver
	vmap arriagx_ver arriagx_ver
	vmap arriagx_gxb_ver arriagx_gxb_ver
	vmap altera_prim_ver altera_prim_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlog -work altgxb_ver $path_to_quartus/eda/sim_lib/stratixgx_mf.v
	vlog -work stratixgx_ver $path_to_quartus/eda/sim_lib/stratixgx_atoms.v
	vlog -work stratixgx_gxb_ver $path_to_quartus/eda/sim_lib/stratixgx_hssi_atoms.v
	vlog -work apex20ke_ver $path_to_quartus/eda/sim_lib/apex20ke_atoms.v
	vlog -work apex20k_ver $path_to_quartus/eda/sim_lib/apex20k_atoms.v
	vlog -work apexii_ver $path_to_quartus/eda/sim_lib/apexii_atoms.v	
	vlog -work cyclone_ver $path_to_quartus/eda/sim_lib/cyclone_atoms.v
	vlog -work cycloneii_ver $path_to_quartus/eda/sim_lib/cycloneii_atoms.v
	vlog -work cycloneiii_ver $path_to_quartus/eda/sim_lib/cycloneiii_atoms.v
	vlog -work flex10ke_ver $path_to_quartus/eda/sim_lib/flex10ke_atoms.v	
	vlog -work flex6000_ver $path_to_quartus/eda/sim_lib/flex6000_atoms.v
	vlog -work hcstratix_ver $path_to_quartus/eda/sim_lib/hcstratix_atoms.v
	vlog -work hardcopyii_ver $path_to_quartus/eda/sim_lib/hardcopyii_atoms.v
	vlog -work max_ver $path_to_quartus/eda/sim_lib/max_atoms.v
	vlog -work maxii_ver $path_to_quartus/eda/sim_lib/maxii_atoms.v
	vlog -work mercury_ver $path_to_quartus/eda/sim_lib/mercury_atoms.v
	vlog -work stratix_ver $path_to_quartus/eda/sim_lib/stratix_atoms.v
	vlog -work stratixii_ver $path_to_quartus/eda/sim_lib/stratixii_atoms.v
	vlog -work stratixiii_ver $path_to_quartus/eda/sim_lib/stratixiii_atoms.v
	vlog -work stratixiigx_ver $path_to_quartus/eda/sim_lib/stratixiigx_atoms.v
	vlog -work stratixiigx_hssi_ver $path_to_quartus/eda/sim_lib/stratixiigx_hssi_atoms.v
	vlog -work arriagx_ver $path_to_quartus/eda/sim_lib/arriagx_atoms.v
	vlog -work arriagx_gxb_ver $path_to_quartus/eda/sim_lib/arriagx_hssi_atoms.v
	vlog -work altera_prim_ver $path_to_quartus/eda/sim_lib/altera_primitives.v
} elseif {[string equal $type_of_sim "functional"]} {
# required for functional simulation of designs that call LPM & altera_mf functions
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib altera_mf_ver
	vmap altera_mf_ver altera_mf_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
} elseif {[string equal $type_of_sim "ip_functional"]} {
# required for IP functional simualtion of designs
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib altera_mf_ver
	vmap altera_mf_ver altera_mf_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
	vlib sgate_ver
	vmap sgate_ver sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
} elseif {[string equal $type_of_sim "stratix_gx"]} {
# required for functional simulation of STRATIXGX designs
	vlib sgate_ver
	vmap sgate_ver sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib altgxb_ver
	vmap altgxb_ver altgxb_ver	
	vlog -work altgxb_ver $path_to_quartus/eda/sim_lib/stratixgx_mf.v
} elseif {[string equal $type_of_sim "apex20ke"]} {
	# required for gate-level simulation of APEX20KE designs
	vlib apex20ke_ver
	vmap apex20ke_ver apex20ke_ver
	vlog -work apex20ke_ver $path_to_quartus/eda/sim_lib/apex20ke_atoms.v
} elseif {[string equal $type_of_sim "apex20k"]} {
	# required for gate-level simulation of APEX20K designs
	vlib apex20k_ver
	vmap apex20k_ver apex20k_ver
	vlog -work apex20k_ver $path_to_quartus/eda/sim_lib/apex20k_atoms.v
} elseif {[string equal $type_of_sim "apexii"]} {
	# required for gate-level simulation of APEXII designs
	vlib apexii_ver
	vmap apexii_ver apexii_ver
	vlog -work apexii_ver $path_to_quartus/eda/sim_lib/apexii_atoms.v
} elseif {[string equal $type_of_sim "cyclone"]} {
	# required for gate-level simulation of CYCLONE designs
	vlib cyclone_ver
	vmap cyclone_ver cyclone_ver
	vlog -work cyclone_ver $path_to_quartus/eda/sim_lib/cyclone_atoms.v
} elseif {[string equal $type_of_sim "cycloneii"]} {
	# required for gate-level simulation of CYCLONEII designs
	vlib cycloneii_ver
	vmap cycloneii_ver cycloneii_ver
	vlog -work cycloneii_ver $path_to_quartus/eda/sim_lib/cycloneii_atoms.v
} elseif {[string equal $type_of_sim "cycloneii"]} {
	# required for gate-level simulation of CYCLONEIII designs
	vlib cycloneiii_ver
	vmap cycloneiii_ver cycloneiii_ver
	vlog -work cycloneiii_ver $path_to_quartus/eda/sim_lib/cycloneiii_atoms.v
} elseif {[string equal $type_of_sim "flex10ke"]} {
	# required for gate-level simulation of FLEX10KE designs
	vlib flex10ke_ver
	vmap flex10ke_ver flex10ke_ver
	vlog -work flex10ke_ver $path_to_quartus/eda/sim_lib/flex10ke_atoms.v
} elseif {[string equal $type_of_sim "flex6000"]} {
	# required for gate-level simulation of FLEX6000 designs
	vlib flex6000_ver
	vmap flex6000_ver flex6000_ver
	vlog -work flex6000_ver $path_to_quartus/eda/sim_lib/flex6000_atoms.v
} elseif {[string equal $type_of_sim "hardcopy"]} {
	# required for gate-level simulation of HARDCOPY STRATIX designs
	vlib hcstratix_ver
	vmap hcstratix_ver hcstratix_ver
	vlog -work hcstratix_ver $path_to_quartus/eda/sim_lib/hcstratix_atoms.v
} elseif {[string equal $type_of_sim "hardcopyii"]} {
	# required for gate-level simulation of HARDCOPYII designs
	vlib hardcopyii_ver
	vmap hardcopyii_ver hardcopyii_ver
	vlog -work hardcopyii_ver $path_to_quartus/eda/sim_lib/hardcopyii_atoms.v
} elseif {[string equal $type_of_sim "max"]} {
	# required for gate-level simulation of MAX designs
	vlib max_ver
	vmap max_ver max_ver
	vlog -work max_ver $path_to_quartus/eda/sim_lib/max_atoms.v
} elseif {[string equal $type_of_sim "maxii"]} {
	# required for gate-level simulation of MAXII designs
	vlib maxii_ver
	vmap maxii_ver maxii_ver
	vlog -work maxii_ver $path_to_quartus/eda/sim_lib/maxii_atoms.v
} elseif {[string equal $type_of_sim "mercury"]} {
	# required for gate-level simulation of MERCURY designs
	vlib mercury_ver
	vmap mercury_ver mercury_ver
	vlog -work mercury_ver $path_to_quartus/eda/sim_lib/mercury_atoms.v
} elseif {[string equal $type_of_sim "stratix"]} {
	# required for gate-level simulation of STRATIX designs
	vlib stratix_ver
	vmap stratix_ver stratix_ver
	vlog -work stratix_ver $path_to_quartus/eda/sim_lib/stratix_atoms.v
} elseif {[string equal $type_of_sim "stratixii"]} {
	# required for gate-level simulation of STRATIXII designs
	vlib stratixii_ver
	vmap stratixii_ver stratixii_ver
	vlog -work stratixii_ver $path_to_quartus/eda/sim_lib/stratixii_atoms.v
} elseif {[string equal $type_of_sim "stratixiii"]} {
	# required for gate-level simulation of STRATIXIII designs
	vlib stratixiii_ver
	vmap stratixiii_ver stratixiii_ver
	vlog -work stratixiii_ver $path_to_quartus/eda/sim_lib/stratixiii_atoms.v
} elseif {[string equal $type_of_sim "stratixiigx_timing"]} {
	# required for gate-level simulation of STRATIXIIGX designs
	vlib sgate_ver
	vmap sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib stratixiigx_ver
	vmap stratixiigx_ver stratixiigx_ver
	vlog -work stratixiigx_ver $path_to_quartus/eda/sim_lib/stratixiigx_atoms.v
	vlib stratixiigx_hssi_ver
	vmap stratixiigx_hssi_ver stratixiigx_hssi_ver
	vlog -work stratixiigx_hssi_ver $path_to_quartus/eda/sim_lib/stratixiigx_hssi_atoms.v
} elseif {[string equal $type_of_sim "stratixgx_timing"]} {
	# required for gate-level simulation of STRATIXGX designs
	vlib sgate_ver
	vmap sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib stratixgx_ver
	vmap stratixgx_ver stratixgx_ver
	vlog -work stratixgx_ver $path_to_quartus/eda/sim_lib/stratixgx_atoms.v
	vlib stratixgx_gxb_ver
	vmap stratixgx_gxb_ver stratixgx_gxb_ver
	vlog -work stratixgx_gxb_ver $path_to_quartus/eda/sim_lib/stratixgx_hssi_atoms.v
} elseif {[string equal $type_of_sim "arriagx_timing"]} {
	# required for gate-level simulation of ARRIAGX designs
	vlib sgate_ver
	vmap sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib arriagx_ver
	vmap arriagx_ver stratixgx_ver
	vlog -work arriagx_ver $path_to_quartus/eda/sim_lib/arriagx_atoms.v
	vlib arriagx_gxb_ver
	vmap arriagx_gxb_ver arriagx_gxb_ver
	vlog -work arriagx_gxb_ver $path_to_quartus/eda/sim_lib/arriagx_hssi_atoms.v
} else {
	puts "invalid code"
}




