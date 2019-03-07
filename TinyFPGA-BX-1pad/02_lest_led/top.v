module top (input CLK, output LED);

    reg [7:0] counter = 0;

    assign LED = counter[23];

    always @(posedge CLK) begin
        counter <= counter +1;
        if (counter == 200)
        begin
            counter <= 0;
        end
    end
endmodule
