`timescale 1ns / 1ps

// Generates in-place data and twiddle addresses for one radix-2 stage.
module fft_address_gen #(
    parameter FFT_SIZE = 256,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [2:0] stage,
    input  logic [ADDR_WIDTH:0] butterfly_idx,
    
    output logic [ADDR_WIDTH-1:0] addr_x0,
    output logic [ADDR_WIDTH-1:0] addr_x1,
    output logic [ADDR_WIDTH-1:0] tw_addr,
    output logic [ADDR_WIDTH-1:0] wr_addr_y0,
    output logic [ADDR_WIDTH-1:0] wr_addr_y1,
    output logic valid
);

logic [ADDR_WIDTH-1:0] butterfly_span;
logic [ADDR_WIDTH-1:0] group_size;
logic [ADDR_WIDTH-1:0] group_idx;
logic [ADDR_WIDTH-1:0] bf_in_group;
logic [ADDR_WIDTH-1:0] tw_mult;

always_comb begin
    // Calculate addressing parameters based on stage
    butterfly_span = (1 << stage);
    group_size = (1 << (stage + 1));
    
    // Calculate group index and position within group
    group_idx = butterfly_idx / butterfly_span;
    bf_in_group = butterfly_idx % butterfly_span;
    
    // Read addresses
    addr_x0 = (group_idx * group_size) + bf_in_group;
    addr_x1 = addr_x0 + butterfly_span;
    
    // Write addresses (in-place)
    wr_addr_y0 = addr_x0;
    wr_addr_y1 = addr_x1;
    
    // Twiddle factor addressing
    tw_mult = bf_in_group * (FFT_SIZE >> (stage + 1));
    tw_addr = tw_mult;
end

// Simple valid signal - just pass through after small delay
logic valid_d, valid_d2;
always_ff @(posedge clk) begin
    if (rst) begin
        valid_d <= 0;
        valid_d2 <= 0;
        valid <= 0;
    end else begin
        valid_d <= start;
        valid_d2 <= valid_d;
        valid <= valid_d2;
    end
end

endmodule
