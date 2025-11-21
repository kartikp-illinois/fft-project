module fft_address_gen #(
    parameter FFT_SIZE = 8,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [1:0] stage,  // FFT stage number (0, 1, 2 for 8-point)
    input  logic [ADDR_WIDTH:0] butterfly_idx,  // Which butterfly in current stage
    
    output logic [ADDR_WIDTH-1:0] addr_x0,
    output logic [ADDR_WIDTH-1:0] addr_x1,
    output logic [ADDR_WIDTH-1:0] tw_addr,
    output logic [ADDR_WIDTH-1:0] wr_addr_y0,
    output logic [ADDR_WIDTH-1:0] wr_addr_y1,
    output logic valid
);

// FFT addressing pattern (Decimation-In-Time Cooley-Tukey algorithm)
// Stage 0: butterfly_span = 1, group_size = 2
// Stage 1: butterfly_span = 2, group_size = 4
// Stage 2: butterfly_span = 4, group_size = 8

logic [ADDR_WIDTH-1:0] butterfly_span;
logic [ADDR_WIDTH-1:0] group_size;
logic [ADDR_WIDTH-1:0] group_idx;
logic [ADDR_WIDTH-1:0] bf_in_group;
logic [ADDR_WIDTH-1:0] tw_mult;

always_comb begin
    // Calculate butterfly span and group size based on stage
    butterfly_span = (ADDR_WIDTH)'(1 << stage);
    group_size = (ADDR_WIDTH)'(1 << (stage + 1));
    
    // Determine position within groups
    group_idx = butterfly_idx / butterfly_span;
    bf_in_group = butterfly_idx % butterfly_span;
    
    // Calculate addresses
    addr_x0 = (group_idx * group_size) + bf_in_group;
    addr_x1 = addr_x0 + butterfly_span;
    
    // Write addresses (same as read for in-place computation)
    wr_addr_y0 = addr_x0;
    wr_addr_y1 = addr_x1;
    
    // Twiddle factor address
    tw_mult = bf_in_group << (2 - stage);  // Adjusted for 8-point FFT
    tw_addr = tw_mult % FFT_SIZE;
end

// Pipeline the valid signal to match processing latency
logic valid_pipe [0:6];  // 7-stage pipeline to match butterfly + BRAM latency

always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 7; i++) begin
            valid_pipe[i] <= 0;
        end
        valid <= 0;
    end else begin
        valid_pipe[0] <= start;
        for (int i = 1; i < 7; i++) begin
            valid_pipe[i] <= valid_pipe[i-1];
        end
        valid <= valid_pipe[6];
    end
end

endmodule
