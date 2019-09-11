
`timescale 1 ns / 1 ns


module CascadeCounterTB();
  
CascadeCounter counter();

logic clock;
logic reset;

initial begin
    clock = 0'b1;

    reset = 1'b1;
    repeat(4) #10 clock = ~clock;

    reset = 1'b0;
    forever #10 clock = ~clock;
end

endmodule 
