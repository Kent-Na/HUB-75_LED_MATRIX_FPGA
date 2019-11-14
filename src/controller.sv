`timescale 1 ns / 1 ns

module Controller (
    input logic clock,
    input logic reset,

    DriveSignal drive_signal
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

/*
always_ff @ (posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kWait;
    end else begin
        state_current = state_next;
    end

end
*/

endmodule
