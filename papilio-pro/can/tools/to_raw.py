#!/usr/bin/env python3
import binascii

f = open("can_tx_testbench_data_out.hex")
raw = open("out","w")
counter=0
for line in f.readlines():
	line = line.strip().split(" ")[1]
	binval = int(line,16);
	for i in bin(binval)[2:]:
		
		if i == "1":
			counter = counter +1
			raw.write(chr(1 + 2 * (counter % 2)))
			counter = counter +1
			raw.write(chr(1 + 2 * (counter % 2)))
		else:
			counter = counter +1
			raw.write(chr(0 + 2 * (counter % 2)))
			counter = counter +1
			raw.write(chr(0 + 2 * (counter % 2)))
    		
