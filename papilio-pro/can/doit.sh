#!/bin/sh 
set -x 
set -e
#
#
#
for i in can_phy.vhd \
	can_clk.vhd \
	can_crc.vhd \
	can_tx.vhd \
	can_rx.vhd \
	can_phy_testbench.vhd \
	can_clk_testbench.vhd \
	can_crc_testbench.vhd \
	can_tx_testbench.vhd \
	can_rx_testbench.vhd \
	can.vhd \
	can_testbench.vhd 
do 
	ghdl -a --ieee=synopsys --std=08 $i
done


#ghdl  -r --ieee=synopsys --std=08 can_crc_testbench --vcd=can_crc_testbench.vcd --stop-time=1ms && \
#ghdl -r --ieee=synopsys --std=08 can_clk_testbench --vcd=can_clk_testbench.vcd --stop-time=3ms && \
ghdl -r --ieee=synopsys --std=08 can_tx_testbench --vcd=can_tx_testbench.vcd --stop-time=30us 
ghdl -r --ieee=synopsys --std=08 can_rx_testbench --vcd=can_rx_testbench.vcd --stop-time=30us 
ghdl -r --ieee=synopsys --std=08 can_testbench --vcd=can_testbench.vcd --stop-time=30us 
./to_raw.py
sigrok-cli --input-format binary:samplerate=2 --input-file out --output-file out.sr
