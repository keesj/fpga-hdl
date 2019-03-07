#!/bin/sh
set -x 
set -e
yosys -p 'synth_ice40 -top top -json top.json' top.v
nextpnr-ice40  --lp8k --json top.json --pcf top.pcf --asc top.asc --package cm81
icepack top.asc top.bin
tinyprog -p top.bin
