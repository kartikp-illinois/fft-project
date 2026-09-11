`timescale 1ns / 1ps

// Four-stage radix-2 decimation-in-time butterfly.
// Twiddle factors use Q1.15 fixed-point representation.
module butterfly #(
    parameter WIDTH = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic valid_in,
    input  logic signed [WIDTH-1:0] x0_re, x0_im,
    input  logic signed [WIDTH-1:0] x1_re, x1_im,
    input  logic signed [WIDTH-1:0] tw_re, tw_im,
    output logic signed [33:0] y0_re, y0_im,
    output logic signed [33:0] y1_re, y1_im,
    output logic valid_out
);

    logic signed [33:0] x0_re_r1, x0_im_r1;
    logic signed [33:0] x1_re_r1, x1_im_r1;
    logic signed [33:0] tw_re_r1, tw_im_r1;
    logic signed [33:0] x0_re_r2, x0_im_r2;
    logic signed [33:0] x0_re_r3, x0_im_r3;
    logic signed [33:0] p1, p2, p3, p4;
    logic signed [33:0] prod_re, prod_im;
    logic [3:0] valid_pipe;

    // Stage 1: sign-extend the complex inputs and twiddle factor.
    always_ff @(posedge clk) begin
        x0_re_r1 <= {{18{x0_re[WIDTH-1]}}, x0_re};
        x0_im_r1 <= {{18{x0_im[WIDTH-1]}}, x0_im};
        x1_re_r1 <= {{18{x1_re[WIDTH-1]}}, x1_re};
        x1_im_r1 <= {{18{x1_im[WIDTH-1]}}, x1_im};
        tw_re_r1 <= {{18{tw_re[WIDTH-1]}}, tw_re};
        tw_im_r1 <= {{18{tw_im[WIDTH-1]}}, tw_im};
    end

    // Stage 2: compute the four real products for x1 * twiddle.
    always_ff @(posedge clk) begin
        p1 <= x1_re_r1 * tw_re_r1;
        p2 <= x1_im_r1 * tw_im_r1;
        p3 <= x1_re_r1 * tw_im_r1;
        p4 <= x1_im_r1 * tw_re_r1;
        x0_re_r2 <= x0_re_r1;
        x0_im_r2 <= x0_im_r1;
    end

    // Stage 3: form the complex product and return it to Q1.15 scale.
    always_ff @(posedge clk) begin
        prod_re <= (p1 - p2) >>> 15;
        prod_im <= (p3 + p4) >>> 15;
        x0_re_r3 <= x0_re_r2;
        x0_im_r3 <= x0_im_r2;
    end

    // Stage 4: butterfly sum and difference.
    always_ff @(posedge clk) begin
        if (rst) begin
            y0_re <= 0;
            y0_im <= 0;
            y1_re <= 0;
            y1_im <= 0;
        end else begin
            y0_re <= x0_re_r3 + prod_re;
            y0_im <= x0_im_r3 + prod_im;
            y1_re <= x0_re_r3 - prod_re;
            y1_im <= x0_im_r3 - prod_im;
        end
    end

    always_ff @(posedge clk) begin
        if (rst)
            valid_pipe <= 0;
        else
            valid_pipe <= {valid_pipe[2:0], valid_in};
    end

    assign valid_out = valid_pipe[3];

endmodule
