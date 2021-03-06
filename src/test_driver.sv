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

    output logic[4:0] abcde,

    output logic clk,
    output logic lat,
    output logic oe
);

parameter k_width = 64;
parameter k_height = 64;

logic[0:0] clk_counter_is_max;
logic clk_counter_carry_out;
logic lat_counter_is_max;
logic lat_counter_carry_out;
logic[5:0] x_counter_count;
logic x_counter_carry_out;
logic x_counter_is_max;
logic y_counter_carry_out;
logic[4:0] y_counter_count;
logic frame_counter_carry_out;
logic[7:0] sequence_counter_count;

typedef enum {
    kLatWait,
    kLatActive
} LatState;

LatState lat_state = kLatWait;

CascadeCounter #(
    .bit_width(1),
    .count_max('h1)
) clk_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(1'b1),
    .sync_reset(1'b0),

    .carry_out(clk_counter_carry_out), .count(), .is_zero(), .is_max(clk_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (lat_state == kLatWait)),
    .sync_reset(1'b0),

    .carry_out(x_counter_carry_out), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h0)
) lat_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (lat_state == kLatActive)),
    .sync_reset(1'b0),

    .carry_out(lat_counter_carry_out), .count(), .is_zero(), .is_max(lat_counter_is_max)
);

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        lat_state = kLatWait;
    end else if (~clk_counter_is_max) begin
        lat_state = lat_state;
    end else if (lat_state == kLatWait) begin
        if (x_counter_is_max) begin
            lat_state = kLatActive;
        end else begin
            lat_state = kLatWait;
        end
    end else if (lat_state == kLatActive && lat_counter_is_max) begin
        lat_state = kLatWait;
    end
end

CascadeCounter #(
    .bit_width(6),
    .count_max('h1f)
) y_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(lat_counter_carry_out),
    .sync_reset(1'b0),

    .carry_out(y_counter_carry_out), .count(y_counter_count), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(10),
    .count_max('h7f)
) frame_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(y_counter_carry_out),
    .sync_reset(1'b0),

    .carry_out(frame_counter_carry_out), .count(), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(8),
    .count_max('h8)
) sequence_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(frame_counter_carry_out),
    .sync_reset(1'b0),

    .carry_out(), .count(sequence_counter_count), .is_zero(), .is_max()
);

always_comb begin
    oe = (x_counter_count > 'h4) && (x_counter_count < 'h38);
    lat = lat_state == kLatActive;
    clk = clk_counter_is_max;

    r1 = sequence_counter_count[0];
    g1 = sequence_counter_count[1];
    b1 = sequence_counter_count[2];

    r2 = sequence_counter_count[0];
    g2 = sequence_counter_count[1];
    b2 = sequence_counter_count[2];

    abcde = y_counter_count;
end

endmodule
