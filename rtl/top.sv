`timescale 1ns / 1ps

module top (
    input logic CLK_100MHZ,
    input logic reset,
    
    // HDMI outputs
    output logic hdmi_tmds_clk_p,
    output logic hdmi_tmds_clk_n,
    output logic [2:0] hdmi_tmds_data_p,
    output logic [2:0] hdmi_tmds_data_n
);

    // Clock signals
    logic clk_25;
    logic clk_125;
    logic clk_100;
    logic clk_locked;
    logic rst_25;
    logic rst_100;
    logic [1:0] reset_pipe_25;
    logic [1:0] reset_pipe_100;
    
    // VGA signals
    logic [9:0] drawX, drawY;
    logic vga_hs, vga_vs;
    logic vde;
    logic hdmi_hs, hdmi_vs, hdmi_vde;
    logic [3:0] vga_r, vga_g, vga_b;
    
    // Display buffer interface
    logic [7:0] display_read_addr;
    logic [15:0] display_read_data;
    
    // Sample memory interface
    logic [7:0] sample_read_addr;
    logic signed [15:0] sample_read_data;
    
    // FFT Core signals
    logic fft_start;
    logic fft_load_enable;
    logic [7:0] fft_load_addr;
    logic signed [15:0] fft_load_data_re;
    logic signed [15:0] fft_load_data_im;
    logic fft_done;
    logic fft_busy;
    logic [7:0] fft_read_addr;
    logic signed [15:0] fft_read_data_re;
    logic signed [15:0] fft_read_data_im;
    
    // Display buffer write interface
    logic [7:0] display_write_addr;
    logic [15:0] display_write_data;
    logic display_write_en;
    
    //========================================================================
    // CLOCK WIZARD
    //========================================================================
    clk_wiz_0 clk_gen (
        .clk_in1(CLK_100MHZ),
        .reset(reset),
        .clk_25(clk_25),
        .clk_125(clk_125),
        .clk_100(clk_100),
        .locked(clk_locked)
    );

    // Sample loss of clock lock synchronously in each generated clock domain.
    // This keeps asynchronous controls away from downstream BRAM interfaces.
    always_ff @(posedge clk_25) begin
        if (!clk_locked)
            reset_pipe_25 <= 2'b11;
        else
            reset_pipe_25 <= {reset_pipe_25[0], 1'b0};
    end

    always_ff @(posedge clk_100) begin
        if (!clk_locked)
            reset_pipe_100 <= 2'b11;
        else
            reset_pipe_100 <= {reset_pipe_100[0], 1'b0};
    end

    assign rst_25 = reset_pipe_25[1];
    assign rst_100 = reset_pipe_100[1];
    
    //========================================================================
    // SAMPLE MEMORY - Loads from .mem file
    //========================================================================
    sample_memory sample_mem (
        .read_addr(sample_read_addr),
        .read_data(sample_read_data)
    );
    
    //========================================================================
    // FFT CONTROLLER - Manages loading, FFT execution, and readout
    //========================================================================
    fft_controller fft_ctrl (
        .clk(clk_100),
        .rst(rst_100),
        
        // Sample memory interface
        .sample_read_addr(sample_read_addr),
        .sample_read_data(sample_read_data),
        
        // FFT core interface
        .fft_start(fft_start),
        .fft_load_enable(fft_load_enable),
        .fft_load_addr(fft_load_addr),
        .fft_load_data_re(fft_load_data_re),
        .fft_load_data_im(fft_load_data_im),
        .fft_done(fft_done),
        .fft_busy(fft_busy),
        .fft_read_addr(fft_read_addr),
        .fft_read_data_re(fft_read_data_re),
        .fft_read_data_im(fft_read_data_im),
        
        // Display buffer interface
        .display_write_addr(display_write_addr),
        .display_write_data(display_write_data),
        .display_write_en(display_write_en)
    );
    
    //========================================================================
    // FFT CORE
    //========================================================================
    fft_top #(
        .WIDTH(16),
        .FFT_SIZE(256)
    ) fft_core (
        .clk(clk_100),
        .rst(rst_100),
        
        .start(fft_start),
        .load_enable(fft_load_enable),
        .load_addr(fft_load_addr),
        .load_data_re(fft_load_data_re),
        .load_data_im(fft_load_data_im),
        
        .done(fft_done),
        .busy(fft_busy),
        
        .read_addr(fft_read_addr),
        .read_data_re(fft_read_data_re),
        .read_data_im(fft_read_data_im)
    );
    
    //========================================================================
    // DISPLAY BUFFER - Dual-port RAM for VGA readout
    //========================================================================
    display_buffer disp_buf (
        .clk(clk_25),
        .read_addr(display_read_addr),
        .read_data(display_read_data),
        
        .write_clk(clk_100),
        .write_en(display_write_en),
        .write_addr(display_write_addr),
        .write_data(display_write_data)
    );
    
    //========================================================================
    // VGA CONTROLLER
    //========================================================================
    vga_controller vga_ctrl (
        .pixel_clk(clk_25),
        .reset(rst_25),
        .hs(vga_hs),
        .vs(vga_vs),
        .active_nblank(vde),
        .sync(),
        .drawX(drawX),
        .drawY(drawY)
    );
    
    //========================================================================
    // BAR GRAPH COLOR MAPPER
    //========================================================================
    bar_graph_color_mapper graph_mapper (
        .clk(clk_25),
        .reset(rst_25),
        .drawX(drawX),
        .drawY(drawY),
        .hsync_in(vga_hs),
        .vsync_in(vga_vs),
        .vde_in(vde),
        
        .bar_read_addr(display_read_addr),
        .bar_read_value(display_read_data),
        
        .hsync_out(hdmi_hs),
        .vsync_out(hdmi_vs),
        .vde_out(hdmi_vde),
        .red(vga_r),
        .green(vga_g),
        .blue(vga_b)
    );
    
    //========================================================================
    // HDMI TX IP
    //========================================================================
    hdmi_tx_0 hdmi_tx (
        .pix_clk(clk_25),
        .pix_clkx5(clk_125),
        // rst_25 already remains asserted until the clock generator locks.
        // Keep the IP's redundant lock input high to avoid OR-gating an
        // asynchronous reset inside the transmitter.
        .pix_clk_locked(1'b1),
        .rst(rst_25),
        
        .red(vga_r),
        .green(vga_g),
        .blue(vga_b),
        .hsync(hdmi_hs),
        .vsync(hdmi_vs),
        .vde(hdmi_vde),
        
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        .TMDS_CLK_P(hdmi_tmds_clk_p),
        .TMDS_CLK_N(hdmi_tmds_clk_n),
        .TMDS_DATA_P(hdmi_tmds_data_p),
        .TMDS_DATA_N(hdmi_tmds_data_n)
    );

endmodule


//============================================================================
// SAMPLE MEMORY - ROM initialized from .mem file
//============================================================================
module sample_memory (
    input logic [7:0] read_addr,
    output logic signed [15:0] read_data
);

    (* rom_style = "block" *) logic signed [15:0] samples [0:255];
    
    // Bit-reversal function for 256-point FFT (8 bits)
    function [7:0] bit_reverse(input [7:0] in);
        bit_reverse = {in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]};
    endfunction
    
    // Initialize from .mem file
    initial begin
        $readmemh("samples.mem", samples); 
    end
    
    // The input is bit-reversed for radix-2 decimation-in-time processing.
    // An asynchronous read keeps the ROM address aligned with the registered
    // FFT load interface.
    always_comb read_data = samples[bit_reverse(read_addr)];

endmodule


//============================================================================
// FFT CONTROLLER - Master FSM for FFT operations
//============================================================================
module fft_controller (
    input logic clk,
    input logic rst,
    
    // Sample memory interface
    output logic [7:0] sample_read_addr,
    input logic signed [15:0] sample_read_data,
    
    // FFT core interface
    output logic fft_start,
    output logic fft_load_enable,
    output logic [7:0] fft_load_addr,
    output logic signed [15:0] fft_load_data_re,
    output logic signed [15:0] fft_load_data_im,
    input logic fft_done,
    input logic fft_busy,
    output logic [7:0] fft_read_addr,
    input logic signed [15:0] fft_read_data_re,
    input logic signed [15:0] fft_read_data_im,
    
    // Display buffer interface
    output logic [7:0] display_write_addr,
    output logic [15:0] display_write_data,
    output logic display_write_en
);

    typedef enum logic [2:0] {
        IDLE,
        LOAD_SAMPLES,
        LOAD_DELAY,
        START_FFT,
        WAIT_FFT,
        READ_RESULTS,
        READ_DELAY,
        PAUSE
    } state_t;
    state_t state;
    
    logic [7:0] load_count;
    logic [8:0] read_count;
    logic [15:0] pause_count;
    
    // Two-stage magnitude pipeline: signed absolute values, then alpha-max
    // plus beta-min approximation.
    logic [15:0] abs_re_q, abs_im_q;
    logic [15:0] max_val, min_val;
    logic [15:0] beta_min;
    logic [15:0] magnitude_q;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            load_count <= 0;
            read_count <= 0;
            pause_count <= 0;
            fft_start <= 0;
            fft_load_enable <= 0;
            display_write_en <= 0;
            sample_read_addr <= 0;
            fft_load_addr <= 0;
            fft_load_data_re <= 0;
            fft_load_data_im <= 0;
            fft_read_addr <= 0;
            display_write_addr <= 0;
            display_write_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    load_count <= 0;
                    fft_start <= 0;
                    fft_load_enable <= 0;
                    sample_read_addr <= 0;
                    state <= LOAD_SAMPLES;
                end
                
                LOAD_SAMPLES: begin
                    // Load samples into FFT core
                    fft_load_enable <= 1;
                    fft_load_addr <= load_count;
                    sample_read_addr <= load_count + 1;  // Pre-fetch next
                    fft_load_data_re <= sample_read_data;
                    fft_load_data_im <= 16'd0;  // Real input only
                    
                    if (load_count == 255) begin
                        state <= LOAD_DELAY;
                    end else begin
                        load_count <= load_count + 1;
                    end
                end
                
                LOAD_DELAY: begin
                    // One cycle delay before starting FFT
                    fft_load_enable <= 0;
                    state <= START_FFT;
                end
                
                START_FFT: begin
                    if (!fft_busy) begin
                        fft_start <= 1;
                        state <= WAIT_FFT;
                    end
                end
                
                WAIT_FFT: begin
                    fft_start <= 0;
                    if (fft_done) begin
                        read_count <= 0;
                        fft_read_addr <= 0;
                        state <= READ_RESULTS;
                    end
                end
                
                READ_RESULTS: begin
                    // Read FFT results and calculate magnitude
                    fft_read_addr <= read_count;
                    
                    if (read_count >= 4) begin
                        // Registered address, BRAM read, absolute value, and
                        // magnitude stages make results from four cycles ago
                        // valid here.
                        display_write_addr <= read_count - 4;
                        display_write_data <= magnitude_q;
                        display_write_en <= 1;
                    end else begin
                        display_write_en <= 0;
                    end
                    
                    if (read_count == 255) begin
                        read_count <= read_count + 1;
                        state <= READ_DELAY;
                    end else begin
                        read_count <= read_count + 1;
                    end
                end
                
                READ_DELAY: begin
                    // Flush the final four values from the result pipeline.
                    if (read_count == 256) begin
                        display_write_addr <= 252;
                        display_write_data <= magnitude_q;
                        display_write_en <= 1;
                        read_count <= 257;
                    end else if (read_count == 257) begin
                        display_write_addr <= 253;
                        display_write_data <= magnitude_q;
                        display_write_en <= 1;
                        read_count <= 258;
                    end else if (read_count == 258) begin
                        display_write_addr <= 254;
                        display_write_data <= magnitude_q;
                        display_write_en <= 1;
                        read_count <= 259;
                    end else if (read_count == 259) begin
                        display_write_addr <= 255;
                        display_write_data <= magnitude_q;
                        display_write_en <= 1;
                        read_count <= 0;
                        pause_count <= 0;
                        state <= PAUSE;
                    end
                end
                
                PAUSE: begin
                    display_write_en <= 0;
                    // Small delay before restarting
                    if (pause_count == 16'd5000) begin
                        state <= IDLE;
                    end else begin
                        pause_count <= pause_count + 1;
                    end
                end

                default: begin
                    state <= IDLE;
                    fft_start <= 1'b0;
                    fft_load_enable <= 1'b0;
                    display_write_en <= 1'b0;
                end
            endcase
        end
    end
    
    //========================================================================
    // MAGNITUDE CALCULATION - Alpha Max + Beta Min
    // Alpha = 1.0, Beta = 0.375 (3/8)
    //========================================================================
    
    always_ff @(posedge clk) begin
        if (rst) begin
            abs_re_q <= 16'd0;
            abs_im_q <= 16'd0;
            magnitude_q <= 16'd0;
        end else begin
            abs_re_q <= fft_read_data_re[15]
                ? (~$unsigned(fft_read_data_re) + 16'd1)
                : $unsigned(fft_read_data_re);
            abs_im_q <= fft_read_data_im[15]
                ? (~$unsigned(fft_read_data_im) + 16'd1)
                : $unsigned(fft_read_data_im);
            magnitude_q <= max_val + beta_min;
        end
    end

    always_comb begin
        if (abs_re_q >= abs_im_q) begin
            max_val = abs_re_q;
            min_val = abs_im_q;
        end else begin
            max_val = abs_im_q;
            min_val = abs_re_q;
        end
        
        // Beta * min is 3/8 * min = min/4 + min/8.
        beta_min = (min_val >> 2) + (min_val >> 3);
        
    end

endmodule


//============================================================================
// DISPLAY BUFFER - Dual-port RAM
//============================================================================
module display_buffer (
    input logic clk,
    input logic [7:0] read_addr,
    output logic [15:0] read_data,
    
    input logic write_clk,
    input logic write_en,
    input logic [7:0] write_addr,
    input logic [15:0] write_data
);

    (* ram_style = "block" *) logic [15:0] memory [0:255];

    initial begin
        for (int i = 0; i < 256; i++)
            memory[i] = 16'd0;
    end
    
    always_ff @(posedge write_clk) begin
        if (write_en) begin
            memory[write_addr] <= write_data;
        end
    end
    
    always_ff @(posedge clk) begin
        read_data <= memory[read_addr];
    end

endmodule
