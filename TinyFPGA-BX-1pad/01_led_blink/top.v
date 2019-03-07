module top (input CLK, output LED);

    // We want to blink at 1 Hz and we have an input clock of 16Mhz
    // We therefore need to count to 16.000.000. In binary we need
    // log(16.000.000)/log(2) bit for this (24 bits)
    // python
    // Python 3.6.7 (default, Oct 22 2018, 11:32:17) 
    // >>> import math
    // >>> math.log(16e6)/math.log(2)
    // 23.931568569324174

    reg [25:0] counter = 0;

    assign LED = counter[23];

    always @(posedge CLK) begin
        counter <= counter +1;
        if (counter > 16000000 -1)
        begin
            counter <= 0;
        end
    end
endmodule
