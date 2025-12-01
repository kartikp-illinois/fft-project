//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 08:05:07 PM
// Design Name: 
// Module Name: fft_minimal_tb
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
`timescale 1ns / 1ps

module fft_minimal_tb;

parameter WIDTH = 16;
parameter FFT_SIZE = 256;
parameter ADDR_WIDTH = $clog2(FFT_SIZE);

logic clk, rst, start, load_enable, done, busy;
logic [ADDR_WIDTH-1:0] load_addr, read_addr;
logic signed [WIDTH-1:0] load_data_re, load_data_im;
logic signed [WIDTH-1:0] read_data_re, read_data_im;

// DUT Instance
fft_top #(
    .WIDTH(WIDTH),
    .FFT_SIZE(FFT_SIZE)
) dut (.*);

// 100MHz Clock
initial clk = 0;
always #5 clk = ~clk;

// Bit-reversal function for 256-point
function [7:0] bit_reverse(input [7:0] in);
    bit_reverse = {in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]};
endfunction

// Calculate magnitude approximation
function real magnitude(input signed [15:0] re, input signed [15:0] im);
    real r, i;
    r = re / 32768.0;
    i = im / 32768.0;
    return $sqrt(r*r + i*i);
endfunction

// --- TEST TASKS ---

task run_test(string name, int input_type, int freq_k);
    integer i;
    real angle;
    real mag;
    
    $display("\n=================================================");
    $display("TEST: %s", name);
    $display("=================================================");
    
    // 1. Reset
    rst = 1; start = 0; load_enable = 0;
    repeat(5) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);
    
    // 2. Load Data
    load_enable = 1;
    for (i = 0; i < FFT_SIZE; i++) begin
        load_addr = bit_reverse(i);
        case (input_type)
            0: begin // DC (0.5)
                load_data_re = 16'h4000; 
                load_data_im = 0;
            end
            1: begin // Impulse at 0 (1.0)
                load_data_re = (i == 0) ? 16'h7FFF : 0;
                load_data_im = 0;
            end
            2: begin // Cosine at freq_k (0.5 amplitude)
                angle = 2.0 * 3.14159 * freq_k * i / FFT_SIZE;
                load_data_re = $rtoi(16384.0 * $cos(angle));
                load_data_im = 0;
            end
        endcase
        @(posedge clk);
    end
    load_enable = 0;
    @(posedge clk);
    
    // 3. Run FFT
    start = 1;
    @(posedge clk);
    start = 0;
    wait(done);
    repeat(10) @(posedge clk);
    
    // 4. Read & Check Results (with bit-reversal)
    $display("Bin | Mag  | Raw (Re, Im)");
    $display("----|------|-----------------");
    
    // Only print first few bins and the expected peak bin
    for (i = 0; i < FFT_SIZE; i++) begin
        read_addr = i; // Read in bit-reversed order
        repeat(2) @(posedge clk);   // Wait for read latency
        
        mag = magnitude(read_data_re, read_data_im);
        
        // Print if magnitude is significant OR it's a low bin index
        if (i < 8 || mag > 0.1) begin
            $display("%3d | %.3f | (%6d, %6d) %s", 
                     i, mag, read_data_re, read_data_im, 
                     (mag > 0.1) ? "<- PEAK" : "");
        end
    end
endtask

// --- MAIN EXECUTION ---

initial begin
    // Test 1: DC Signal (Expect peak at Bin 0)
    run_test("DC Signal (Input 0.5)", 0, 0);
    
    // Test 2: Impulse (Expect flat magnitude ~0.004 across all bins)
    // Note: With 1/N scaling, impulse output is very small
    run_test("Impulse (Input 1.0)", 1, 0);
    
    // Test 3: Cosine k=5 (Expect peaks at Bin 5 and Bin 251)
    run_test("Cosine Wave (k=5)", 2, 5);
    
        $display("\n=================================================");
        $display("ALL TESTS COMPLETE");
        $display("=================================================");
        $finish;
end

// Timeout watchdog
initial begin
    #25000000; // 25ms
    $display("\nERROR: Simulation Timeout!");
    $finish;
end

endmodule
