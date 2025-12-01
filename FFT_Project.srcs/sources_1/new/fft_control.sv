module fft_control #(
    parameter FFT_SIZE = 256
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    output logic [2:0] stage,
    output logic [$clog2(FFT_SIZE):0] butterfly_idx,
    output logic compute_enable,
    output logic we_mem,
    output logic done,
    output logic busy
);

typedef enum logic [2:0] {
    IDLE,
    INIT_STAGE,
    COMPUTE,
    DRAIN_PIPELINE,
    NEXT_STAGE,
    FINISH
} state_t;

state_t state, next_state;

logic [2:0] current_stage;
logic [$clog2(FFT_SIZE):0] bf_count;
logic [$clog2(FFT_SIZE):0] butterflies_per_stage;
logic [3:0] drain_count;
localparam PIPELINE_DEPTH = 9;

logic compute_toggle;
always_ff @(posedge clk) begin
    if (rst || state != COMPUTE) compute_toggle <= 0;
    else compute_toggle <= ~compute_toggle;
end

// butterflies per stage = N/2
always_comb begin
    butterflies_per_stage = FFT_SIZE >> 1;
end

// --------- STATE REGISTER ONLY (no next_state here) ----------
always_ff @(posedge clk) begin
    if (rst) begin
        state         <= IDLE;
        current_stage <= 0;
        bf_count      <= 0;
        butterfly_idx <= 0;
        drain_count   <= 0;
        stage         <= 0;
    end else begin
        state <= next_state;

        case (state)
            IDLE: begin
                current_stage <= 0;
                bf_count      <= 0;
                butterfly_idx <= 0;
                drain_count   <= 0;
            end

            INIT_STAGE: begin
                bf_count      <= 0;
                butterfly_idx <= 0;
                drain_count   <= 0;
                stage         <= current_stage;
            end

            COMPUTE: begin
                // Only increment on toggle=0
                if (bf_count < butterflies_per_stage && compute_toggle == 0) begin
                    butterfly_idx <= bf_count;
                    bf_count      <= bf_count + 1;
                end
            end

            DRAIN_PIPELINE: begin
                drain_count <= drain_count + 1;
            end

            NEXT_STAGE: begin
                current_stage <= current_stage + 1;
                drain_count   <= 0;
            end

            FINISH: begin
                // hold final values
            end
        endcase
    end
end

// --------- NEXT-STATE / OUTPUT COMBINATIONAL LOGIC ----------
always_comb begin
    next_state     = state;
    compute_enable = 0;
    we_mem         = 0;
    done           = 0;
    busy           = 1;

    case (state)
        IDLE: begin
            busy = 0;
            if (start)
                next_state = INIT_STAGE;
        end

        INIT_STAGE: begin
            next_state = COMPUTE;
        end

        COMPUTE: begin
            compute_enable = (bf_count < butterflies_per_stage) && (compute_toggle == 0);
            we_mem         = 1;
            if (bf_count >= butterflies_per_stage)
                next_state = DRAIN_PIPELINE;
        end


        DRAIN_PIPELINE: begin
            we_mem = 1;
            if (drain_count >= PIPELINE_DEPTH) begin
                if (current_stage >= 3'd7)   // stages 0..7
                    next_state = FINISH;
                else
                    next_state = NEXT_STAGE;
            end
        end

        NEXT_STAGE: begin
            next_state = INIT_STAGE;
        end

        FINISH: begin
            done = 1;
            busy = 0;
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule
