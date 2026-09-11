`timescale 1ns / 1ps

// Generates in-place data and twiddle addresses for one radix-2 DIT stage.
module fft_address_gen #(
    parameter FFT_SIZE = 256,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE)
)(
    input  logic [$clog2(ADDR_WIDTH)-1:0] stage,
    input  logic [ADDR_WIDTH-1:0] butterfly_idx,
    output logic [ADDR_WIDTH-1:0] addr_x0,
    output logic [ADDR_WIDTH-1:0] addr_x1,
    output logic [ADDR_WIDTH-1:0] tw_addr
);

    logic [ADDR_WIDTH:0] span;
    logic [ADDR_WIDTH:0] group;
    logic [ADDR_WIDTH:0] offset;
    logic [ADDR_WIDTH:0] addr_x0_wide;
    logic [ADDR_WIDTH:0] addr_x1_wide;
    logic [ADDR_WIDTH:0] tw_addr_wide;

    always_comb begin
        span = ({{ADDR_WIDTH{1'b0}}, 1'b1} << stage);
        group = butterfly_idx >> stage;
        offset = butterfly_idx & (span - 1'b1);
        addr_x0_wide = (group << (stage + 1'b1)) + offset;
        addr_x1_wide = addr_x0_wide + span;
        tw_addr_wide = offset << ((ADDR_WIDTH - 1) - stage);

        addr_x0 = addr_x0_wide[ADDR_WIDTH-1:0];
        addr_x1 = addr_x1_wide[ADDR_WIDTH-1:0];
        tw_addr = tw_addr_wide[ADDR_WIDTH-1:0];
    end

endmodule
