

module SinTable (
    // 0 -> 0, pi/2 -> 1024
    input logic[9:0] theta_dash,
    output logic[8:0] value
);

logic[8:0] _table[1024] = '{
9'h0, 9'h1, 9'h2, 9'h2, 9'h3, 9'h4, 9'h5, 9'h5,
9'h6, 9'h7, 9'h8, 9'h9, 9'h9, 9'ha, 9'hb, 9'hc,
9'hd, 9'hd, 9'he, 9'hf, 9'h10, 9'h10, 9'h11, 9'h12,
9'h13, 9'h14, 9'h14, 9'h15, 9'h16, 9'h17, 9'h18, 9'h18,
9'h19, 9'h1a, 9'h1b, 9'h1b, 9'h1c, 9'h1d, 9'h1e, 9'h1f,
9'h1f, 9'h20, 9'h21, 9'h22, 9'h22, 9'h23, 9'h24, 9'h25,
9'h26, 9'h26, 9'h27, 9'h28, 9'h29, 9'h29, 9'h2a, 9'h2b,
9'h2c, 9'h2d, 9'h2d, 9'h2e, 9'h2f, 9'h30, 9'h31, 9'h31,
9'h32, 9'h33, 9'h34, 9'h34, 9'h35, 9'h36, 9'h37, 9'h38,
9'h38, 9'h39, 9'h3a, 9'h3b, 9'h3b, 9'h3c, 9'h3d, 9'h3e,
9'h3f, 9'h3f, 9'h40, 9'h41, 9'h42, 9'h42, 9'h43, 9'h44,
9'h45, 9'h46, 9'h46, 9'h47, 9'h48, 9'h49, 9'h49, 9'h4a,
9'h4b, 9'h4c, 9'h4d, 9'h4d, 9'h4e, 9'h4f, 9'h50, 9'h50,
9'h51, 9'h52, 9'h53, 9'h53, 9'h54, 9'h55, 9'h56, 9'h57,
9'h57, 9'h58, 9'h59, 9'h5a, 9'h5a, 9'h5b, 9'h5c, 9'h5d,
9'h5e, 9'h5e, 9'h5f, 9'h60, 9'h61, 9'h61, 9'h62, 9'h63,
9'h64, 9'h64, 9'h65, 9'h66, 9'h67, 9'h68, 9'h68, 9'h69,
9'h6a, 9'h6b, 9'h6b, 9'h6c, 9'h6d, 9'h6e, 9'h6e, 9'h6f,
9'h70, 9'h71, 9'h71, 9'h72, 9'h73, 9'h74, 9'h75, 9'h75,
9'h76, 9'h77, 9'h78, 9'h78, 9'h79, 9'h7a, 9'h7b, 9'h7b,
9'h7c, 9'h7d, 9'h7e, 9'h7e, 9'h7f, 9'h80, 9'h81, 9'h81,
9'h82, 9'h83, 9'h84, 9'h85, 9'h85, 9'h86, 9'h87, 9'h88,
9'h88, 9'h89, 9'h8a, 9'h8b, 9'h8b, 9'h8c, 9'h8d, 9'h8e,
9'h8e, 9'h8f, 9'h90, 9'h91, 9'h91, 9'h92, 9'h93, 9'h94,
9'h94, 9'h95, 9'h96, 9'h97, 9'h97, 9'h98, 9'h99, 9'h9a,
9'h9a, 9'h9b, 9'h9c, 9'h9d, 9'h9d, 9'h9e, 9'h9f, 9'ha0,
9'ha0, 9'ha1, 9'ha2, 9'ha3, 9'ha3, 9'ha4, 9'ha5, 9'ha5,
9'ha6, 9'ha7, 9'ha8, 9'ha8, 9'ha9, 9'haa, 9'hab, 9'hab,
9'hac, 9'had, 9'hae, 9'hae, 9'haf, 9'hb0, 9'hb1, 9'hb1,
9'hb2, 9'hb3, 9'hb4, 9'hb4, 9'hb5, 9'hb6, 9'hb6, 9'hb7,
9'hb8, 9'hb9, 9'hb9, 9'hba, 9'hbb, 9'hbc, 9'hbc, 9'hbd,
9'hbe, 9'hbe, 9'hbf, 9'hc0, 9'hc1, 9'hc1, 9'hc2, 9'hc3,
9'hc4, 9'hc4, 9'hc5, 9'hc6, 9'hc6, 9'hc7, 9'hc8, 9'hc9,
9'hc9, 9'hca, 9'hcb, 9'hcb, 9'hcc, 9'hcd, 9'hce, 9'hce,
9'hcf, 9'hd0, 9'hd1, 9'hd1, 9'hd2, 9'hd3, 9'hd3, 9'hd4,
9'hd5, 9'hd6, 9'hd6, 9'hd7, 9'hd8, 9'hd8, 9'hd9, 9'hda,
9'hda, 9'hdb, 9'hdc, 9'hdd, 9'hdd, 9'hde, 9'hdf, 9'hdf,
9'he0, 9'he1, 9'he2, 9'he2, 9'he3, 9'he4, 9'he4, 9'he5,
9'he6, 9'he6, 9'he7, 9'he8, 9'he9, 9'he9, 9'hea, 9'heb,
9'heb, 9'hec, 9'hed, 9'hed, 9'hee, 9'hef, 9'hef, 9'hf0,
9'hf1, 9'hf2, 9'hf2, 9'hf3, 9'hf4, 9'hf4, 9'hf5, 9'hf6,
9'hf6, 9'hf7, 9'hf8, 9'hf8, 9'hf9, 9'hfa, 9'hfb, 9'hfb,
9'hfc, 9'hfd, 9'hfd, 9'hfe, 9'hff, 9'hff, 9'h100, 9'h101,
9'h101, 9'h102, 9'h103, 9'h103, 9'h104, 9'h105, 9'h105, 9'h106,
9'h107, 9'h107, 9'h108, 9'h109, 9'h109, 9'h10a, 9'h10b, 9'h10b,
9'h10c, 9'h10d, 9'h10d, 9'h10e, 9'h10f, 9'h10f, 9'h110, 9'h111,
9'h111, 9'h112, 9'h113, 9'h113, 9'h114, 9'h115, 9'h115, 9'h116,
9'h117, 9'h117, 9'h118, 9'h119, 9'h119, 9'h11a, 9'h11b, 9'h11b,
9'h11c, 9'h11d, 9'h11d, 9'h11e, 9'h11e, 9'h11f, 9'h120, 9'h120,
9'h121, 9'h122, 9'h122, 9'h123, 9'h124, 9'h124, 9'h125, 9'h126,
9'h126, 9'h127, 9'h128, 9'h128, 9'h129, 9'h129, 9'h12a, 9'h12b,
9'h12b, 9'h12c, 9'h12d, 9'h12d, 9'h12e, 9'h12f, 9'h12f, 9'h130,
9'h130, 9'h131, 9'h132, 9'h132, 9'h133, 9'h134, 9'h134, 9'h135,
9'h135, 9'h136, 9'h137, 9'h137, 9'h138, 9'h139, 9'h139, 9'h13a,
9'h13a, 9'h13b, 9'h13c, 9'h13c, 9'h13d, 9'h13d, 9'h13e, 9'h13f,
9'h13f, 9'h140, 9'h141, 9'h141, 9'h142, 9'h142, 9'h143, 9'h144,
9'h144, 9'h145, 9'h145, 9'h146, 9'h147, 9'h147, 9'h148, 9'h148,
9'h149, 9'h14a, 9'h14a, 9'h14b, 9'h14b, 9'h14c, 9'h14d, 9'h14d,
9'h14e, 9'h14e, 9'h14f, 9'h150, 9'h150, 9'h151, 9'h151, 9'h152,
9'h152, 9'h153, 9'h154, 9'h154, 9'h155, 9'h155, 9'h156, 9'h157,
9'h157, 9'h158, 9'h158, 9'h159, 9'h159, 9'h15a, 9'h15b, 9'h15b,
9'h15c, 9'h15c, 9'h15d, 9'h15e, 9'h15e, 9'h15f, 9'h15f, 9'h160,
9'h160, 9'h161, 9'h161, 9'h162, 9'h163, 9'h163, 9'h164, 9'h164,
9'h165, 9'h165, 9'h166, 9'h167, 9'h167, 9'h168, 9'h168, 9'h169,
9'h169, 9'h16a, 9'h16a, 9'h16b, 9'h16c, 9'h16c, 9'h16d, 9'h16d,
9'h16e, 9'h16e, 9'h16f, 9'h16f, 9'h170, 9'h170, 9'h171, 9'h172,
9'h172, 9'h173, 9'h173, 9'h174, 9'h174, 9'h175, 9'h175, 9'h176,
9'h176, 9'h177, 9'h177, 9'h178, 9'h179, 9'h179, 9'h17a, 9'h17a,
9'h17b, 9'h17b, 9'h17c, 9'h17c, 9'h17d, 9'h17d, 9'h17e, 9'h17e,
9'h17f, 9'h17f, 9'h180, 9'h180, 9'h181, 9'h181, 9'h182, 9'h182,
9'h183, 9'h183, 9'h184, 9'h184, 9'h185, 9'h185, 9'h186, 9'h186,
9'h187, 9'h188, 9'h188, 9'h189, 9'h189, 9'h18a, 9'h18a, 9'h18b,
9'h18b, 9'h18c, 9'h18c, 9'h18c, 9'h18d, 9'h18d, 9'h18e, 9'h18e,
9'h18f, 9'h18f, 9'h190, 9'h190, 9'h191, 9'h191, 9'h192, 9'h192,
9'h193, 9'h193, 9'h194, 9'h194, 9'h195, 9'h195, 9'h196, 9'h196,
9'h197, 9'h197, 9'h198, 9'h198, 9'h199, 9'h199, 9'h19a, 9'h19a,
9'h19a, 9'h19b, 9'h19b, 9'h19c, 9'h19c, 9'h19d, 9'h19d, 9'h19e,
9'h19e, 9'h19f, 9'h19f, 9'h1a0, 9'h1a0, 9'h1a0, 9'h1a1, 9'h1a1,
9'h1a2, 9'h1a2, 9'h1a3, 9'h1a3, 9'h1a4, 9'h1a4, 9'h1a4, 9'h1a5,
9'h1a5, 9'h1a6, 9'h1a6, 9'h1a7, 9'h1a7, 9'h1a8, 9'h1a8, 9'h1a8,
9'h1a9, 9'h1a9, 9'h1aa, 9'h1aa, 9'h1ab, 9'h1ab, 9'h1ab, 9'h1ac,
9'h1ac, 9'h1ad, 9'h1ad, 9'h1ae, 9'h1ae, 9'h1ae, 9'h1af, 9'h1af,
9'h1b0, 9'h1b0, 9'h1b1, 9'h1b1, 9'h1b1, 9'h1b2, 9'h1b2, 9'h1b3,
9'h1b3, 9'h1b3, 9'h1b4, 9'h1b4, 9'h1b5, 9'h1b5, 9'h1b5, 9'h1b6,
9'h1b6, 9'h1b7, 9'h1b7, 9'h1b8, 9'h1b8, 9'h1b8, 9'h1b9, 9'h1b9,
9'h1b9, 9'h1ba, 9'h1ba, 9'h1bb, 9'h1bb, 9'h1bb, 9'h1bc, 9'h1bc,
9'h1bd, 9'h1bd, 9'h1bd, 9'h1be, 9'h1be, 9'h1bf, 9'h1bf, 9'h1bf,
9'h1c0, 9'h1c0, 9'h1c0, 9'h1c1, 9'h1c1, 9'h1c2, 9'h1c2, 9'h1c2,
9'h1c3, 9'h1c3, 9'h1c3, 9'h1c4, 9'h1c4, 9'h1c4, 9'h1c5, 9'h1c5,
9'h1c6, 9'h1c6, 9'h1c6, 9'h1c7, 9'h1c7, 9'h1c7, 9'h1c8, 9'h1c8,
9'h1c8, 9'h1c9, 9'h1c9, 9'h1c9, 9'h1ca, 9'h1ca, 9'h1cb, 9'h1cb,
9'h1cb, 9'h1cc, 9'h1cc, 9'h1cc, 9'h1cd, 9'h1cd, 9'h1cd, 9'h1ce,
9'h1ce, 9'h1ce, 9'h1cf, 9'h1cf, 9'h1cf, 9'h1d0, 9'h1d0, 9'h1d0,
9'h1d1, 9'h1d1, 9'h1d1, 9'h1d2, 9'h1d2, 9'h1d2, 9'h1d3, 9'h1d3,
9'h1d3, 9'h1d3, 9'h1d4, 9'h1d4, 9'h1d4, 9'h1d5, 9'h1d5, 9'h1d5,
9'h1d6, 9'h1d6, 9'h1d6, 9'h1d7, 9'h1d7, 9'h1d7, 9'h1d8, 9'h1d8,
9'h1d8, 9'h1d8, 9'h1d9, 9'h1d9, 9'h1d9, 9'h1da, 9'h1da, 9'h1da,
9'h1da, 9'h1db, 9'h1db, 9'h1db, 9'h1dc, 9'h1dc, 9'h1dc, 9'h1dc,
9'h1dd, 9'h1dd, 9'h1dd, 9'h1de, 9'h1de, 9'h1de, 9'h1de, 9'h1df,
9'h1df, 9'h1df, 9'h1e0, 9'h1e0, 9'h1e0, 9'h1e0, 9'h1e1, 9'h1e1,
9'h1e1, 9'h1e1, 9'h1e2, 9'h1e2, 9'h1e2, 9'h1e2, 9'h1e3, 9'h1e3,
9'h1e3, 9'h1e3, 9'h1e4, 9'h1e4, 9'h1e4, 9'h1e4, 9'h1e5, 9'h1e5,
9'h1e5, 9'h1e5, 9'h1e6, 9'h1e6, 9'h1e6, 9'h1e6, 9'h1e7, 9'h1e7,
9'h1e7, 9'h1e7, 9'h1e8, 9'h1e8, 9'h1e8, 9'h1e8, 9'h1e9, 9'h1e9,
9'h1e9, 9'h1e9, 9'h1e9, 9'h1ea, 9'h1ea, 9'h1ea, 9'h1ea, 9'h1eb,
9'h1eb, 9'h1eb, 9'h1eb, 9'h1eb, 9'h1ec, 9'h1ec, 9'h1ec, 9'h1ec,
9'h1ec, 9'h1ed, 9'h1ed, 9'h1ed, 9'h1ed, 9'h1ee, 9'h1ee, 9'h1ee,
9'h1ee, 9'h1ee, 9'h1ef, 9'h1ef, 9'h1ef, 9'h1ef, 9'h1ef, 9'h1ef,
9'h1f0, 9'h1f0, 9'h1f0, 9'h1f0, 9'h1f0, 9'h1f1, 9'h1f1, 9'h1f1,
9'h1f1, 9'h1f1, 9'h1f2, 9'h1f2, 9'h1f2, 9'h1f2, 9'h1f2, 9'h1f2,
9'h1f3, 9'h1f3, 9'h1f3, 9'h1f3, 9'h1f3, 9'h1f3, 9'h1f4, 9'h1f4,
9'h1f4, 9'h1f4, 9'h1f4, 9'h1f4, 9'h1f5, 9'h1f5, 9'h1f5, 9'h1f5,
9'h1f5, 9'h1f5, 9'h1f5, 9'h1f6, 9'h1f6, 9'h1f6, 9'h1f6, 9'h1f6,
9'h1f6, 9'h1f7, 9'h1f7, 9'h1f7, 9'h1f7, 9'h1f7, 9'h1f7, 9'h1f7,
9'h1f7, 9'h1f8, 9'h1f8, 9'h1f8, 9'h1f8, 9'h1f8, 9'h1f8, 9'h1f8,
9'h1f9, 9'h1f9, 9'h1f9, 9'h1f9, 9'h1f9, 9'h1f9, 9'h1f9, 9'h1f9,
9'h1f9, 9'h1fa, 9'h1fa, 9'h1fa, 9'h1fa, 9'h1fa, 9'h1fa, 9'h1fa,
9'h1fa, 9'h1fa, 9'h1fb, 9'h1fb, 9'h1fb, 9'h1fb, 9'h1fb, 9'h1fb,
9'h1fb, 9'h1fb, 9'h1fb, 9'h1fb, 9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc,
9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc, 9'h1fc,
9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd,
9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fd, 9'h1fe,
9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe,
9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe,
9'h1fe, 9'h1fe, 9'h1fe, 9'h1fe, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff,
9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff,
9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff,
9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff, 9'h1ff
};

assign value = _table[theta_dash];

endmodule

// Generate single color component
module NormalGenerator (
    input logic[11:0] t,
    output logic[9:0] sin,
    output logic[9:0] cos
);

logic[1:0] t_alpha;
logic[9:0] t_beta;
assign t_alpha = t[11:10];
assign t_beta = t[9:0];

logic[9:0] t_dash_for_sin;
logic[8:0] sin_table_value;
logic[9:0] sin_value;
SinTable sin_table(
    .theta_dash(t_dash_for_sin),
    .value(sin_table_value)
);

always_comb begin
    if (t_alpha == 'b00) begin
        t_dash_for_sin <= t_beta;
        sin_value <= sin_table_value;
    end else if (t_alpha == 'b01) begin
        t_dash_for_sin <= 'd1023 - t_beta;
        sin_value <= sin_table_value;
    end else if (t_alpha == 'b10) begin
        t_dash_for_sin <= t_beta;
        sin_value <= -sin_table_value;
    end else begin // 'b11
        t_dash_for_sin <= 'd1023 - t_beta;
        sin_value <= -sin_table_value;
    end
end


logic[9:0] t_dash_for_cos;
logic[8:0] cos_table_value;
logic[8:0] cos_value;
SinTable cos_table(
    .theta_dash(t_dash_for_cos),
    .value(cos_table_value)
);

always_comb begin
    if (t_alpha == 'b00) begin
        t_dash_for_cos <= 'd1023 - t_beta;
        cos_value <= cos_table_value;
    end else if (t_alpha == 'b01) begin
        t_dash_for_cos <= t_beta;
        cos_value <= -cos_table_value;
    end else if (t_alpha == 'b10) begin
        t_dash_for_cos <= 'd1023 - t_beta;
        cos_value <= -cos_table_value;
    end else begin // 'b11
        t_dash_for_cos <= t_beta;
        cos_value <= cos_table_value;
    end
end

always_comb begin
    sin <= sin_value;
    cos <= cos_value;
end

endmodule

module ValueGenerator (
    input logic[5:0] x,
    input logic[5:0] y,
    input logic[9:0] sin,
    input logic[9:0] cos,
    output logic value
);

logic[5:0] x_dash;
logic[5:0] y_dash;
assign x_dash = x - 'd32;
assign y_dash = y - 'd32;

logic[18:0] dot_product;
assign dot_product = x_dash * cos + y_dash * cos;
assign out = dot_product[18];

endmodule

module ComponentPipeline (
    input logic clock,
    input logic reset,

    input logic[5:0] x,
    input logic[5:0] y,
    input logic[9:0] t,

    input logic[9:0] t_offset,

    output logic value
);

// pipeline stage 0

logic[5:0] s0_x;
logic[5:0] s0_y;
logic[9:0] s0_t;
logic[9:0] s0_t_offset;

always_comb begin
    s0_x = x;
    s0_y = y;
    s0_t = t;
    s0_t_offset = t_offset;
end

logic[9:0] s0_sin;
logic[9:0] s0_cos;
NormalGenerator s0_normal(
    .t(s0_t + s0_t_offset),
    .sin(s0_sin),
    .cos(s0_cos)
);

// pipeline stage 1

logic[5:0] s1_x;
logic[5:0] s1_y;
logic[9:0] s1_sin;
logic[9:0] s1_cos;
logic s1_value;

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        s1_x = 'b0;
        s1_y = 'b0;
        s1_sin = 'b0;
        s1_cos = 'b0;
    end else begin
        s1_x = s0_x;
        s1_y = s0_y;
        s1_sin = s0_sin;
        s1_cos = s0_cos;
    end
end

ValueGenerator generator(
    .x(s1_x),
    .y(s1_y),
    .sin(s1_sin),
    .cos(s1_cos),
    .value(s1_value)
);

// pipeline stage 2
logic s2_value;

always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
        s2_value = s1_value;
    end else begin
        s2_value = 'b0;
    end
end

always_comb begin
    value = s2_value;
end

endmodule

module TestPatternGenerator (
    input logic clock,
    input logic reset,

    input logic[5:0] x,
    input logic[5:0] y,
    input logic[9:0] t,

    output logic r,
    output logic g,
    output logic b
);


endmodule

