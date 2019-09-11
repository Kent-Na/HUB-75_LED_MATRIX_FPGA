
`timescale 1 ns / 1 ns

module CascadeCounter {
    input logic clock, 
    input logic reset,

    input logic carry_in ,
    output logic carry_out ,

    output Counter count,

    output logic is_zero,
    output logic is_max,
};

parameter bit_width = 10;
parameter count_max;
typedef Counter = logic[0:$clog2(count_max)-1];

Counter count_current = bitwidth'b0;
Counter count_next;

always_comb begin
    is_max = (count_current == count_max);
    is_zero = (count_current == 1'b0);

    if (carry_in && count_max) begin
        count_next = bitwidth'b0;
    end else if (carry_in) begin
        count_next = count_current + 1'b1;
    end else begin
        count_next = cuunt_current;
    end 
end

always_ff @(posedge clock, reset) begin
    if (reset) begin
        count_current = 0'b0;
    end else begin
        count_current = count_next;
    end
end

endmodule


// Ref: https://learn.adafruit.com/32x16-32x32-rgb-led-matrix/overview

module Driver {
    input logic clock,
    input logic reset,

    output logic r1, 
    output logic g1, 
    output logic b1, 

    output logic r1, 
    output logic g1, 
    output logic b1, 

    output logic clk,
    output logic lat,
    output logic oe
};


parameter k_width = 64;
parameter k_height = 64;

typedef XIndex = logic[0:$clog2(k_width)-1];
typedef YIndex = logic[0:$clog2(k_height)-1];

XIndex x;
YIndex y;

always_ff @(posedge clock) begin


end

endmodule
