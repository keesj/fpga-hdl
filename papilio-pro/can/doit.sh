#!/bin/sh 

mkdir -p build
(
cd build
set -x 
set -e
#
#
#
for i in syn/can_phy.vhd \
	syn/can_clk.vhd \
	syn/can_crc.vhd \
	syn/can_tx.vhd \
	syn/can_rx.vhd \
	syn/can.vhd \
	sim/can_phy_testbench.vhd \
	sim/can_clk_testbench.vhd \
	sim/can_crc_testbench.vhd \
	sim/can_tx_testbench.vhd \
	sim/can_rx_testbench.vhd \
	sim/can_testbench.vhd 
do 
	ghdl -a --ieee=synopsys --std=08 ../$i
done


#ghdl  -r --ieee=synopsys --std=08 can_crc_testbench --vcd=can_crc_testbench.vcd --stop-time=1ms && \
#ghdl -r --ieee=synopsys --std=08 can_clk_testbench --vcd=can_clk_testbench.vcd --stop-time=3ms && \
cp -r ../sim/test_data .
ghdl -r --ieee=synopsys --std=08 can_tx_testbench --vcd=can_tx_testbench.vcd --stop-time=30us
ghdl -r --ieee=synopsys --std=08 can_rx_testbench --vcd=can_rx_testbench.vcd --stop-time=30us 
ghdl -r --ieee=synopsys --std=08 can_testbench --vcd=can_testbench.vcd --stop-time=100us
../tools/to_raw.py
sigrok-cli --input-format binary:samplerate=2 --input-file out --output-file out.sr
)
