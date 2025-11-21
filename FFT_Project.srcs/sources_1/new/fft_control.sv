`timescale 1ns / 1ps

module fft_control #(
    parameter FFT_SIZE = 8,
    parameter NUM_STAGES = $clog2(FFT_SIZE),
    parameter PIPELINE_DEPTH = 8  // 2 (BRAM + Twiddle ROM) + 6 (butterfly stages)
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    
    output logic [1:0] stage,
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

logic [1:0] current_stage;
logic [$clog2(FFT_SIZE):0] bf_count;
logic [$clog2(FFT_SIZE):0] butterflies_per_stage;
logic [$clog2(FFT_SIZE):0] drain_count;

always_comb begin
    // Calculate number of butterflies per stage
    butterflies_per_stage = FFT_SIZE >> 1;  // Always N/2 butterflies per stage (4 for 8-point)
end

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        current_stage <= 0;
        bf_count <= 0;
        butterfly_idx <= 0;
        drain_count <= 0;
        stage <= 0;
    end else begin
        state <= next_state;
        
        case (state)
            IDLE: begin
                current_stage <= 0;
                bf_count <= 0;
                butterfly_idx <= 0;
                drain_count <= 0;
            end
            
            INIT_STAGE: begin
                bf_count <= 0;
                butterfly_idx <= 0;
                drain_count <= 0;
                stage <= current_stage;
            end
            
            COMPUTE: begin
                if (compute_enable) begin
                    butterfly_idx <= bf_count;  // Output current count
                    bf_count <= bf_count + 1;   // Then increment for next
                end
            end
            
            DRAIN_PIPELINE: begin
                // Count cycles to drain pipeline
                drain_count <= drain_count + 1;
            end
            
            NEXT_STAGE: begin
                current_stage <= current_stage + 1;
                drain_count <= 0;
            end
            
            FINISH: begin
                // Stay in finish for one cycle
            end
        endcase
    end
end

always_comb begin
    next_state = state;
    compute_enable = 0;
    we_mem = 0;
    done = 0;
    busy = 1;
    
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
            compute_enable = 1;
            we_mem = 1;  // Enable writes immediately (they'll be gated by pipeline)
            
            // After processing all butterflies in this stage, move to drain
            // Process butterflies 0 through (butterflies_per_stage-1)
            // Transition when bf_count reaches butterflies_per_stage (after last one increments)
            if (bf_count >= butterflies_per_stage)
                next_state = DRAIN_PIPELINE;
        end
        
        DRAIN_PIPELINE: begin
            we_mem = 1;  // Continue writing as results come out of pipeline
            
            // Wait for pipeline to fully drain (PIPELINE_DEPTH cycles after last input)
            if (drain_count >= PIPELINE_DEPTH) begin
                if (current_stage >= NUM_STAGES - 1)
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
            next_state = IDLE;
        end
    endcase
end

endmodule