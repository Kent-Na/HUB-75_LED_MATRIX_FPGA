`timescale 1 ns / 1 ns

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

module PixelGenerator_sx(
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

logic[11:0] t;
logic[9:0] sin_t;
logic[9:0] cos_t;

NormalGenerator normal_generator(
    .t(t),
    .sin(sin_t),
    .cos(cos_t)
);

always_comb begin
    t = {frame_count[9:4] + y, 7'b0};
end

always_comb begin
    write_address <= {frame_count[0], x_counter_count};
    write_data <= 
    /*
    {
        {8{x_counter_count[0]}},
        {8{x_counter_count[1]}},
        {8{x_counter_count[2]}},
        {8{x_counter_count[0]}},
        {8{x_counter_count[1]}},
        {8{x_counter_count[2]}}
    } & 
    */
    /*
    {2{
            {16{x_counter_count < (sin_t[9:4] + 6'h20)}},
            {8{x_counter_count < (cos_t[9:4] + 6'h20)}}
    }};
    */
    {6{
            {8{x_counter_count < {y, 1'b0}}}
    }};
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
