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

    output logic[bit_width-1:0] count,

    output logic is_zero,
    output logic is_max
);

typedef logic[bit_width-1:0] Counter;

generate

// TODO: Conditional compile following check.

//if ($clog2(count_max) > bit_width) begin
//    $error("Insufficient bit_width for counter.");
//end

endgenerate

Counter count_current = 1'b0;
Counter count_next;

always_comb begin
    is_max = (count_current == count_max);
    is_zero = (count_current == 1'b0);
    count = count_current;
    carry_out = is_max & carry_in;

    if (carry_in && is_max) begin
        count_next = 1'b0;
    end else if (carry_in) begin
        count_next = count_current + 1'b1;
    end else begin
        count_next = count_current;
    end 
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        count_current = 1'b0;
    end else begin
        count_current = count_next;
    end
end

endmodule
