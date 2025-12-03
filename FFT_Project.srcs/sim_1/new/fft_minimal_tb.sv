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

// Calculate magnitude using Alpha Max + Beta Min approximation
// This matches your hardware: magnitude ? Max + (3/8)*Min
function integer magnitude_approx(input signed [15:0] re, input signed [15:0] im);
    integer abs_re, abs_im;
    integer max_val, min_val;
    integer beta_min;
    
    // Absolute values
    abs_re = (re < 0) ? -re : re;
    abs_im = (im < 0) ? -im : im;
    
    // Max / Min
    if (abs_re >= abs_im) begin
        max_val = abs_re;
        min_val = abs_im;
    end else begin
        max_val = abs_im;
        min_val = abs_re;
    end
    
    // Beta * Min ? 3/8 * Min = Min/4 + Min/8
    beta_min = (min_val >> 2) + (min_val >> 3);
    
    // Magnitude ? Max + Beta*Min
    magnitude_approx = max_val + beta_min;
endfunction

// Also provide exact magnitude for comparison
function real magnitude_exact(input signed [15:0] re, input signed [15:0] im);
    real r, i;
    r = re;
    i = im;
    return $sqrt(r*r + i*i);
endfunction

// Absolute value function for real numbers
function real abs_real(input real x);
    abs_real = (x < 0.0) ? -x : x;
endfunction

// --- TEST TASKS ---

task run_test(string name, int input_type, int freq_k);
    integer i;
    real angle;
    integer mag_approx;
    real mag_exact;
    integer max_mag;
    integer peak_bin;
    real error_sum;
    integer error_count;
    real error_pct;
    
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
    
    // 4. Read & Check Results
    $display("\n=== ALL FFT OUTPUT BINS ===");
    $display("Bin | Mag(Approx) | Mag(Exact) | Error%% | Real     | Imag     | Hex(Re)  | Hex(Im)");
    $display("----|-------------|------------|--------|----------|----------|----------|----------");
    
    max_mag = 0;
    peak_bin = 0;
    error_sum = 0.0;
    error_count = 0;
    
    // Read and display all bins
    for (i = 0; i < FFT_SIZE; i++) begin
        read_addr = i;
        repeat(2) @(posedge clk);   // Wait for read latency
        
        mag_approx = magnitude_approx(read_data_re, read_data_im);
        mag_exact = magnitude_exact(read_data_re, read_data_im);
        
        // Track peak
        if (mag_approx > max_mag) begin
            max_mag = mag_approx;
            peak_bin = i;
        end
        
        // Calculate approximation error
        if (mag_exact > 0.0) begin
            error_pct = abs_real((mag_approx - mag_exact) / mag_exact * 100.0);
            error_sum += error_pct;
            error_count++;
        end else begin
            error_pct = 0.0;
        end
        
        // Display all bins
        $display("%3d | %11d | %10.2f | %6.2f | %8d | %8d | %04X | %04X %s", 
                 i, 
                 mag_approx,
                 mag_exact,
                 error_pct,
                 read_data_re, 
                 read_data_im,
                 read_data_re & 16'hFFFF,
                 read_data_im & 16'hFFFF,
                 (mag_approx > 1000) ? " <-- PEAK" : "");
    end
    
    // Summary statistics
    $display("\n=== SUMMARY ===");
    $display("Peak Bin: %d", peak_bin);
    $display("Peak Magnitude (Approx): %d", max_mag);
    $display("Peak Magnitude (Exact): %.2f", magnitude_exact(read_data_re, read_data_im));
    if (error_count > 0) begin
        $display("Average Approximation Error: %.2f%%", error_sum / error_count);
    end
    
endtask

// Compact version for quick scanning
task run_test_compact(string name, int input_type, int freq_k);
    integer i;
    real angle;
    integer mag_approx;
    
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
    
    // 4. Compact Display
    $display("\n=== FFT MAGNITUDE SPECTRUM (16 bins per row) ===");
    
    for (i = 0; i < FFT_SIZE; i++) begin
        read_addr = i;
        repeat(2) @(posedge clk);
        mag_approx = magnitude_approx(read_data_re, read_data_im);
        
        if (i % 16 == 0)
            $write("\nBin %3d-%3d: ", i, i+15);
        
        $write("%5d ", mag_approx);
    end
    $display("\n");
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
    $display("COMPACT VIEW - ALL TESTS");
    $display("=================================================");
    
    run_test_compact("DC Signal (Input 0.5)", 0, 0);
    run_test_compact("Impulse (Input 1.0)", 1, 0);
    run_test_compact("Cosine Wave (k=5)", 2, 5);
    
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