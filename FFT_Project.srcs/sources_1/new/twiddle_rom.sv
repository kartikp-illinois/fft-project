`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 04:36:48 PM
// Design Name: 
// Module Name: twiddle_rom
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


module twiddle_rom #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 8
)(
    input  logic clk,
    input  logic [$clog2(FFT_SIZE)-1:0] addr,
    output logic signed [WIDTH-1:0] tw_re,
    output logic signed [WIDTH-1:0] tw_im
);

// Twiddle factors for FFT: W_N^k = e^(-j*2*pi*k/N)
// Stored in Q15 fixed-point format (sign bit + 15 fractional bits)
// Pre-computed for 8-point FFT (extendable to larger sizes)

logic signed [WIDTH-1:0] twiddle_real [0:FFT_SIZE-1];
logic signed [WIDTH-1:0] twiddle_imag [0:FFT_SIZE-1];

// Initialize twiddle factors for 8-point FFT
initial begin
    // W_8^0 = 1.0 + 0j
    twiddle_real[0] = 16'h7FFF; twiddle_imag[0] = 16'h0000;
    // W_8^1 = 0.707 - 0.707j
    twiddle_real[1] = 16'h5A82; twiddle_imag[1] = 16'hA57E;
    // W_8^2 = 0.0 - 1.0j
    twiddle_real[2] = 16'h0000; twiddle_imag[2] = 16'h8000;
    // W_8^3 = -0.707 - 0.707j
    twiddle_real[3] = 16'hA57E; twiddle_imag[3] = 16'hA57E;
    // W_8^4 = -1.0 + 0j
    twiddle_real[4] = 16'h8000; twiddle_imag[4] = 16'h0000;
    // W_8^5 = -0.707 + 0.707j
    twiddle_real[5] = 16'hA57E; twiddle_imag[5] = 16'h5A82;
    // W_8^6 = 0.0 + 1.0j
    twiddle_real[6] = 16'h0000; twiddle_imag[6] = 16'h7FFF;
    // W_8^7 = 0.707 + 0.707j
    twiddle_real[7] = 16'h5A82; twiddle_imag[7] = 16'h5A82;
end

// Pipelined ROM output (1 cycle latency)
always_ff @(posedge clk) begin
    tw_re <= twiddle_real[addr];
    tw_im <= twiddle_imag[addr];
end

endmodule