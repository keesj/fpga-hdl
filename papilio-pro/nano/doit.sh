#!/bin/sh

mkdir -p build
(
cd build
set -x
set -e
#
#
#
ghdl -a --ieee=synopsys --std=08 ../nano.vhd
ghdl -a --ieee=synopsys --std=08 ../nano_tb.vhd
ghdl -r --ieee=synopsys --std=08 nano_tb --vcd=nano_tb.vcd
)
