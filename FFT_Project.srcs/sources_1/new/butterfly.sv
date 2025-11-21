`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 04:36:09 PM
// Design Name: 
// Module Name: butterfly
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module butterfly #(
    parameter WIDTH = 16,
    parameter FRAC_BITS = 15  // Q15 fixed-point format
)(
    input  logic clk,
    input  logic rst,
    input  logic valid_in,
    
    // Input complex numbers
    input  logic signed [WIDTH-1:0] x0_re, x0_im,
    input  logic signed [WIDTH-1:0] x1_re, x1_im,
    
    // Twiddle factor
    input  logic signed [WIDTH-1:0] tw_re, tw_im,
    
    // Output complex numbers
    output logic signed [WIDTH-1:0] y0_re, y0_im,
    output logic signed [WIDTH-1:0] y1_re, y1_im,
    output logic valid_out
);

// Pipeline stages: 5-stage pipeline for high-frequency operation
// Stage 0: Input registration
// Stage 1: Multiply operations (4 DSP multipliers)
// Stage 2: Multiply result registration
// Stage 3: Add/subtract operations
// Stage 4: Output registration

// Stage 0: Input registers
logic signed [WIDTH-1:0] x0_re_r0, x0_im_r0, x1_re_r0, x1_im_r0;
logic signed [WIDTH-1:0] tw_re_r0, tw_im_r0;
logic valid_r0;

// Stage 1: Multiplication products (use full precision)
logic signed [2*WIDTH-1:0] prod1, prod2, prod3, prod4;
logic signed [WIDTH-1:0] x0_re_r1, x0_im_r1;
logic valid_r1;

// Stage 2: Registered multiplication results
logic signed [2*WIDTH-1:0] prod1_r, prod2_r, prod3_r, prod4_r;
logic signed [WIDTH-1:0] x0_re_r2, x0_im_r2;
logic valid_r2;

// Stage 3: Complex multiply results and add/sub intermediate
logic signed [WIDTH-1:0] prod_re, prod_im;
logic signed [WIDTH-1:0] x0_re_r3, x0_im_r3;
logic valid_r3;

// Stage 4: Final outputs registered
logic signed [WIDTH-1:0] y0_re_r, y0_im_r, y1_re_r, y1_im_r;
logic valid_r4;

always_ff @(posedge clk) begin
    if (rst) begin
        valid_r0 <= 0;
        valid_r1 <= 0;
        valid_r2 <= 0;
        valid_r3 <= 0;
        valid_r4 <= 0;
        valid_out <= 0;
    end else begin
        // ===== STAGE 0: Input Registration =====
        x0_re_r0 <= x0_re;
        x0_im_r0 <= x0_im;
        x1_re_r0 <= x1_re;
        x1_im_r0 <= x1_im;
        tw_re_r0 <= tw_re;
        tw_im_r0 <= tw_im;
        valid_r0 <= valid_in;
        
        // ===== STAGE 1: Multiplications (4 DSP blocks) =====
        // Complex multiply: (x1_re + j*x1_im) * (tw_re + j*tw_im)
        // = (x1_re*tw_re - x1_im*tw_im) + j*(x1_re*tw_im + x1_im*tw_re)
        prod1 <= x1_re_r0 * tw_re_r0;  // Real part: positive term
        prod2 <= x1_im_r0 * tw_im_r0;  // Real part: negative term
        prod3 <= x1_re_r0 * tw_im_r0;  // Imag part: positive term
        prod4 <= x1_im_r0 * tw_re_r0;  // Imag part: positive term
        x0_re_r1 <= x0_re_r0;
        x0_im_r1 <= x0_im_r0;
        valid_r1 <= valid_r0;
        
        // ===== STAGE 2: Register Multiplication Results =====
        prod1_r <= prod1;
        prod2_r <= prod2;
        prod3_r <= prod3;
        prod4_r <= prod4;
        x0_re_r2 <= x0_re_r1;
        x0_im_r2 <= x0_im_r1;
        valid_r2 <= valid_r1;
        
        // ===== STAGE 3: Combine Products & Scale =====
        // Scale down from 2*WIDTH to WIDTH (remove lower FRAC_BITS)
        prod_re <= ((prod1_r - prod2_r) >>> FRAC_BITS);
        prod_im <= ((prod3_r + prod4_r) >>> FRAC_BITS);
        x0_re_r3 <= x0_re_r2;
        x0_im_r3 <= x0_im_r2;
        valid_r3 <= valid_r2;
        
        // ===== STAGE 4: Butterfly Add/Subtract =====
        // y0 = x0 + (x1 * twiddle)
        // y1 = x0 - (x1 * twiddle)
        y0_re_r <= x0_re_r3 + prod_re;
        y0_im_r <= x0_im_r3 + prod_im;
        y1_re_r <= x0_re_r3 - prod_re;
        y1_im_r <= x0_im_r3 - prod_im;
        valid_r4 <= valid_r3;
        
        // ===== STAGE 5: Output Registration =====
        y0_re <= y0_re_r;
        y0_im <= y0_im_r;
        y1_re <= y1_re_r;
        y1_im <= y1_im_r;
        valid_out <= valid_r4;
    end
end

endmodule
