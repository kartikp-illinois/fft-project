`timescale 1ns / 1ps

// Combinational radix-2 decimation-in-time butterfly.
// Inputs and twiddle factors are signed Q1.(WIDTH-1). Each output is divided
// by two, so eight stages produce an overall 1/256 scale factor.
module butterfly #(
    parameter WIDTH = 16,
    parameter FRAC_BITS = WIDTH - 1
)(
    input  logic signed [WIDTH-1:0] x0_re, x0_im,
    input  logic signed [WIDTH-1:0] x1_re, x1_im,
    input  logic signed [WIDTH-1:0] tw_re, tw_im,
    output logic signed [WIDTH-1:0] y0_re, y0_im,
    output logic signed [WIDTH-1:0] y1_re, y1_im
);

    localparam PRODUCT_WIDTH = 2 * WIDTH;

    logic signed [PRODUCT_WIDTH-1:0] product_rr;
    logic signed [PRODUCT_WIDTH-1:0] product_ii;
    logic signed [PRODUCT_WIDTH-1:0] product_ri;
    logic signed [PRODUCT_WIDTH-1:0] product_ir;
    logic signed [PRODUCT_WIDTH:0] product_re_full;
    logic signed [PRODUCT_WIDTH:0] product_im_full;
    logic signed [WIDTH:0] product_re_q;
    logic signed [WIDTH:0] product_im_q;
    logic signed [WIDTH+1:0] x0_re_ext;
    logic signed [WIDTH+1:0] x0_im_ext;
    logic signed [WIDTH+1:0] product_re_ext;
    logic signed [WIDTH+1:0] product_im_ext;
    logic signed [WIDTH+1:0] scaled_y0_re;
    logic signed [WIDTH+1:0] scaled_y0_im;
    logic signed [WIDTH+1:0] scaled_y1_re;
    logic signed [WIDTH+1:0] scaled_y1_im;

    function automatic logic signed [WIDTH-1:0] saturate(
        input logic signed [WIDTH+1:0] value
    );
        logic signed [WIDTH+1:0] maximum;
        logic signed [WIDTH+1:0] minimum;
        begin
            maximum = (1 <<< (WIDTH - 1)) - 1;
            minimum = -(1 <<< (WIDTH - 1));
            if (value > maximum)
                saturate = {1'b0, {(WIDTH-1){1'b1}}};
            else if (value < minimum)
                saturate = {1'b1, {(WIDTH-1){1'b0}}};
            else
                saturate = value[WIDTH-1:0];
        end
    endfunction

    always_comb begin
        product_rr = x1_re * tw_re;
        product_ii = x1_im * tw_im;
        product_ri = x1_re * tw_im;
        product_ir = x1_im * tw_re;

        product_re_full = product_rr - product_ii;
        product_im_full = product_ri + product_ir;
        product_re_q = product_re_full >>> FRAC_BITS;
        product_im_q = product_im_full >>> FRAC_BITS;

        x0_re_ext = {{2{x0_re[WIDTH-1]}}, x0_re};
        x0_im_ext = {{2{x0_im[WIDTH-1]}}, x0_im};
        product_re_ext = {{1{product_re_q[WIDTH]}}, product_re_q};
        product_im_ext = {{1{product_im_q[WIDTH]}}, product_im_q};

        scaled_y0_re = (x0_re_ext + product_re_ext) >>> 1;
        scaled_y0_im = (x0_im_ext + product_im_ext) >>> 1;
        scaled_y1_re = (x0_re_ext - product_re_ext) >>> 1;
        scaled_y1_im = (x0_im_ext - product_im_ext) >>> 1;

        y0_re = saturate(scaled_y0_re);
        y0_im = saturate(scaled_y0_im);
        y1_re = saturate(scaled_y1_re);
        y1_im = saturate(scaled_y1_im);
    end

endmodule
