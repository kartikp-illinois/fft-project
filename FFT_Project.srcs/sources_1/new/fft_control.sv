module fft_control #(
    parameter FFT_SIZE = 8
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
logic [2:0] drain_count;
localparam PIPELINE_DEPTH = 6;

// Calculate butterflies per stage
always_comb begin
    case (current_stage)
        0: butterflies_per_stage = 4;  // Stage 0: 4 butterflies
        1: butterflies_per_stage = 2;  // Stage 1: 2 butterflies  
        2: butterflies_per_stage = 1;  // Stage 2: 1 butterfly
        default: butterflies_per_stage = 0;
    endcase
end

// State register
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
                if (bf_count < butterflies_per_stage) begin
                    butterfly_idx <= bf_count;
                    bf_count <= bf_count + 1;
                end
            end
            
            DRAIN_PIPELINE: begin
                drain_count <= drain_count + 1;
            end
            
            NEXT_STAGE: begin
                current_stage <= current_stage + 1;
                drain_count <= 0;
            end
            
            FINISH: begin
                // Hold finished state
            end
        endcase
    end
end

// Next state logic
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
            compute_enable = (bf_count < butterflies_per_stage);
            we_mem = 1;
            
            if (bf_count >= butterflies_per_stage) 
                next_state = DRAIN_PIPELINE;
        end
        
        DRAIN_PIPELINE: begin
            we_mem = 1;
            
            if (drain_count >= PIPELINE_DEPTH) begin
                if (current_stage >= 2) // 3 stages for 8-point FFT (0,1,2)
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
    endcase
end

endmodule