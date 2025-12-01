`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 04:37:29 PM
// Design Name: 
// Module Name: fft_bram
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

module fft_bram #(
    parameter WIDTH = 16,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic clk,
    
    // Port A: Read/Write
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic we_a,
    input  logic signed [WIDTH-1:0] din_a_re, din_a_im,
    output logic signed [WIDTH-1:0] dout_a_re, dout_a_im,
    
    // Port B: Read/Write (Was Read-Only, now RW)
    input  logic [ADDR_WIDTH-1:0] addr_b,
    input  logic we_b,                                   // NEW
    input  logic signed [WIDTH-1:0] din_b_re, din_b_im,  // NEW
    output logic signed [WIDTH-1:0] dout_b_re, dout_b_im
);

// Dual-port block RAM
logic signed [WIDTH-1:0] mem_re [0:DEPTH-1];
logic signed [WIDTH-1:0] mem_im [0:DEPTH-1];

// Port A
always_ff @(posedge clk) begin
    if (we_a) begin
        mem_re[addr_a] <= din_a_re;
        mem_im[addr_a] <= din_a_im;
    end
    dout_a_re <= mem_re[addr_a];
    dout_a_im <= mem_im[addr_a];
end

// Port B
always_ff @(posedge clk) begin
    if (we_b) begin  // NEW: Write capability on Port B
        mem_re[addr_b] <= din_b_re;
        mem_im[addr_b] <= din_b_im;
    end
    dout_b_re <= mem_re[addr_b];
    dout_b_im <= mem_im[addr_b];
end

initial begin
    for (int i = 0; i < DEPTH; i++) begin
        mem_re[i] = 0;
        mem_im[i] = 0;
    end
end

endmodule
