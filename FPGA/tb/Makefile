
VPATH = ../src
SRC  = simulation_led_gpmc.sv fifo.v gumstix_interface.sv led_shift_register.sv  fpga_top.sv pll.v zbtram.sv zbt_write_ctrl.sv fetch_pixels.sv blade_position.sv cross_exchanger.sv ram_controller.sv cy7c1357c.v internal_rom.sv
TAGS = $(patsubst %.sv,%.tag,$(SRC)) $(patsubst %.v,%.tag,$(SRC))
TOP  = simulation_led_gpmc

all : simu

work :
	vlib work

%.tag : %.v work
	vlog +acc -novopt $<
	touch $@

%.tag : %.sv work
	vlog +acc -novopt $<
	touch $@

simu : $(TAGS) work
	vsim $(TOP) -L altera_mf_ver -do wave.do

clean : 
	rm -rf work *~ *.tag transcript *.wlf ../src/*~

