#The name of the project, used as a name for certain intermediate files, and as the default name for the top-level module and constraints file.
PROJECT=blink

# The full part-speed-package identifier for the Xilinx part to be targeted, e.g. xc6slx9-2-tqg144.
# Can be seen from thee ide in the design summary: as taret device
TARGET_PART=xc6slx9-3tqg144



# The path to the appropriate binaries directory of the target Xilinx ISE install, e.g. 
# /cygdrive/c/Xilinx/14.7/ISE_DS/ISE or /opt/Xilinx/14.7/ISE_DS/ISE for typical installs.
#
XILINX=/opt/Xilinx/14.7/ISE_DS/ISE/


#The space-separated names of all Verilog and/or VHDL source files to be used in the project.
# You can define these on multiple lines using +=, e.g.VSOURCE += foo.v
VHDSOURCE += blink.vhd


#
#The name of the constraints file (.ucf) to be used for the project. (Defaults to $PROJECT.ucf.)
#CONSTRAINTS=

#PROGRAMMER ?= papilio-prog
PROGRAMMER=papilio-prog-spi

###########################################################################
## Xilinx ISE Makefile
##
## To the extent possible under law, the author(s) have dedicated all copyright
## and related and neighboring rights to this software to the public domain
## worldwide. This software is distributed without any warranty.
###########################################################################

include mk/common.mk
