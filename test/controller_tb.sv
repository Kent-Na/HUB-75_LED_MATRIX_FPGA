
`timescale 1 ns / 1 ns


module ControllerTB();
  
logic clock;
logic reset;

DriveSignal drive_signal();

Controller#(
) controller(
    .clock(clock),
    .reset(reset),

    .drive_signal(drive_signal)
);

initial begin
    clock = 0'b1;

    reset = 1'b1;
    repeat(4) #10 clock = ~clock;

    reset = 1'b0;
    forever #10 clock = ~clock;
end

endmodule 
