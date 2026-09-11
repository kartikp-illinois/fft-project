`timescale 1ns / 1ps

module fft_top #(
    parameter WIDTH = 16,
    parameter FFT_SIZE = 256,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE),
    parameter STAGES = $clog2(FFT_SIZE)
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

    logic [$clog2(STAGES)-1:0] stage;
    logic [ADDR_WIDTH-1:0] butterfly_idx;
    logic write_enable;

    logic [ADDR_WIDTH-1:0] addr_x0;
    logic [ADDR_WIDTH-1:0] addr_x1;
    logic [ADDR_WIDTH-1:0] tw_addr;

    logic [ADDR_WIDTH-1:0] mem_addr_a, mem_addr_b;
    logic mem_we_a, mem_we_b;
    logic signed [WIDTH-1:0] mem_din_a_re, mem_din_a_im;
    logic signed [WIDTH-1:0] mem_din_b_re, mem_din_b_im;
    logic signed [WIDTH-1:0] mem_dout_a_re, mem_dout_a_im;
    logic signed [WIDTH-1:0] mem_dout_b_re, mem_dout_b_im;

    logic [31:0] tw_data;
    logic signed [WIDTH-1:0] tw_re, tw_im;
    logic signed [WIDTH-1:0] y0_re, y0_im, y1_re, y1_im;

    assign tw_re = $signed(tw_data[31:16]);
    assign tw_im = $signed(tw_data[15:0]);
    assign read_data_re = mem_dout_a_re;
    assign read_data_im = mem_dout_a_im;

    // The two memory ports perform both operand reads in READ_BUTTERFLY and
    // both in-place result writes in WRITE_BUTTERFLY.
    always_comb begin
        mem_addr_a = read_addr;
        mem_addr_b = '0;
        mem_we_a = 1'b0;
        mem_we_b = 1'b0;
        mem_din_a_re = '0;
        mem_din_a_im = '0;
        mem_din_b_re = '0;
        mem_din_b_im = '0;

        if (load_enable && !busy) begin
            mem_addr_a = load_addr;
            mem_we_a = 1'b1;
            mem_din_a_re = load_data_re;
            mem_din_a_im = load_data_im;
        end else if (busy) begin
            mem_addr_a = addr_x0;
            mem_addr_b = addr_x1;
            if (write_enable) begin
                mem_we_a = 1'b1;
                mem_we_b = 1'b1;
                mem_din_a_re = y0_re;
                mem_din_a_im = y0_im;
                mem_din_b_re = y1_re;
                mem_din_b_im = y1_im;
            end
        end
    end

    fft_control #(
        .FFT_SIZE(FFT_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH),
        .STAGES(STAGES)
    ) control (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stage(stage),
        .butterfly_idx(butterfly_idx),
        .read_enable(),
        .write_enable(write_enable),
        .done(done),
        .busy(busy)
    );

    fft_address_gen #(
        .FFT_SIZE(FFT_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) address_generator (
        .stage(stage),
        .butterfly_idx(butterfly_idx),
        .addr_x0(addr_x0),
        .addr_x1(addr_x1),
        .tw_addr(tw_addr)
    );

    fft_bram #(
        .WIDTH(WIDTH),
        .DEPTH(FFT_SIZE),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) data_memory (
        .clk(clk),
        .addr_a(mem_addr_a),
        .we_a(mem_we_a),
        .din_a_re(mem_din_a_re),
        .din_a_im(mem_din_a_im),
        .dout_a_re(mem_dout_a_re),
        .dout_a_im(mem_dout_a_im),
        .addr_b(mem_addr_b),
        .we_b(mem_we_b),
        .din_b_re(mem_din_b_re),
        .din_b_im(mem_din_b_im),
        .dout_b_re(mem_dout_b_re),
        .dout_b_im(mem_dout_b_im)
    );

    blk_mem_gen_0 twiddle_rom (
        .clka(clk),
        .ena(1'b1),
        .addra(tw_addr),
        .douta(tw_data)
    );

    butterfly #(
        .WIDTH(WIDTH)
    ) butterfly_unit (
        .x0_re(mem_dout_a_re),
        .x0_im(mem_dout_a_im),
        .x1_re(mem_dout_b_re),
        .x1_im(mem_dout_b_im),
        .tw_re(tw_re),
        .tw_im(tw_im),
        .y0_re(y0_re),
        .y0_im(y0_im),
        .y1_re(y1_re),
        .y1_im(y1_im)
    );

endmodule
