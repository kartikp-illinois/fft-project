`timescale 1ns / 1ps

// Sequences an in-place radix-2 FFT using address/read, memory settling,
// arithmetic pipeline, and write cycles for each butterfly.
module fft_control #(
    parameter FFT_SIZE = 256,
    parameter ADDR_WIDTH = $clog2(FFT_SIZE),
    parameter STAGES = $clog2(FFT_SIZE)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    output logic [$clog2(STAGES)-1:0] stage,
    output logic [ADDR_WIDTH-1:0] butterfly_idx,
    output logic read_enable,
    output logic write_enable,
    output logic done,
    output logic busy
);

    localparam BUTTERFLIES_PER_STAGE = FFT_SIZE / 2;

    typedef enum logic [2:0] {
        IDLE,
        READ_BUTTERFLY,
        WAIT_MEMORY,
        PIPELINE_BUTTERFLY,
        WRITE_BUTTERFLY,
        FINISH
    } state_t;

    state_t state;
    logic [$clog2(STAGES)-1:0] current_stage;
    logic [ADDR_WIDTH-1:0] current_butterfly;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            current_stage <= '0;
            current_butterfly <= '0;
        end else begin
            case (state)
                IDLE: begin
                    current_stage <= '0;
                    current_butterfly <= '0;
                    if (start)
                        state <= READ_BUTTERFLY;
                end

                READ_BUTTERFLY:
                    state <= WAIT_MEMORY;

                WAIT_MEMORY:
                    state <= PIPELINE_BUTTERFLY;

                PIPELINE_BUTTERFLY:
                    state <= WRITE_BUTTERFLY;

                WRITE_BUTTERFLY: begin
                    if (current_butterfly == BUTTERFLIES_PER_STAGE - 1) begin
                        current_butterfly <= '0;
                        if (current_stage == STAGES - 1)
                            state <= FINISH;
                        else begin
                            current_stage <= current_stage + 1'b1;
                            state <= READ_BUTTERFLY;
                        end
                    end else begin
                        current_butterfly <= current_butterfly + 1'b1;
                        state <= READ_BUTTERFLY;
                    end
                end

                FINISH:
                    state <= IDLE;

                default:
                    state <= IDLE;
            endcase
        end
    end

    always_comb begin
        stage = current_stage;
        butterfly_idx = current_butterfly;
        read_enable = (state == READ_BUTTERFLY);
        write_enable = (state == WRITE_BUTTERFLY);
        done = (state == FINISH);
        busy = (state == READ_BUTTERFLY) ||
               (state == WAIT_MEMORY) ||
               (state == PIPELINE_BUTTERFLY) ||
               (state == WRITE_BUTTERFLY);
    end

endmodule
