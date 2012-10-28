#!/usr/bin/env python
# -*- coding: utf-8 -*-
#######################################################################################
#########################################RoseAce#######################################        
#######################################################################################
#
# This file creates the file which will contain the config data for 
# the config_shift_register. The form of the output files is  :
# Every value in the file are unsigned short
# From 0 to maxpixel*2+1 there are the DC value correponding to the npixel value
# In npixel*2 there is the {1'b0,green,1'b0,red} component and in npixel*2+1 there is the {9'b0,blue} component
# DC -> 0 to 255
# 
# In 256 there is {green,red} component and in 257 there is the {8'b0,blue} component
# BC -> 256 to 257
#
# In 258 there is the FC configuration value {X,FC}
# FC -> 258
#
# The output file name is precised on the variable rom_config_file_name.
# The file name is given in argument when starting the program.
#######################################################################################

############################### Extern function importation ###########################
# Used for beeing in thegood repertory
from os import chdir
import sys

#################################### Global variable ##################################
# Output file name
rom_config_file_name = sys.argv[1]

##################################### Main script #####################################

# config_rom data generation
# Creating the file
rom_config = open(rom_config_file_name, 'w')

# Writing DC value
for i in range(128):
    # Writing value : DC = max value for all pixels
    if i<4 or (i>63 and i<68):
        rom_config.write("0x1010\n")
        rom_config.write("0x0010\n")
    else:
        rom_config.write("0x7f7f\n");
        rom_config.write("0x007f\n");

# BC = mac value for all groups
rom_config.write("0xffff\n"); 
rom_config.write("0x00ff\n"); 

# Writing FC value
# DC = 0-67% mode, 8 bits PWM, autoreload, FIXME : last bit ???
rom_config.write("0x78\n")
        
# Close file
rom_config.close()        
