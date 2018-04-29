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
	sim/can_phy_testbench.vhd \
	syn/can_clk.vhd \
	sim/can_clk_testbench.vhd \
	syn/can_crc.vhd \
	sim/can_crc_testbench.vhd \
	syn/can_tx.vhd \
	sim/can_tx_testbench.vhd \
	syn/can_rx.vhd \
	sim/can_rx_testbench.vhd \
	syn/can_tx_mux.vhd \
	syn/can.vhd \
	sim/can_testbench.vhd \
	sim/can_two_devices_testbench.vhd \
	sim/can_two_devices_clk_sync_testbench.vhd \
	examples/can_send.vhd \
	sim/can_send_testbench.vhd \
	syn/can_wb.vhd \
	sim/can_wb_testbench.vhd \
	sim/can_wb_register_testbench.vhd
do
	ghdl -a --ieee=synopsys --std=08 ../$i
done


cp -r ../sim/test_data .
for i in can_crc_testbench can_clk_testbench can_tx_testbench can_rx_testbench can_two_devices_testbench can_two_devices_clk_sync_testbench can_testbench can_wb_register_testbench can_wb_testbench
do
	ghdl  -r --ieee=synopsys --std=08 $i
#	ghdl  -r --ieee=synopsys --std=08 $i --vcd=$i.vcd 
done
#../tools/to_raw.py
#sigrok-cli --input-format binary:samplerate=2 --input-file out --output-file out.sr
)
