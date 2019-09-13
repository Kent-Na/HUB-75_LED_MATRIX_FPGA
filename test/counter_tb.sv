
`timescale 1 ns / 1 ns


module CascadeCounterTB();
  
logic clock;
logic reset;

CascadeCounter#(
    .bit_width(8),
    .count_max(100)
) counter_1(
    .clock(clock),
    .reset(reset),
    
    .carry_in(1'b1)
);

CascadeCounter#(
    .bit_width(8),
    .count_max(50)
) counter_2(
    .clock(clock),
    .reset(reset),
    
    .carry_in(counter_1.carry_out)
);

initial begin
    clock = 0'b1;

    reset = 1'b1;
    repeat(4) #10 clock = ~clock;

    reset = 1'b0;
    forever #10 clock = ~clock;
end

endmodule 
