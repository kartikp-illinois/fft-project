`timescale 1ns / 1ps

// Pipelined radix-2 decimation-in-time butterfly.
// Inputs and twiddle factors are signed Q1.(WIDTH-1). Each output is divided
// by two, so eight stages produce an overall 1/256 scale factor.
module butterfly #(
    parameter WIDTH = 16,
    parameter FRAC_BITS = WIDTH - 1
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [WIDTH-1:0] x0_re, x0_im,
    input  logic signed [WIDTH-1:0] x1_re, x1_im,
    input  logic signed [WIDTH-1:0] tw_re, tw_im,
    output logic signed [WIDTH-1:0] y0_re, y0_im,
    output logic signed [WIDTH-1:0] y1_re, y1_im
);

    localparam PRODUCT_WIDTH = 2 * WIDTH;

    logic signed [PRODUCT_WIDTH-1:0] product_rr_q;
    logic signed [PRODUCT_WIDTH-1:0] product_ii_q;
    logic signed [PRODUCT_WIDTH-1:0] product_ri_q;
    logic signed [PRODUCT_WIDTH-1:0] product_ir_q;
    logic signed [WIDTH-1:0] x0_re_q;
    logic signed [WIDTH-1:0] x0_im_q;
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

    // Register the four multiplies and matching x0 operand. The controller's
    // memory-settling cycle fills this stage before writeback, breaking the
    // former BRAM-to-DSP-to-BRAM critical path at 100 MHz.
    always_ff @(posedge clk) begin
        if (rst) begin
            product_rr_q <= '0;
            product_ii_q <= '0;
            product_ri_q <= '0;
            product_ir_q <= '0;
            x0_re_q <= '0;
            x0_im_q <= '0;
        end else begin
            product_rr_q <= x1_re * tw_re;
            product_ii_q <= x1_im * tw_im;
            product_ri_q <= x1_re * tw_im;
            product_ir_q <= x1_im * tw_re;
            x0_re_q <= x0_re;
            x0_im_q <= x0_im;
        end
    end

    always_comb begin
        product_re_full = product_rr_q - product_ii_q;
        product_im_full = product_ri_q + product_ir_q;
        product_re_q = product_re_full >>> FRAC_BITS;
        product_im_q = product_im_full >>> FRAC_BITS;

        x0_re_ext = {{2{x0_re_q[WIDTH-1]}}, x0_re_q};
        x0_im_ext = {{2{x0_im_q[WIDTH-1]}}, x0_im_q};
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
