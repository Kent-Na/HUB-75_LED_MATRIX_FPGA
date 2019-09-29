`timescale 1 ns / 1 ns

// Ref: https://learn.adafruit.com/32x16-32x32-rgb-led-matrix/overview

module Driver (
    input logic clock,
    input logic reset,

    output logic r1, 
    output logic g1, 
    output logic b1, 

    output logic r2, 
    output logic g2, 
    output logic b2, 

    output logic[3:0] abcde,

    output logic clk,
    output logic lat,
    output logic oe
);

parameter k_width = 64;
parameter k_height = 64;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(1'b1),

    .carry_out(), .count(), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) y_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(x_counter.carry_out),

    .carry_out(), .count(), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(5),
    .count_max('h1f)
) frame_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(y_counter.carry_out),

    .carry_out(), .count(), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(8),
    .count_max('h8)
) sequence_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(frame_counter.carry_out),

    .carry_out(), .count(), .is_zero(), .is_max()
);

always_comb begin
    oe = 1'b1;
    lat = x_counter.is_max;
    clk = clock;

    r1 = sequence_counter.count[0];
    g1 = sequence_counter.count[1];
    b1 = sequence_counter.count[2];

    r2 = sequence_counter.count[0];
    g2 = sequence_counter.count[1];
    b2 = sequence_counter.count[2];

    abcde = y_counter.count;
end

endmodule
