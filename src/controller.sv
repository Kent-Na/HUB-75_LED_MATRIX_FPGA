`timescale 1 ns / 1 ns

module Controller_q_ip (
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

DriveSignal drive_signal(
);

assign r1 = drive_signal.r1;
assign g1 = drive_signal.g1;
assign b1 = drive_signal.b1;

assign r2 = drive_signal.r2;
assign g2 = drive_signal.g2;
assign b2 = drive_signal.b2;

assign abcde = drive_signal.abcde;

assign clk = drive_signal.clk;
assign lat = drive_signal.lat;
assign oe = drive_signal.oe;

Controller controller(
    .clock(clock),
    .reset(reset),
    .drive_signal(drive_signal)
);

endmodule

module Controller (
    input logic clock,
    input logic reset,

    DriveSignal drive_signal
);

// TODO: Set bit width for those signals.

parameter address_width = 7; //64 pixel x 2 buffer
parameter data_width = 48;

logic[address_width-1:0] line_buffer_read_address;
logic[data_width-1:0] line_buffer_read_data;

logic[address_width-1:0] line_buffer_write_address;
logic[data_width-1:0] line_buffer_write_data;
logic line_buffer_write_enable;

logic[4:0] driver_y;
logic[4:0] generator_y;
logic[9:0] frame_count;

LineBuffer#(
    .address_width(address_width),
    .data_width(data_width)
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

Driver_8bit driver(
    .clock(clock),
    .reset(reset),

    .y(driver_y),
    .frame_count(frame_count),
    .start(driver_start),
    .is_idle(driver_is_idle),

    .read_address(line_buffer_read_address),
    .read_data(line_buffer_read_data),

    .drive_signal(drive_signal)
);

logic generator_start;
logic generator_is_idle;

PixelGenerator_sx pixel_generator(
    .clock(clock),
    .reset(reset),

    .y(generator_y),
    .frame_count(frame_count),
    .start(generator_start),
    .is_idle(generator_is_idle),

    .write_address(line_buffer_write_address),
    .write_data(line_buffer_write_data),
    .write_enable(line_buffer_write_enable)
);

logic driver_y_carry_in;
logic driver_y_is_zero;
logic driver_y_is_max;

logic generator_y_carry_in;
logic generator_y_is_max;

logic frame_count_carry_in;

parameter count_max = 'h1f;

CascadeCounter #(
    .bit_width(5),
    .count_max(count_max)
) generator_y_counter(
    .clock(clock),
    .reset(reset),
    .carry_in(generator_y_carry_in),
    .sync_reset(1'b0),

    .carry_out(), 
    .count(generator_y), 
    .is_zero(generator_y_is_zero), 
    .is_max(generator_y_is_max)
);

CascadeCounter #(
    .bit_width(5),
    .count_max(count_max)
) driver_y_counter(
    .clock(clock),
    .reset(reset),
    .carry_in(driver_y_carry_in),
    .sync_reset(1'b0),

    .carry_out(), 
    .count(driver_y), 
    .is_zero(), 
    .is_max(driver_y_is_max)
);

CascadeCounter #(
    .bit_width(10),
    .count_max('h3ff)
) frame_counter (
    .clock(clock),
    .reset(reset),
    .carry_in(frame_count_carry_in),
    .sync_reset(1'b0),

    .carry_out(), .count(frame_count), .is_zero(), .is_max()
);

typedef enum {
    kInit,
    kStartRow,
    kWaitRow
} State;

State state_next;
State state_current;

always_comb begin
    if (state_current == kInit) begin
        state_next <= kStartRow;
        generator_start <= 1'b0;
        driver_start <= 1'b0;
        frame_count_carry_in <= 1'b0;
        driver_y_carry_in <= 1'b0;
        generator_y_carry_in <= 1'b0;
    end else if (state_current == kStartRow) begin
        state_next <= kWaitRow;
        driver_y_carry_in <= 1'b0;
        generator_y_carry_in <= 1'b0;
        frame_count_carry_in <= 1'b0;

        if (generator_y_is_zero) begin
            generator_start <= 1'b1;
            driver_start <= 1'b0;
        end else begin
            generator_start <= ~driver_y_is_max;
            driver_start <= 1'b1;
        end
    end else if (state_current == kWaitRow) begin
        generator_start <= 1'b0;
        driver_start <= 1'b0;

        if (generator_is_idle && driver_is_idle) begin
            state_next <= kStartRow;

            if (generator_y_is_zero) begin
                driver_y_carry_in <= 1'b0;
                generator_y_carry_in <= 1'b1;
            end else if (generator_y_is_max && ~driver_y_is_max) begin
                driver_y_carry_in <= 1'b1;
                generator_y_carry_in <= 1'b0;
            end else begin
                driver_y_carry_in <= 1'b1;
                generator_y_carry_in <= 1'b1;
            end

            if (generator_y_is_max && driver_y_is_max) begin
                frame_count_carry_in <= 1'b1;
            end else begin
                frame_count_carry_in <= 1'b0;
            end
        end else begin
            state_next <= kWaitRow;
            frame_count_carry_in <= 1'b0;
            driver_y_carry_in <= 1'b0;
            generator_y_carry_in <= 1'b0;
        end
    end else begin
        state_next <= kWaitRow;
        generator_start <= 1'b0;
        driver_start <= 1'b0;
        frame_count_carry_in <= 1'b0;
        driver_y_carry_in <= 1'b0;
        generator_y_carry_in <= 1'b0;
    end
end

always_ff @ (posedge clock, posedge reset) begin
    if (reset) begin
        state_current = kInit;
    end else begin
        state_current = state_next;
    end

end

endmodule
