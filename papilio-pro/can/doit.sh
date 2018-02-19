#
#
#
ghdl -a can_phy.vhd 
ghdl -a can_phy_testbench.vhd 

#
#
#
ghdl -a can_clk.vhd
ghdl -a can_clk_testbench.vhd
#ghdl -r can_phy_testbench --vcd=can_phy.vcd
#ghdl -r can_clk_testbench --vcd=can_clk_testbench.vcd --stop-time=10ms

ghdl -a can_crc.vhd
ghdl -a can_crc_testbench.vhd

ghdl -a can_tx.vhd
ghdl -a can_tx_testbench.vhd
ghdl -r can_tx_testbench --vcd=can_tx_testbench.vcd --stop-time=10ms
#ghdl -r can_clk_testbench --vcd=can_clk_testbench.vcd --stop-time=10ms
