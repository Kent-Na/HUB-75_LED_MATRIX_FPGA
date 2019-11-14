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

    .carry_out(clk_counter_carry_out), .count(), .is_zero(), .is_max(clk_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h3f)
) x_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (lat_state == kLatWait)),

    .carry_out(x_counter_carry_out), .count(x_counter_count), .is_zero(), .is_max(x_counter_is_max)
);

CascadeCounter #(
    .bit_width(6),
    .count_max('h0)
) lat_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(clk_counter_carry_out && (lat_state == kLatActive)),

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

    .carry_out(y_counter_carry_out), .count(y_counter_count), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(10),
    .count_max('h7f)
) frame_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(y_counter_carry_out),

    .carry_out(frame_counter_carry_out), .count(), .is_zero(), .is_max()
);

CascadeCounter #(
    .bit_width(8),
    .count_max('h8)
) sequence_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(frame_counter_carry_out),

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

/*
module Controller (
    input logic clock,
    input logic reset,

    output DriveSignal drive_signal
);

// TODO: Set bit width for those signals.

logic line_buffer_read_address;
logic line_buffer_read_data;

logic line_buffer_write_address;
logic line_buffer_write_data;
logic line_buffer_write_enable;

LineBuffer#(
    .address_width(7), // 64 pixel x 2 buffer
    .data_width(48)
) line_buffer(
    .clock(clock),
    .reset(reset),
    
    .read_address(line_buffer_read_address),
    .read_data(line_buffer_read_data),

    .write_address(line_buffer_write_address),
    .write_data(line_buffer_write_data),
    .write_enable(line_buffer_write_enable)
);

logic driver_start;
logic driver_done;

Driver driver(
    .clock(clock),
    .reset(reset),

    .y(),
    .start(),
    .done(),

    .read_address(line_buffer_read_address),
    .read_data(line_buffer_read_data),

    .drive_singnal(drive_signal)
);

logic generator_start;
logic generator_done;

PixelGenerator pixel_generator(
    .clock(clock),
    .reset(reset),

    .y(),
    .start(generator_start),
    .done(generator_done)
);

logic driver_y_carry_in;
logic driver_y_is_zero;
logic driver_y_is_max;

logic generator_y_carry_in;
logic generator_y_is_max;

logic frame_count_carry_in;

CascadeCounter #(
    .bit_width(5),
    .count_max('h1f)
) generator_y_counter(
    .clock(clock),
    .reset(reset),
    .carry_in(generator_y_carry_in),

    .carry_out(), .count(), .is_zero(generator_y_is_zero), .is_max(generator_y_is_max)
);

CascadeCounter #(
    .bit_width(5),
    .count_max('h1f)
) driver_y_counter(
    .clock(clock),
    .reset(reset),
    .carry_in(driver_y_carry_in),

    .carry_out(), .count(), .is_zero(), .is_max(driver_y_is_max)
);

CascadeCounter #(
    .bit_width(10),
    .count_max('h7f)
) frame_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(frame_count_carry_in),

    .carry_out(frame_count), .count(), .is_zero(), .is_max()
);

/*
typedef enum {
    kWait,
    kActive,
    kScanRows,
    kHSync,
} State;

State state_next;
State state_current;
*/
/*
always_comb begin
    //if ( state_current == kScanRows) begin
        if (generator_done && driver_done) begin
            if (driver_y_is_max && generator_y_is_max) begin
                //state_next = kHSync;
                driver_y_carry_in = 1'b1;
                generator_y_carry_in = 1'b1;
                frame_count_carry_in = 1'b1;
            end else if (driver_y_is_zero) begin
                driver_y_carry_in = 1'b1 && ~driver_y_is_max;
                generator_y_carry_in = 1'b0;
                frame_count_carry_in = 1'b0;
                //state_next = kScanRows;
            end else begin
                driver_y_carry_in = 1'b1 && ~driver_y_is_max;
                generator_y_carry_in = 1'b0 && ~generator_y_is_max;
                frame_count_carry_in = 1'b0;
                //state_next = kScanRows;
            end
        end else begin
            driver_y_carry_in = 1'b0;
            generator_y_carry_in = 1'b0;
            frame_count_carry_in = 1'b0;
        end
    //end else begin

    //end
    //state_next = kWait;
end
*/

/*
always_ff @ (posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end

end
*/
/*
endmodule
*/
