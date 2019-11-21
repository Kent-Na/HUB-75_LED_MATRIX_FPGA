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

module Driver_1bit (
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

logic[0:0] clk_counter_is_max;
logic clk_counter_carry_out;
logic lat_counter_is_max;
logic lat_counter_carry_out;
logic[5:0] x_counter_count;
logic[5:0] oe_counter_count;
logic x_counter_carry_out;
logic x_counter_is_max;

typedef enum {
    kInit,
    kWait,
    kSetColumn,
    kSetRow
} State;

State state_current;
State state_next;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kSetColumn),

    .carry_out(x_counter_carry_out), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h17)
) oe_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kSetRow),

    .carry_out(), .count(oe_counter_count), .is_zero(), .is_max(oe_counter_is_max)
);


assign is_idle = state_current == kWait;
assign read_address = {y[0], x_counter_count};

always_comb begin
    if (state_current == kInit) begin
        state_next <= kWait;
    end else if (state_current == kWait) begin
        if (start) begin
            state_next <= kSetColumn;
        end else begin
            state_next <= kWait;
        end
    end else if (state_current == kSetColumn) begin
        if (x_counter_is_max) begin
            state_next <= kSetRow;
        end else begin
            state_next <= kSetColumn;
        end
    end else if (state_current == kSetRow) begin
        if (oe_counter_is_max) begin
            state_next <= kWait;
        end else begin
            state_next <= kSetRow;
        end
    end else begin
        state_next <= kInit;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kInit;
    end else begin
        state_current = state_next;
    end
end

DriveSignal drive_signal_s0();

always_comb begin
    drive_signal_s0.oe <= ~((oe_counter_count > 'h3) && (state_current == kSetRow));
    drive_signal_s0.lat <= x_counter_is_max && (state_current == kSetColumn);
    // state_current == kLatActive;

    //drive_signal_s0.clk <= ~clock;

    drive_signal_s0.r1 <= read_data['h7];
    drive_signal_s0.g1 <= read_data['hf];
    drive_signal_s0.b1 <= read_data['h17];

    drive_signal_s0.r2 <= read_data['h1f];
    drive_signal_s0.g2 <= read_data['h27];
    drive_signal_s0.b2 <= read_data['h2f];

    drive_signal_s0.abcde <= y;
end

assign drive_signal.clk = ~clock;

always_ff @(posedge clock, posedge reset) begin
    drive_signal.oe <= drive_signal_s0.oe;
    drive_signal.lat <= drive_signal_s0.lat;

    //drive_signal.clk = drive_signal_s0.clk;

    drive_signal.r1 <= drive_signal_s0.r1;
    drive_signal.g1 <= drive_signal_s0.g1;
    drive_signal.b1 <= drive_signal_s0.b1;
    drive_signal.r2 <= drive_signal_s0.r2;
    drive_signal.g2 <= drive_signal_s0.g2;
    drive_signal.b2 <= drive_signal_s0.b2;

    drive_signal.abcde <= drive_signal_s0.abcde;
end

endmodule

module Driver_8bit (
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

logic[0:0] clk_counter_is_max;
logic clk_counter_carry_out;
logic lat_counter_is_max;
logic lat_counter_carry_out;

logic[8:0] oe_counter_count;

logic[2:0] oe_bit_counter_count;
logic oe_bit_counter_is_max;

logic[5:0] x_counter_count;
logic x_counter_carry_out;
logic x_counter_is_max;

typedef enum {
    kInit,
    kWait,
    kSetColumn,
    kWaitRow,
    kSetRow
} State;

State state_current;
State state_next;

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kSetColumn),
    .sync_reset(1'b0),

    .carry_out(x_counter_carry_out), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

CascadeCounter #(
    .bit_width(3),
    .count_max('h7)
) oe_bit_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kSetRow && oe_counter_is_max),
    .sync_reset(1'b0),

    .carry_out(), .count(oe_bit_counter_count), .is_zero(), .is_max(oe_bit_counter_is_max)
);

CascadeCounter #(
    .bit_width(9),
    .count_max('h1ff)
) oe_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(state_current == kSetRow),
    .sync_reset(oe_counter_is_max),

    .carry_out(), .count(oe_counter_count), .is_zero(), .is_max()
);

logic[7:0] bit_table[8] = '{
    'h01, 'h02, 'h04, 'h08,
    'h10, 'h20, 'h40, 'h80
};

assign is_idle = state_current == kWait;
assign read_address = {y[0], x_counter_count};
assign oe_counter_is_max = oe_counter_count == bit_table[oe_bit_counter_count];

always_comb begin
    if (state_current == kInit) begin
        state_next <= kWait;
    end else if (state_current == kWait) begin
        if (start) begin
            state_next <= kSetColumn;
        end else begin
            state_next <= kWait;
        end
    end else if (state_current == kSetColumn) begin
        if (x_counter_is_max) begin
            state_next <= kWaitRow;
        end else begin
            state_next <= kSetColumn;
        end
    end else if (state_current == kWaitRow) begin
        state_next <= kSetRow;
    end else if (state_current == kSetRow) begin
        if (oe_counter_is_max && oe_bit_counter_is_max) begin
            state_next <= kWait;
        end else if (oe_counter_is_max) begin
            state_next <= kSetColumn;
        end else begin
            state_next <= kSetRow;
        end
    end else begin
        state_next <= kInit;
    end
end

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kInit;
    end else begin
        state_current = state_next;
    end
end

DriveSignal drive_signal_s0();

always_comb begin
    drive_signal_s0.oe <= ~(state_current == kSetRow);
    drive_signal_s0.lat <= x_counter_is_max && (state_current == kSetColumn);

    //drive_signal_s0.clk <= ~clock;

    drive_signal_s0.r1 <= |(read_data['h7:'h0] & bit_table[oe_bit_counter_count]);
    drive_signal_s0.g1 <= |(read_data['hf:'h8] & bit_table[oe_bit_counter_count]);
    drive_signal_s0.b1 <= |(read_data['h17:'h10] & bit_table[oe_bit_counter_count]);

    drive_signal_s0.r2 <= |(read_data['h1f:'h18] & bit_table[oe_bit_counter_count]);
    drive_signal_s0.g2 <= |(read_data['h27:'h20] & bit_table[oe_bit_counter_count]);
    drive_signal_s0.b2 <= |(read_data['h2f:'h28] & bit_table[oe_bit_counter_count]);

    drive_signal_s0.abcde <= y;
end

assign drive_signal.clk = ~clock;

always_ff @(posedge clock, posedge reset) begin
    drive_signal.oe <= drive_signal_s0.oe;
    drive_signal.lat <= drive_signal_s0.lat;

    //drive_signal.clk = drive_signal_s0.clk;

    drive_signal.r1 <= drive_signal_s0.r1;
    drive_signal.g1 <= drive_signal_s0.g1;
    drive_signal.b1 <= drive_signal_s0.b1;
    drive_signal.r2 <= drive_signal_s0.r2;
    drive_signal.g2 <= drive_signal_s0.g2;
    drive_signal.b2 <= drive_signal_s0.b2;

    drive_signal.abcde <= drive_signal_s0.abcde;
end

endmodule
