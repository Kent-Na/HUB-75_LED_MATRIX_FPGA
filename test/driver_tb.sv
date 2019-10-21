
`timescale 1 ns / 1 ns


module DriverTB();
  
logic clock;
logic reset;

Driver#(
) driver(
    .clock(clock),
    .reset(reset),

    .r1(), .g1(), .b1(),
    .r2(), .g2(), .b2(),

    .abcde(),

    .clk(), .lat(), .oe()
);

initial begin
    clock = 0'b1;

    reset = 1'b1;
    repeat(4) #10 clock = ~clock;

    reset = 1'b0;
    forever #10 clock = ~clock;
end

endmodule 
