`timescale 1 ns / 1 ns

// Ref: https://learn.adafruit.com/32x16-32x32-rgb-led-matrix/overview

interface DriveSignal;
    logic r1; 
    logic g1; 
    logic b1; 

    logic r2; 
    logic g2; 
    logic b2; 

    logic[4:0] abcde;

    logic clk;
    logic lat;
    logic oe;
endinterface 

module Driver (
    input logic clock,
    input logic reset,

    input logic[4:0] y,
    input logic[9:0] frame_count,
    input logic start,
    output logic is_idle,

    output logic[6:0] read_address,
    input logic[47:0] read_data,

    DriveSignal drive_signal
);

//parameter k_width = 64;
//parameter k_height = 64;

logic[0:0] clk_counter_is_max;
logic clk_counter_carry_out;
logic lat_counter_is_max;
logic lat_counter_carry_out;
logic[5:0] x_counter_count;
logic x_counter_carry_out;
logic x_counter_is_max;

typedef enum {
    kWait,
    kLatWait,
    kLatActive
} State;

State state_current;
State state_next;

CascadeCounter #(
    .bit_width(1),
    .count_max('h1)
) clk_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(1'b1),

    .carry_out(clk_counter_carry_out), .count(), .is_zero(), .is_max(clk_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (state_current == kLatWait)),

    .carry_out(x_counter_carry_out), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h0)
) lat_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (state_current == kLatActive)),

    .carry_out(lat_counter_carry_out), .count(), .is_zero(), .is_max(lat_counter_is_max)
);

assign is_idle = state_current == kWait;
assign read_address = {frame_count[0], x_counter_count};

always_comb begin
    if (state_current == kWait) begin
        if (start) begin
            state_next <= kLatWait;
        end else begin
            state_next <= kWait;
        end
    end else if (~clk_counter_is_max) begin
        state_next <= state_current;
    end else if (state_current == kLatWait) begin
        if (x_counter_is_max) begin
            state_next <= kLatActive;
        end else begin
            state_next <= kLatWait;
        end
    end else if (state_current == kLatActive && lat_counter_is_max) begin
        state_next <= kWait;
    end else begin
        state_next <= state_current;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end
end

always_comb begin
    drive_signal.oe <= ~((x_counter_count > 'h10) && (x_counter_count < 'h30));
    drive_signal.lat <= state_current == kLatActive;

    drive_signal.clk <= clk_counter_is_max;

    drive_signal.r1 = read_data['h7];
    drive_signal.g1 = read_data['hf];
    drive_signal.b1 = read_data['h17];

    drive_signal.r2 = read_data['h1f];
    drive_signal.g2 = read_data['h27];
    drive_signal.b2 = read_data['h2f];

/*
    drive_signal.r1 <= x_counter_count[0];
    drive_signal.g1 <= x_counter_count[1];
    drive_signal.b1 <= x_counter_count[2];

    drive_signal.r2 <= x_counter_count[0];
    drive_signal.g2 <= x_counter_count[1];
    drive_signal.b2 <= x_counter_count[2];
    */

    drive_signal.abcde <= y;
end

endmodule

module PixelGenerator(
    input logic clock,
    input logic reset,

    input logic[4:0] y,
    input logic[9:0] frame_count,
    input logic start,
    output logic is_idle,

    output logic[6:0] write_address,
    output logic[47:0] write_data,
    output logic write_enable
);

typedef enum {
    kWait,
    kRun
} State;

State state_current;
State state_next;

logic x_counter_is_max;
logic[5:0] x_counter_count;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kRun),

    .carry_out(), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

assign is_idle = state_current == kWait;

always_comb begin
    write_address <= {frame_count[0], x_counter_count};
    write_data <= {
        {8{x_counter_count[0]}},
        {8{x_counter_count[1]}},
        {8{x_counter_count[2]}},
        {8{x_counter_count[0]}},
        {8{x_counter_count[1]}},
        {8{x_counter_count[2]}}
    };
    write_enable <= state_current == kRun;
end

always_comb begin
    if (state_current == kWait && start) begin
        state_next = kRun;
    end else if (state_current == kRun && x_counter_is_max) begin
        state_next = kWait;
    end else begin
        state_next = state_current;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end
end

endmodule

module DummyDriver (
    input logic clock,
    input logic reset,

    input logic y,
    input logic start,
    output logic is_idle,

    DriveSignal drive_signal
);

typedef enum {
    kWait,
    kRun
} State;

State state_current;
State state_next;

logic x_counter_is_max;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kRun),

    .carry_out(), .count(), .is_zero(), .is_max(x_counter_is_max)
);

assign is_idle = state_current == kWait;

always_comb begin
    if (state_current == kWait && start) begin
        state_next = kRun;
    end else if (state_current == kRun && x_counter_is_max) begin
        state_next = kWait;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end
end

endmodule

module DummyPixelGenerator(
    input logic clock,
    input logic reset,

    input logic[4:0] y,
    input logic start,
    output logic is_idle
);

typedef enum {
    kWait,
    kRun
} State;

State state_current;
State state_next;

logic x_counter_is_max;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kRun),

    .carry_out(), .count(), .is_zero(), .is_max(x_counter_is_max)
);

assign is_idle = state_current == kWait;

always_comb begin
    if (state_current == kWait && start) begin
        state_next = kRun;
    end else if (state_current == kRun && x_counter_is_max) begin
        state_next = kWait;
    end else begin
        state_next = state_current;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end
end

endmodule
