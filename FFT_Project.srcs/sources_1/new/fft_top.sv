`timescale 1ns / 1ps

module fft_top #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 256,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic load_enable,
    input  logic [ADDR_WIDTH-1:0] load_addr,
    input  logic signed [WIDTH-1:0] load_data_re, load_data_im,
    output logic done,
    output logic busy,
    input  logic [ADDR_WIDTH-1:0] read_addr,
    output logic signed [WIDTH-1:0] read_data_re, read_data_im
);

// Internal signals
logic [2:0] stage;
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
logic mem_we_a, mem_we_b;
logic signed [WIDTH-1:0] mem_din_a_re, mem_din_a_im;
logic signed [WIDTH-1:0] mem_din_b_re, mem_din_b_im; // Added inputs for Port B
logic signed [WIDTH-1:0] mem_dout_a_re, mem_dout_a_im;
logic signed [WIDTH-1:0] mem_dout_b_re, mem_dout_b_im;

// ========================================================================
// FIXED: 6-STAGE PIPELINE WITH PROPER DECLARATIONS
// ========================================================================
localparam ADDR_PIPE_DEPTH = 9;  // 3 (read) + 6 (butterfly)

logic [ADDR_WIDTH-1:0] wr_addr_y0_d [0:ADDR_PIPE_DEPTH-1];
logic [ADDR_WIDTH-1:0] wr_addr_y1_d [0:ADDR_PIPE_DEPTH-1];
logic we_pipe [0:ADDR_PIPE_DEPTH-1];

// Write-back control

// Data Delay Pipeline (2 cycles)
logic signed [WIDTH-1:0] x0_re_d, x0_im_d, x0_re_d2, x0_im_d2;
logic signed [WIDTH-1:0] x1_re_d, x1_im_d, x1_re_d2, x1_im_d2;
// Twiddle Delay (1 cycle) - to align with 2-cycle data delay
logic signed [WIDTH-1:0] tw_re_d, tw_im_d;

always_ff @(posedge clk) begin
    // Stage 1: Capture from RAM
    x0_re_d <= mem_dout_a_re;
    x0_im_d <= mem_dout_a_im;
    x1_re_d <= mem_dout_b_re;
    x1_im_d <= mem_dout_b_im;
    
    // Stage 2: Extra delay to ensure Odd Latency (Total 3 cycles before BF)
    x0_re_d2 <= x0_re_d;
    x0_im_d2 <= x0_im_d;
    x1_re_d2 <= x1_re_d;
    x1_im_d2 <= x1_im_d;
    
    // Twiddle Alignment: RAM data is Latency 1+2=3. Twiddle ROM is Latency 2.
    // We need 1 register here to make Twiddle Latency 3.
    tw_re_d <= tw_re;
    tw_im_d <= tw_im;
end


logic [31:0] tw_data;

blk_mem_gen_0 tw_rom (
    .clka  (clk),
    .ena   (1'b1),
    .addra (tw_addr),
    .douta (tw_data)
);

assign tw_re = tw_data[31:16];
assign tw_im = tw_data[15:0];

// Pipeline the write addresses
always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < ADDR_PIPE_DEPTH; i++) begin
            wr_addr_y0_d[i] <= 0;
            wr_addr_y1_d[i] <= 0;
            we_pipe[i] <= 0;
        end
    end else begin
        wr_addr_y0_d[0] <= wr_addr_y0;
        wr_addr_y1_d[0] <= wr_addr_y1;
        we_pipe[0] <= we_mem && compute_enable;  // Changed back
        
        for (int i = 1; i < ADDR_PIPE_DEPTH; i++) begin
            wr_addr_y0_d[i] <= wr_addr_y0_d[i-1];
            wr_addr_y1_d[i] <= wr_addr_y1_d[i-1];
            we_pipe[i] <= we_pipe[i-1];
        end
    end
end


// Memory interface multiplexing
always_comb begin
    // Defaults (Read Phase / Idle)
    mem_we_a = 0;
    mem_we_b = 0;
    mem_addr_a = addr_x0;
    mem_addr_b = addr_x1;
    mem_din_a_re = 0; mem_din_a_im = 0;
    mem_din_b_re = 0; mem_din_b_im = 0;

    if (load_enable) begin
        // External Load
        mem_addr_a = load_addr;
        mem_we_a = 1;
        mem_din_a_re = load_data_re;
        mem_din_a_im = load_data_im;
        mem_addr_b = read_addr; // During load, Port B can be used for read/debug
    end else if (busy) begin
        // During FFT operation: Check if we have a result to write
        if (bf_valid_out && we_pipe[ADDR_PIPE_DEPTH-1]) begin
            // WRITE PHASE: Write y0 to Port A, y1 to Port B
            mem_we_a = 1;
            mem_addr_a = wr_addr_y0_d[ADDR_PIPE_DEPTH-1];
            mem_din_a_re = y0_re;
            mem_din_a_im = y0_im;
            
            mem_we_b = 1;
            mem_addr_b = wr_addr_y1_d[ADDR_PIPE_DEPTH-1];
            mem_din_b_re = y1_re;
            mem_din_b_im = y1_im;
        end 
        // Else: READ PHASE (defaults hold: addr_x0/x1)
    end else begin
        // Final Readout
        mem_addr_a = read_addr;
        mem_addr_b = 0;
    end
    
    // Data to pipeline delay registers
    // Note: If we are writing, mem_dout is undefined/old, 
    // but we only capture valid data when compute_toggle allows it (Read Phase).
    read_data_re = mem_dout_a_re;
    read_data_im = mem_dout_a_im;
end

// Delay valid signal by 3 cycles (data BRAM 1 + twiddle ROM 2)
logic bf_valid_in_d, bf_valid_in_d2, bf_valid_in_d3;

always_ff @(posedge clk) begin
    if (rst) begin
        bf_valid_in_d  <= 0;
        bf_valid_in_d2 <= 0;
        bf_valid_in_d3 <= 0;
    end else begin
        bf_valid_in_d  <= compute_enable;  // Changed
        bf_valid_in_d2 <= bf_valid_in_d;
        bf_valid_in_d3 <= bf_valid_in_d2;
    end
end

assign bf_valid_in = bf_valid_in_d3;


// Module Instantiations
fft_control #(.FFT_SIZE(FFT_SIZE)) ctrl (
    .clk(clk), .rst(rst), .start(start && !busy),
    .stage(stage), .butterfly_idx(butterfly_idx),
    .compute_enable(compute_enable), .we_mem(we_mem),
    .done(done), .busy(busy)
);

fft_address_gen #(.FFT_SIZE(FFT_SIZE)) addr_gen (
    .clk(clk), .rst(rst), 
    .start(compute_enable),
    .stage(stage), .butterfly_idx(butterfly_idx),
    .addr_x0(addr_x0), .addr_x1(addr_x1), .tw_addr(tw_addr),
    .wr_addr_y0(wr_addr_y0), .wr_addr_y1(wr_addr_y1), .valid(addr_valid)
);

//twiddle_rom #(.WIDTH(WIDTH), .FFT_SIZE(FFT_SIZE)) tw_rom (
//    .clk(clk), .addr(tw_addr), .tw_re(tw_re), .tw_im(tw_im)
//);

fft_bram #(.WIDTH(WIDTH), .DEPTH(FFT_SIZE)) data_mem (
    .clk(clk), 
    // Port A
    .addr_a(mem_addr_a), .we_a(mem_we_a), 
    .din_a_re(mem_din_a_re), .din_a_im(mem_din_a_im), 
    .dout_a_re(mem_dout_a_re), .dout_a_im(mem_dout_a_im),
    // Port B (Now R/W)
    .addr_b(mem_addr_b), .we_b(mem_we_b),  // NEW
    .din_b_re(mem_din_b_re), .din_b_im(mem_din_b_im), // NEW
    .dout_b_re(mem_dout_b_re), .dout_b_im(mem_dout_b_im)
);

butterfly #(.WIDTH(WIDTH)) bfu (
    .clk(clk), .rst(rst), .valid_in(bf_valid_in),
    // Use d2 signals (2 cycle delay from RAM)
    .x0_re(x0_re_d2), .x0_im(x0_im_d2), 
    .x1_re(x1_re_d2), .x1_im(x1_im_d2),
    // Use d signals (1 cycle delay from ROM)
    .tw_re(tw_re_d),  .tw_im(tw_im_d),
    // Outputs remain same
    .y0_re(y0_re), .y0_im(y0_im), .y1_re(y1_re), .y1_im(y1_im),
    .valid_out(bf_valid_out)
);

endmodule