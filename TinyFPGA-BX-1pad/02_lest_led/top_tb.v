`default_nettype none
`timescale 100 ns / 10 ns

module top_tb();

    //We have a very slow clock so need a lot of simulation time
    parameter DURATION = 100;

    //-- Clock signal. It is not used in this simulation
    reg clk = 0;
    always #0.5 clk = ~clk;

    wire led;

    top UUT (clk,led);

    initial begin
      $dumpfile("top_tb.vcd");
      $dumpvars(0, top_tb);

       #(DURATION) $display("End of simulation");
       $finish;
    end

endmodule
