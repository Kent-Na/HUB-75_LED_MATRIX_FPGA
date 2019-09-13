`timescale 1 ns / 1 ns

module CascadeCounter 
#(
    parameter bit_width,
    parameter count_max
)
(
    input logic clock, 
    input logic reset,

    input logic carry_in ,
    output logic carry_out ,

    output logic[0:bit_width-1] count,

    output logic is_zero,
    output logic is_max
);

typedef logic[0:bit_width-1] Counter;

generate

if ($clog2(count_max) > bit_width) begin
    $error("Insufficient bit_width for counter.");
end

endgenerate

Counter count_current = 1'b0;
Counter count_next;

always_comb begin
    is_max = (count_current == count_max);
    is_zero = (count_current == 1'b0);
    count = count_current;
    carry_out = is_max;

    if (carry_in && is_max) begin
        count_next = 1'b0;
    end else if (carry_in) begin
        count_next = count_current + 1'b1;
    end else begin
        count_next = count_current;
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
