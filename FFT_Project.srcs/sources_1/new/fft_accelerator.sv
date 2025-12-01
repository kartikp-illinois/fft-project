`timescale 1ns / 1ps
/*
 * ============================================================================
 * Module: fft_accelerator
 * ============================================================================
 * Description:
 *   A high-level wrapper for the 256-point Fixed-Point FFT Core.
 *   This module abstracts away the complexity of bit-reversal addressing, 
 *   memory management, and complex magnitude calculation, providing a simple
 *   AXI-Stream-like interface for time-domain input and frequency-domain output.
 *
 * Key Features:
 *   - Input:  Accepts 256 real-valued 16-bit time-domain samples.
 *             (Imaginary component is hardcoded to 0 internally).
 *   - Output: Produces 256 16-bit frequency-domain magnitude values.
 *   - Math:   Uses Alpha Max + Beta Min algorithm (Alpha=1, Beta=0.375)
 *             to approximate vector magnitude (|z| ? Max + 3/8*Min).
 *   - Auto:   Automatically handles bit-reversal on input so outputs come
 *             out in natural linear order (Bin 0 to 255).
 *
 * Interface Usage:
 *   1. Wait for `ready_for_input` to be HIGH.
 *   2. Stream in exactly 256 samples:
 *      - Assert `input_valid` = 1.
 *      - Provide `time_domain_sample` on the same clock edge.
 *      - You can burst all 256 or pause (deassert valid) at any time; 
 *        the internal counter tracks progress.
 *   3. Once the 256th sample is received, the module goes BUSY (`busy`=1).
 *      - It automatically starts the FFT core.
 *      - `ready_for_input` goes LOW.
 *   4. Wait for `output_valid` to go HIGH.
 *      - The module will stream out 256 magnitude results over 256 clocks.
 *      - `freq_domain_magnitude` contains the approx magnitude.
 *      - `output_bin_index` tells you which bin (0-255) is valid.
 *   5. After the 256th output, `busy` goes LOW and `ready_for_input` goes HIGH.
 *      - The module is now ready for the next frame of audio/data.
 *
 * Internal Pipeline:
 *   [Input] -> [Bit-Reverse Addr] -> [RAM A/B] -> [FFT Core] -> [Linear Read] -> [Mag Approx] -> [Output]
 * ============================================================================
 */

module fft_accelerator #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 256
)(
    input  logic clk,
    input  logic rst,

    // --- Input Interface (Time Domain) ---
    // Pulse this high while sending 256 samples
    input  logic input_valid,           
    // The 16-bit real sample (Imaginary is assumed 0 internally)
    input  logic signed [WIDTH-1:0] time_domain_sample, 
    // High when the core is ready to accept new batch of data
    output logic ready_for_input,       

    // --- Output Interface (Frequency Domain) ---
    // High when freq_domain_magnitude is valid
    output logic output_valid,          
    // The calculated magnitude (approx) of the bin
    output logic [WIDTH-1:0] freq_domain_magnitude, 
    // Optional: tells you which bin (0-255) is currently on output
    output logic [$clog2(FFT_SIZE)-1:0] output_bin_index, 
    // High during calculation phase
    output logic busy                   
);

    // Internal States
    typedef enum logic [1:0] {IDLE, LOAD, CALC, UNLOAD} state_t;
    state_t state;

    // Counters
    logic [$clog2(FFT_SIZE)-1:0] counter;

    // Signals to FFT Core
    logic core_start;
    logic core_load_en;
    logic [$clog2(FFT_SIZE)-1:0] core_load_addr;
    logic signed [WIDTH-1:0] core_load_re;
    logic signed [WIDTH-1:0] core_load_im;
    logic core_done;
    logic core_busy;
    logic [$clog2(FFT_SIZE)-1:0] core_read_addr;
    logic signed [WIDTH-1:0] core_read_re, core_read_im;

    // Bit Reversal Function (same as before)
    function [$clog2(FFT_SIZE)-1:0] bit_reverse(input [$clog2(FFT_SIZE)-1:0] in);
        // Hardcoded for 256 size (8 bits)
        bit_reverse = {in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]};
    endfunction

    // -------------------------------------------------------
    // Instantiate the Existing Core
    // -------------------------------------------------------
    fft_top #(
        .WIDTH(WIDTH),
        .FFT_SIZE(FFT_SIZE)
    ) core_inst (
        .clk(clk), .rst(rst),
        .start(core_start),
        .load_enable(core_load_en),
        .load_addr(core_load_addr),
        .load_data_re(core_load_re),
        .load_data_im(core_load_im),
        .done(core_done),
        .busy(core_busy),
        .read_addr(core_read_addr),
        .read_data_re(core_read_re),
        .read_data_im(core_read_im)
    );

    // -------------------------------------------------------
    // State Machine
    // -------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            counter <= 0;
            core_start <= 0;
        end else begin
            case (state)
                IDLE: begin
                    core_start <= 0;
                    counter <= 0;
                    if (input_valid && ready_for_input) begin
                        state <= LOAD;
                        counter <= counter + 1; // We consumed 1st sample
                    end
                end

                LOAD: begin
                    if (input_valid) begin
                        counter <= counter + 1;
                        if (counter == FFT_SIZE - 1) begin
                            state <= CALC;
                            core_start <= 1; // Auto-start FFT
                        end
                    end
                end

                CALC: begin
                    core_start <= 0;
                    // Wait for core to finish
                    if (core_done) begin
                        state <= UNLOAD;
                        counter <= 0; // Reset for read-out
                    end
                end

                UNLOAD: begin
                    // Stream out 256 results.
                    if (counter == FFT_SIZE - 1) begin
                         state <= IDLE;
                         counter <= 0;
                    end else begin
                         counter <= counter + 1;
                    end
                end
            endcase
        end
    end


    // -------------------------------------------------------
    // Logic Mapping
    // -------------------------------------------------------
    
    // 1. Input Logic
    assign ready_for_input = (state == IDLE || state == LOAD);
    
    // We perform Bit Reversal ON ENTRY. This simplifies the output side.
    // The core expects bit-reversed inputs to produce linear outputs (DIT FFT).
    assign core_load_en = (input_valid && (state == IDLE || state == LOAD));
    assign core_load_addr = bit_reverse(counter); 
    assign core_load_re = time_domain_sample;
    assign core_load_im = 16'd0; // Real input means Imaginary is 0

    // 2. Output Logic
    // We read data out linearly. Since we bit-reversed inputs, outputs come out in order 0..255
    assign core_read_addr = counter; 
    
    // Pipeline delay compensation for Read RAM (2 cycles latency standard for BRAM)
    logic valid_d1, valid_d2;
    logic [$clog2(FFT_SIZE)-1:0] bin_d1, bin_d2;

    always_ff @(posedge clk) begin
        // Delay the valid signal to match RAM read latency
        valid_d1 <= (state == UNLOAD);
        valid_d2 <= valid_d1;
        output_valid <= valid_d2;

        // Delay the bin index to match the data
        bin_d1 <= counter;
        bin_d2 <= bin_d1;
        output_bin_index <= bin_d2;
    end

    assign busy = (state != IDLE);

    // -------------------------------------------------------
    // Magnitude Approximation: Alpha Max + Beta Min
    // Alpha = 1.0, Beta = 0.375 (3/8)
    // -------------------------------------------------------
    
    // Absolute values
    logic signed [WIDTH-1:0] abs_re, abs_im;
    assign abs_re = (core_read_re < 0) ? -core_read_re : core_read_re;
    assign abs_im = (core_read_im < 0) ? -core_read_im : core_read_im;
    
    // Max / Min of |Re|, |Im|
    logic [WIDTH-1:0] max_val, min_val;
    assign max_val = (abs_re >= abs_im) ? abs_re : abs_im;
    assign min_val = (abs_re <  abs_im) ? abs_re : abs_im;
    
    // Beta * Min ? 3/8 * Min = Min/4 + Min/8
    logic [WIDTH-1:0] beta_min;
    assign beta_min = (min_val >> 2) + (min_val >> 3);  // (Min/4 + Min/8)
    
    // Magnitude ? Alpha*Max + Beta*Min = Max + Beta*Min
    logic [WIDTH:0] mag_tmp; // one extra bit to reduce overflow risk
    assign mag_tmp = max_val + beta_min;
    
    // Truncate back to WIDTH bits
    assign freq_domain_magnitude = mag_tmp[WIDTH-1:0];
    
endmodule
