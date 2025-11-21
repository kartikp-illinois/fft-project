`timescale 1ns / 1ps

module fft_top #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 8,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    
    // Load interface
    input  logic load_enable,
    input  logic [ADDR_WIDTH-1:0] load_addr,
    input  logic signed [WIDTH-1:0] load_data_re, load_data_im,
    
    // Output interface
    output logic done,
    output logic busy,
    
    // Read interface
    input  logic [ADDR_WIDTH-1:0] read_addr,
    output logic signed [WIDTH-1:0] read_data_re, read_data_im
);

// Internal signals
logic [1:0] stage;
logic [ADDR_WIDTH:0] butterfly_idx;
logic compute_enable;
logic we_mem;

// Address generation outputs
logic [ADDR_WIDTH-1:0] addr_x0, addr_x1, tw_addr;
logic [ADDR_WIDTH-1:0] wr_addr_y0, wr_addr_y1;
logic addr_valid;

// Butterfly I/O
logic signed [WIDTH-1:0] x0_re, x0_im, x1_re, x1_im;
logic signed [WIDTH-1:0] y0_re, y0_im, y1_re, y1_im;
logic signed [WIDTH-1:0] tw_re, tw_im;
logic bf_valid_in, bf_valid_out;

// Memory control
logic [ADDR_WIDTH-1:0] mem_addr_a, mem_addr_b;
logic mem_we_a;
logic signed [WIDTH-1:0] mem_din_a_re, mem_din_a_im;
logic signed [WIDTH-1:0] mem_dout_a_re, mem_dout_a_im;
logic signed [WIDTH-1:0] mem_dout_b_re, mem_dout_b_im;

// Pipeline registers for write-back (match 6-cycle butterfly latency)
logic [ADDR_WIDTH-1:0] wr_addr_y0_d [0:5];
logic [ADDR_WIDTH-1:0] wr_addr_y1_d [0:5];
logic we_pipe [0:5];

// Write-back control: alternate between writing y0 and y1
logic wb_select;  // 0 = write y0, 1 = write y1
logic signed [WIDTH-1:0] wb_data_re, wb_data_im;
logic [ADDR_WIDTH-1:0] wb_addr;
logic wb_enable;  // Combinational enable signal

// Storage for y1 output (hold while y0 is written)
logic signed [WIDTH-1:0] y1_re_hold, y1_im_hold;
logic [ADDR_WIDTH-1:0] wr_addr_y1_hold;

// Pipeline the write addresses and enable to match butterfly latency
always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 6; i++) begin
            wr_addr_y0_d[i] <= 0;
            wr_addr_y1_d[i] <= 0;
            we_pipe[i] <= 0;
        end
    end else begin
        // Stage 0
        wr_addr_y0_d[0] <= wr_addr_y0;
        wr_addr_y1_d[0] <= wr_addr_y1;
        we_pipe[0] <= we_mem && compute_enable;
        
        // Shift pipeline
        for (int i = 1; i < 6; i++) begin
            wr_addr_y0_d[i] <= wr_addr_y0_d[i-1];
            wr_addr_y1_d[i] <= wr_addr_y1_d[i-1];
            we_pipe[i] <= we_pipe[i-1];
        end
    end
end

// Write-back control: alternate between writing y0 and y1
logic wb_select_next;

// Combinational write enable - asserts immediately when butterfly outputs
assign wb_enable = (bf_valid_out && we_pipe[6] && wb_select == 0) ||  // Write y0
                   (wb_select == 1);                                     // Write y1 next cycle

// Sequential state for alternating between y0/y1 writes
always_ff @(posedge clk) begin
    if (rst) begin
        wb_select <= 0;
        y1_re_hold <= 0;
        y1_im_hold <= 0;
        wr_addr_y1_hold <= 0;
    end else begin
        if (bf_valid_out && we_pipe[6] && wb_select == 0) begin
            // Butterfly output - store y1 for next cycle, toggle select
            wb_select <= 1;
            y1_re_hold <= y1_re;
            y1_im_hold <= y1_im;
            wr_addr_y1_hold <= wr_addr_y1_d[6];
        end else if (wb_select == 1) begin
            // Just wrote y1, return to idle
            wb_select <= 0;
        end
    end
end

// Write-back data multiplexing
always_comb begin
    if (wb_select == 0) begin
        wb_data_re = y0_re;
        wb_data_im = y0_im;
        wb_addr = wr_addr_y0_d[6];
    end else begin
        wb_data_re = y1_re_hold;
        wb_data_im = y1_im_hold;
        wb_addr = wr_addr_y1_hold;
    end
end

// Memory interface multiplexing
always_comb begin
    if (load_enable) begin
        // Load mode - write on port A, allow reads on port B
        mem_addr_a = load_addr;
        mem_we_a = 1;
        mem_din_a_re = load_data_re;
        mem_din_a_im = load_data_im;
        mem_addr_b = read_addr;
    end else if (wb_enable) begin
        // Write-back mode - write on port A
        mem_addr_a = wb_addr;
        mem_we_a = 1;
        mem_din_a_re = wb_data_re;
        mem_din_a_im = wb_data_im;
        // Read for next butterfly on port B
        mem_addr_b = addr_x1;
    end else if (busy) begin
        // FFT computation mode - read for butterfly
        mem_addr_a = addr_x0;
        mem_we_a = 0;
        mem_din_a_re = 0;
        mem_din_a_im = 0;
        mem_addr_b = addr_x1;
    end else begin
        // Idle/read mode - use read_addr for verification
        mem_addr_a = read_addr;
        mem_we_a = 0;
        mem_din_a_re = 0;
        mem_din_a_im = 0;
        mem_addr_b = 0;
    end
    
    // Connect memory outputs to butterfly inputs
    x0_re = mem_dout_a_re;
    x0_im = mem_dout_a_im;
    x1_re = mem_dout_b_re;
    x1_im = mem_dout_b_im;
    
    // Read output (when not computing)
    read_data_re = mem_dout_a_re;
    read_data_im = mem_dout_a_im;
end

// Butterfly valid control - delay by 2 cycles for BRAM + Twiddle ROM read latency
logic bf_valid_in_d, bf_valid_in_d2;

always_ff @(posedge clk) begin
    if (rst) begin
        bf_valid_in_d <= 0;
        bf_valid_in_d2 <= 0;
    end else begin
        bf_valid_in_d <= compute_enable;
        bf_valid_in_d2 <= bf_valid_in_d;
    end
end

assign bf_valid_in = bf_valid_in_d2;

// Control Unit
fft_control #(
    .FFT_SIZE(FFT_SIZE)
) ctrl (
    .clk(clk),
    .rst(rst),
    .start(start && !busy),
    .stage(stage),
    .butterfly_idx(butterfly_idx),
    .compute_enable(compute_enable),
    .we_mem(we_mem),
    .done(done),
    .busy(busy)
);

// Address Generator
fft_address_gen #(
    .FFT_SIZE(FFT_SIZE)
) addr_gen (
    .clk(clk),
    .rst(rst),
    .start(compute_enable),
    .stage(stage),
    .butterfly_idx(butterfly_idx),
    .addr_x0(addr_x0),
    .addr_x1(addr_x1),
    .tw_addr(tw_addr),
    .wr_addr_y0(wr_addr_y0),
    .wr_addr_y1(wr_addr_y1),
    .valid(addr_valid)
);

// Twiddle ROM
twiddle_rom #(
    .WIDTH(WIDTH),
    .FFT_SIZE(FFT_SIZE)
) tw_rom (
    .clk(clk),
    .addr(tw_addr),
    .tw_re(tw_re),
    .tw_im(tw_im)
);

// Data Memory (BRAM)
fft_bram #(
    .WIDTH(WIDTH),
    .DEPTH(FFT_SIZE)
) data_mem (
    .clk(clk),
    .addr_a(mem_addr_a),
    .we_a(mem_we_a),
    .din_a_re(mem_din_a_re),
    .din_a_im(mem_din_a_im),
    .dout_a_re(mem_dout_a_re),
    .dout_a_im(mem_dout_a_im),
    .addr_b(mem_addr_b),
    .dout_b_re(mem_dout_b_re),
    .dout_b_im(mem_dout_b_im)
);

// Butterfly Unit
butterfly #(
    .WIDTH(WIDTH)
) bfu (
    .clk(clk),
    .rst(rst),
    .valid_in(bf_valid_in),
    .x0_re(x0_re), .x0_im(x0_im),
    .x1_re(x1_re), .x1_im(x1_im),
    .tw_re(tw_re), .tw_im(tw_im),
    .y0_re(y0_re), .y0_im(y0_im),
    .y1_re(y1_re), .y1_im(y1_im),
    .valid_out(bf_valid_out)
);

endmodule