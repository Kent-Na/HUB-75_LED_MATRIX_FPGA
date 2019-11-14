
module LineBuffer #(
    parameter address_width,
    parameter data_width
)(
    input logic clock,
    input logic reset,

    input logic[address_width-1:0] read_address,
    output logic[data_width-1:0] read_data,

    input logic[address_width-1:0] write_address,
    input logic[data_width-1:0] write_data,
    input logic write_enable
);

logic[data_width-1:0] data[1<<address_width];

always_ff @(posedge clock) begin
    if (write_enable) begin
        data[write_address] = write_data;
    end
end

always_comb begin
    read_data = data[read_address];
end

endmodule

