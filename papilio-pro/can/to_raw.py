#!/usr/bin/env python3
import binascii

f = open("can_tx_testbench_data_out.hex")
raw = open("out","w")
counter=1
for line in f.readlines():
	line = line.strip()
	binval = int(line,16);
	for i in bin(binval)[2:]:
		counter = counter +1
		if i == "1":
			raw.write(chr(1 + 2 * (counter % 2)))
		else:
			raw.write(chr(0 + 2 * (counter % 2)))
    		
