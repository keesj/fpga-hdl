Setup
=====

Copy the top.v and top.pcf from the 01 example and create top_tb.v

Create test bench based on
https://github.com/FPGAwars/apio-examples/blob/master/leds/leds_tb.v

Also reading
https://github.com/FPGAwars/apio-examples/blob/master/Makefile_example/Makefile


Compile the verilog into code for the Verilog runtime engine (vpp). This
can be executed to perform the tests.

.. code-block::

    iverilog top_tb.v top.v -o top_tb.vpp
    ./top_tb.vvp


Use gtkwave to see the waveform
.. code-block::

    gtkwave  top_tb.vcd


