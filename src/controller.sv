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
logic driver_is_idle;

DummyDriver driver(
    .clock(clock),
    .reset(reset),

    .y(),
    .start(driver_start),
    .is_idle(driver_is_idle),

    //.read_address(line_buffer_read_address),
    //.read_data(line_buffer_read_data),

    .drive_signal(drive_signal)
);

logic generator_start;
logic generator_is_idle;

DummyPixelGenerator pixel_generator(
    .clock(clock),
    .reset(reset),

    .y(),
    .start(generator_start),
    .is_idle(generator_is_idle)
);

logic driver_y_carry_in;
logic driver_y_is_zero;
logic driver_y_is_max;

logic generator_y_carry_in;
logic generator_y_is_max;

logic frame_count_carry_in;

logic[9:0] frame_count;

CascadeCounter #(
    .bit_width(5),
    .count_max('h3)
) generator_y_counter(
    .clock(clock),
    .reset(reset),
    .carry_in(generator_y_carry_in),

    .carry_out(), .count(), .is_zero(generator_y_is_zero), .is_max(generator_y_is_max)
);

CascadeCounter #(
    .bit_width(5),
    .count_max('h3)
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

    .carry_out(), .count(frame_count), .is_zero(), .is_max()
);

typedef enum {
    kStartRow,
    kWaitRow
} State;

State state_next;
State state_current;

always_comb begin
    if (state_current == kStartRow) begin
        state_next = kWaitRow;
        driver_y_carry_in = 1'b0;
        generator_y_carry_in = 1'b0;

        if (generator_y_is_zero) begin
            generator_start = 1'b1;
            driver_start = 1'b0;
            frame_count_carry_in = 1'b0;
        end else begin
            generator_start = ~generator_y_is_max;
            driver_start = ~driver_y_is_max;
            frame_count_carry_in = 1'b0;
        end
    end else if (state_current == kWaitRow) begin
        generator_start = 1'b0;
        driver_start = 1'b0;

        if (generator_is_idle && driver_is_idle) begin
            state_next = kStartRow;

            if (generator_y_is_zero) begin
                driver_y_carry_in = 1'b0;
                generator_y_carry_in = 1'b1;
            end else if (generator_y_is_max && ~driver_y_is_max) begin
                driver_y_carry_in = 1'b1;
                generator_y_carry_in = 1'b0;
            end else begin
                driver_y_carry_in = 1'b1;
                generator_y_carry_in = 1'b1;
            end

            if (generator_y_is_max && driver_y_is_max) begin
                frame_count_carry_in = 1'b1;
            end else begin
                frame_count_carry_in = 1'b0;
            end
        end else begin
            state_next = kWaitRow;
            frame_count_carry_in = 1'b0;
            driver_y_carry_in = 1'b0;
            generator_y_carry_in = 1'b0;
        end
    end
end

always_ff @ (posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kStartRow;
    end else begin
        state_current = state_next;
    end

end

endmodule
